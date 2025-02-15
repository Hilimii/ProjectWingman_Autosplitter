// Version: 1.0.4
// By NitrogenCynic (https://www.speedrun.com/users/NitrogenCynic) and Hilimii (https://www.speedrun.com/users/Hilimii)

//Added in this version:
    //Added processUptime pointer for tracking when the game is open
    //Removed Campaign autostart option. This was a legacy feature that is no longer needed
    // Added 'causality' and 'crashed' variables to help with crash protection
    // Redueced refresh rate from 60 to 30 Hz
    // Added basic and advanced crash protection settings, both under the new crash heading setting which has been moved out from under 'Campaign' for visibilty
    // Added exit event to track 'crashed'
    // Added update event to determine when to adjust the state of 'crashed' and 'causality'
    // Added basic and advanced crash protection logic to 'isLoading'.
    
state("ProjectWingman-Win64-Shipping")
{
    byte inGame: "ProjectWingman-Win64-Shipping.exe", 0x9124420; //1 when in game, 0 when in menu. Found by NitrogenCynic
    byte missionComplete: "ProjectWingman-Win64-Shipping.exe", 0x093EFDC8, 0x0, 0x438; //2 normally, 3 when mission complete trigger has been activated. Found by Hilimii
    byte isPaused: "ProjectWingman-Win64-Shipping.exe", 0x95C00C4; //2 when unpaused, 3 when paused. Found by NitrogenCynic
    byte playerRef: "ProjectWingman-Win64-Shipping.exe", 0x95C3A28, 0x118, 0x320; // Reference to the player FlyingPawn, 0 when undefined (as in menus).

    // A useful root object for finding a number of other in-game objects and variables.
    // WingmanInstance: "ProjectWingman-Win64-Shipping.exe", 0x9150ED0, 0x0, 0x180;
    byte levelSequencePhase: "ProjectWingman-Win64-Shipping.exe", 0x9150ED0, 0x0, 0x180, 0x999; // Level Sequence Phase
    // Enumerator for the current stage of the level
        // useful values:
        // 0 = PreStagingCutscene - MainMenu/Level Selection
        // 1 = Briefing
        // 2 = Staging -- Menu Before 'Start Mission' Button
        // 3 = Hangar
        // 4 = Takeoff
        // 5 = PreMissionCutscene
        // 6 = Mission
        // 7 = PostMissionCutscene
        // 8 = Landing
        // 9 = Debrief
        // 10 = PostDebriefCutscene
    byte onMissionSequence: "ProjectWingman-Win64-Shipping.exe", 0x9150ED0, 0x0, 0x180, 0x99B; // On Mission Sequence - True while in a 'Mission Sequence'
        // Triggers after a difficulty has been selected, once the player transitions from LevelSequencePhase 0 to 1 (Briefing)
    byte onFreeMission: "ProjectWingman-Win64-Shipping.exe", 0x9150ED0, 0x0, 0x180, 0x99A; // On Free Mission - True when in a free mission - Applicable to ILs
    float processUptime: "ProjectWingman-Win64-Shipping.exe", 0x957481C // A pure measurement in seconds of how long the game has been open
}

startup
{
    // Settings
    settings.Add("ModeWrapper", true, "Mode Selector: Pick One");
        // Has no functionality other than to give directions to the user and contain the two operating modes under a single title
    settings.Add("Mission", true, "Mission Mode", "ModeWrapper");
    // Mission mode has the following properties:
        // Starts timer when playerRef transitions from undefined to defined (in mission)
        // Resets timer when the player resets the level. If the player completes a run, they must reset manually
        // Automatically splits once upon the mission ending
    settings.Add("IgnoreTakeoff", true, "Autostart Ignores Takeoff Sequence", "Mission");
        // When true, tells the Start function to ignore takeoff sequences whilst in Mission Mode
    settings.Add("Campaign", false, "Campaign Mode", "ModeWrapper");
    // Campaign mode has the following properties:
        // Automatically starts timer on difficulty select.
        // Does not reset automatically
        // Automatically splits once at the end of each mission (only if you complete it)
    settings.Add("CrashOptions", true, "Crash Protection Options: Select one or both");
        // Heading to contain crash protection options
    settings.Add("BasicCrashProtection", false, "Basic Crash Protection", "CrashOptions");
        // Basic crash option. Stops the timer if the game is closed.
    settings.Add("AdvancedCrashProtection",true, "Advanced Crash Protection", "CrashOptions");
    settings.Add("EnablePause",true,"Pausing Stops Timer");
        // Enables functionality for pausing the timer when the player pauses the game

    // Variables
    vars.causality = false; // Variable for detecting if processUptime is ticking upwards
    refreshRate = 30; // Lowers autosplitter refresh rate. I found that on 60Hz the 'ProcessUptime' pointer would give duplicate time values on 'old' and 'current', thereby tricking causality into = false
    vars.crashed = false; // Defines 'crashed'. Default state is false because we only need it do something if the game crashes. Assume not needed until needed.
}

exit
{
    // Crashing tracking. If the game process ends for any reason, 'crashed' is set to true. See 'update' for polar case where 'crashed' = false.
    vars.crashed = true;
}

reset
{
    // Reset timer when playerRef is dereferenced (goes from defined to undefined).
    // Mission mode only.
    return (current.playerRef == 0 && old.playerRef != 0 && settings["Mission"] == true);
}

start
{
    // Mission mode only
    // Start the timer when playerRef transitions from undefined (menu) to defined (in mission)
    return
    (
        current.playerRef != 0 &&
        old.playerRef == 0 &&
        settings["Mission"] == true &&
            // Takeoff culling:
            // XNOR That only returns true if IgnoreTakeoff = true and levelSequencePhase != 4 (not takeoff), or if IgnoreTakeoff = false and LevelSequencePase = 4 (takeoff) 
            (
                current.levelSequencePhase != 4
                ==
                settings["IgnoreTakeoff"] == true
            )
    ) ||
    // Campaign mode only
    // Start the timer when the player selects difficulty and enters the first loading screen.
    (
        current.onMissionSequence == 1 &&
        old.onMissionSequence == 0 &&
        current.onFreeMission == 0  && // the free mission flag may still be set when starting a campaign mission, but should flip to 0 after difficulty selection
        settings["Campaign"] == true
    );
}
split
{
    // Trigger a split when missionComplete transitions from 2 (not complete) to 3 (mission complete)
    return current.missionComplete == 3 && old.missionComplete == 2;
}

isLoading
{
    // Note that isLoading only works when comparing to Game Time in Livesplit. RTA splits will cause this functionality to cease.
    if
    (
        // Pausing - Pauses the timer if the player pauses during a mission (isPaused = 3)
        (
            current.isPaused == 3 &&
            settings["EnablePause"] == true
        )
        ||
        // Basic crash detection. Pauses the timer if causality = false i.e. processUptime is not ticking up
        (
            current.causality == false
            &&
            (
                settings["BasicCrashProtection"] == true
                ||
                settings["AdvancedCrashProtection"] == true
            )
        )
        ||
        // Advanced crash detection. Pauses timer if crashed = true. Crashed is only set to false after the player advances beyond difficulty selection.
        (
            vars.crashed == true
            &&
            settings["AdvancedCrashProtection"] == true
        )
    )
    {
        return true;
    }
    else
    {
        return false;
    }
}
 update
 {
    // Causality tracking
        // Resource intensive but currently the cleanest way I can find to do it
        // Checks on each update if 'processUptime' has ticked up. Sets 'causality' to true if so, false otherwise.
    if
    (
        current.processUptime == old.processUptime
    )
    {
        current.causality = false;
    }
    else
    {
        current.causality = true;
    }
    // Advanced Crash restoration tracking
        // If the player advances upon difficulty selection in Campaign mode, 'crashed' is set to false. This should facilitate the timer unpausing.
    if
    (
        current.onMissionSequence == 1
        &&
        old.onMissionSequence == 0
    )
    {
        vars.crashed = false;
    }
 }