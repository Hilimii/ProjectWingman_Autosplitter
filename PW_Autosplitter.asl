// Version: 1.0.3
// By NitrogenCynic (https://www.speedrun.com/users/NitrogenCynic) and Hilimii (https://www.speedrun.com/users/Hilimii)
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
    float HUDSpeed: "ProjectWingman-Win64-Shipping.exe", 0x95AC140, 0x30, 0xC58, 0x4F8, 0x5EC; // Denotes the current speed of the player's speed as shown by the HUD. Generally either zero or freezes at current value when not in use.
        // Note that this takes on a value as donated by the units which the player has set in their options (knots or Kph)
    float processUptime: "ProjectWingman-Win64-Shipping.exe", 0x957481C; // A pure measurement in seconds of how long the game has been open
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
    settings.Add("CampaignStarter", false, "Campaign Auto Starter", "Campaign");
        // Enables auto starting in campaign mode, specifically when entering the first loading screen after selecting difficulty.
    settings.Add("EnablePause",true,"Pausing Stops Timer");
        // Enables functionality for pausing the timer when the player pauses the game
    // Autosplitter settings
    refreshRate = 30; // Lowers autosplitter refresh rate. I found that on 60Hz the 'ProcessUptime' pointer would give duplicate time values on 'old' and 'current', thereby tricking causality into = false
    
    // Variables
    vars.pauseGrace = 0;
        // Variable for tracking a grace peroid after unpausing. Relevant to Faust fix.
    vars.faustSplit = false;
        // Variable for tracking if we have triggered a Faust split.
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
        current.onFreeMission == 0 && // the free mission flag may still be set when starting a campaign mission, but should flip to 0 after difficulty selection
        settings["CampaignStarter"] == true
    )
    ;
}

split
{
    // Trigger a split when missionComplete transitions from 2 (not complete) to 3 (mission complete)
    return
    (
        current.missionComplete == 3
        &&
        old.missionComplete == 2
    )
    ||
        // King Fix. Triggers a split when transitioning to a post mission cutscene ONLY when missionComplete didn't change to 3. This stops Wayback triggering a false positive.
    (
        current.levelSequencePhase == 7
        &&
        old.levelSequencePhase == 6
        &&
        current.missionComplete == 2
    )
    ||
    // Faust Fix
    // This is a very convoluted bandaid fix, beware reading this. The logic below defines the very specific circumstances in which M6 Faust ends, thereby triggering a split
    // I don't know if ALL of this logic is required, but I did it to be safe.
    (
        current.levelSequencePhase == 6
         // First check is if we're in a misson (=6)
        &&
        (
            current.HUDSpeed
            ==
            old.HUDSpeed
        )
         // Second check is if the player's speed is currently static. When M6 Faust ends, player speed is frozen.
        &&
        current.HUDSpeed != 0
        // Third check is if speed is not zero. This helps to rule out takeoff sequences like in F59 M1 BotB
        &&
        current.isPaused == 2
        // Fourth check is if we're not paused. Otherwise pausing would satisfy logic.
        &&
        current.playerRef != 0
        // Fifth check is if the player is spawned in. When Faust ends, the player remains spawned in until the title screen ends. This check allows us rule out most other mission endings, especially Kings.
        &
        current.missionComplete == 2
        // Sixth check is if missionComplete = 2 (not complete), this rules out every mission except Kings and Faust.
        &&
        vars.pauseGrace == 0
        // Seventh check is if pauseGrace is not active.
            // Pause grace is important because pausing the game will active a split using the current logic.
            // This is because briefly, when unpausing, the game stands still, giving several frames where speed is static and not zero, thus satisfying logic.
            // Pause grace is turned on for 0.5s (15 ticks at 30Hz) whenever the player unpauses to stop this happening.
        &&
        vars.faustSplit == false
           // Eighth check is if we have already triggered a split using the above logic. Stops repeat splits every tick in the unlikely event that a player wants to run vanilla + F59 together, starting with F59.
    )
    ;
}

onSplit
{
    // Faust logic
    // Read the above Faust fix for context. This repeats the same logic to identify when a Faust split happens.
    // When Faust split does happen, faustsplit is set to true so it can't happen again. Otherwise, it would split again every tick.
    if
    (
        current.levelSequencePhase == 6
        &&
        (
            current.HUDSpeed
            ==
            old.HUDSpeed
        )
        &&
        current.HUDSpeed != 0
        &&
        current.isPaused == 2
        &&
        current.playerRef != 0
        &
        current.missionComplete == 2
        &&
        vars.pauseGrace == 0
    )
    {
        vars.faustSplit = true
    ;
    }
    
}

isLoading
{
    // Pauses the timer if the game is paused (isPaused = 3).
    // Note that isLoading only works when comparing to Game Time in Livesplit. RTA splits will cause this functionality to cease.
    if( current.isPaused == 3 && settings["EnablePause"] == true )
        { return true;
    }
    else{
        return false;
    }
}

update
{
    if
    // Check when the game is unpaused. If true, set pauseGrace to maximum (15 ticks)
    (
        current.isPaused == 2
        &&
        old.isPaused == 3
    )
    {
        vars.pauseGrace = 15
        ;
    }

    if
    // Check if the game is unpaused, and if pauseGrace is more than 0. If true reduce pauseGrace by 1 each tick until it hits zero.
    (
        current.isPaused == 2
        &&
        vars.pauseGrace > 0
    )
    {
        vars.pauseGrace = vars.pauseGrace - 1
        ;
    }

    if
    // Failsafe for if pauseGrace drops below 0, thereby setting it to 0 (default state). This shouldn't happen.
    (
        vars.pauseGrace < 0
    )
    {
        vars.pauseGrace = 0
        ;
    }
}