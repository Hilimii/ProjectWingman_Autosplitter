// Version: 1.2.0
// By NitrogenCynic (https://www.speedrun.com/users/NitrogenCynic) and Hilimii (https://www.speedrun.com/users/Hilimii)

// Added in this version:
    // Split detection for Express Lane: Tunnel Run

state("ProjectWingman-Win64-Shipping")
{
    byte inGame: "ProjectWingman-Win64-Shipping.exe", 0x9124420; //1 when in game, 0 when in menu. Found by NitrogenCynic
    byte missionComplete: "ProjectWingman-Win64-Shipping.exe", 0x093EFDC8, 0x0, 0x438; //2 normally, 3 when mission complete trigger has been activated. Found by Hilimii
    byte isPaused: "ProjectWingman-Win64-Shipping.exe", 0x95C00C4; //2 when unpaused, 3 when paused. Found by NitrogenCynic
    byte playerRef: "ProjectWingman-Win64-Shipping.exe", 0x95C3A28, 0x118, 0x320; // Reference to the player FlyingPawn, 0 when undefined (as in menus).

    // A useful root object for finding a number of other in-game objects and variables.
    //byte WingmanInstance: "ProjectWingman-Win64-Shipping.exe", 0x9150ED0, 0x0, 0x180;
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

    int airUnitArrayLength: "ProjectWingman-Win64-Shipping.exe", 0x09150ED0, 0x0, 0x118, 0x388; // Length of the currently available air units in the mission
}

startup
{
    // User Settings
    settings.Add("ModeWrapper", true, "Mode Selector: Pick One");
        // Has no functionality other than to give directions to the user and contain the two operating modes under a single title
        settings.SetToolTip("ModeWrapper", "Select only one mode at a time. They don't conflict, but having the wrong mode turned on will cause splits and timer resets at unwanted times");
    settings.Add("Mission", true, "Mission Mode", "ModeWrapper");
    // Mission mode has the following properties:
        // Starts timer when playerRef transitions from undefined to defined (in mission)
        // Resets timer when the player resets the level. If the player completes a run, they must reset manually
        // Automatically splits once upon the mission ending
        settings.SetToolTip("Mission", "For running IL categories using Free Mission Mode. Autostarts after pressing start, autosplits once upon mission end, and resets when you restart the level");
        settings.Add("IgnoreTakeoff", true, "Autostart Ignores Takeoff Sequence", "Mission");
            // When true, tells the Start function to ignore takeoff sequences whilst in Mission Mode
            settings.SetToolTip("IgnoreTakeoff", "Your timer will no longer auto-start in takeoff sequences before missions");
        settings.Add("TunnelRun", false, "Autosplit Tunnel Run", "Mission");
            // When true, tells the Split function to split when the player completes the tunnel run in MF04
            settings.SetToolTip("TunnelRun", "Splits when the player completes the tunnel run in F59 Mission 4");
    settings.Add("Campaign", false, "Campaign Mode", "ModeWrapper");
    // Campaign mode has the following properties:
        // Automatically starts timer on difficulty select.
        // Does not reset automatically
        // Automatically splits once at the end of each mission (only if you complete it)
        settings.SetToolTip("Campaign", "For running full playthrough categories using campaign mode. Autostarts upon difficulty selection, splits once at the end of each mission, and resets when starting a new campaign");
        settings.Add("CrashProtection", false, "Crash Protection", "Campaign");
            // Basic crash option. Stops the timer if the game is closed.
                settings.SetToolTip("CrashProtection", "Pauses the timer if you have not progressed beyond difficulty selection. If your game crashes, your timer will be paused until you select 'Resume' to continue a campaign run.");
    settings.Add("EnablePause",true,"Pausing Stops Timer");
        // Enables functionality for pausing the timer when the player pauses the game
        settings.SetToolTip("EnablePause", "Pauses your timer whenever you pause during a mission. No effect outside of missions.");

    // AutoSplitter settings
    refreshRate = 30; // Lowers autosplitter refresh rate. At 60Hz, at least on my end (Hilimii), some ticks give repeated values in debug, thereby tricking logic into believing nothing has changed, when it should have.
}

reset
{
    return
    // Mission mode only.
        // Reset timer when playerRef is dereferenced (goes from defined to undefined).
    (
        current.playerRef == 0
        &&
        old.playerRef != 0
        &&
        settings["Mission"] == true
    )
    ||
    // Campaign mode only
        // Watches onMissionSequence and levelSequencePhase. When the player has progressed beyond difficulty selection (onMissionSequence), test to see if levelSequencePhase has changed as well.
        // When starting a new campaign, behaviour is as follows: onMissionSequence changes from 0 --> 1. levelSequencePhase stays put at 0, this is because the campaign starting cutscene is not counted as a briefing.
        // When resuming a campaign, behaviour is as follows: onMissionSequence changes from 0 --> 1. levelSequencePhase changes from 0 --> 1, this is because it transitions to a briefing for the relevent resumed mission.
        // Reset only occurs when we satisfy the conditions for starting a new campaign.
    (
        current.onMissionSequence == 1 && old.onMissionSequence == 0
        &&
        current.levelSequencePhase == old.levelSequencePhase
        &&
        ( // Checks if the level we're transitioning to is the first mission of either campaign. This stops levels like campaign_17 'No Respite' triggering a reset with a cutscene.
            vars.GetLevelID() == "campaign_01"
            ||
            vars.GetLevelID() == "mf_01"
        )
        &&
        settings["Campaign"] == true
    )
    ;
}

start
{
    vars.beatKings = false;
    vars.beatFaust = false;

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
        settings["Campaign"] == true
    );
}

init
{
    // Returns True when the mission Kings in the main campaign is complete.
    // Rules consider this to be completion of the fadeout after Crimson 1.
    vars.KingsSplit = (Func<byte, byte, byte, bool>)((currPhase, oldPhase, missionComplete) =>
        {
            if (currPhase == 7 && oldPhase == 6 && missionComplete == 2)
            {
                vars.beatKings = true;
                return true;
            };
            return false;
        }
    );

    // Returns True when the mission Faust in Frontline 59 is complete.
    // Rules consider this to be when the Frontline 59 logo cutscene starts.
    vars.FaustSplit = (Func<bool>)(() =>
        {
            var gameBase = modules.First().BaseAddress;
            var expectedOffset = 0x8550; // Extracted from the MF59Ending address pattern

            var controllerPawnPtr = new DeepPointer("ProjectWingman-Win64-Shipping.exe", 0x95AC140, 0x30, 0x250);
            var pawnClassPtr = controllerPawnPtr.Deref<IntPtr>(game);
            var pawnClass = game.ReadPointer(pawnClassPtr);

            var relativeOffset = (long)pawnClass - (long)gameBase;

            // Debug in case this ever breaks
            // print("Relative Offset: " + relativeOffset.ToString("X"));

            // Check that the relative offset ends with 8550
            if ((relativeOffset & 0xFFFF) == expectedOffset)
            {
                vars.beatFaust = true;
                return true;
            };
            return false;
        }
    );

    vars.GetLevelID = (Func<string>)(() =>
        {
        var levelPtr = new DeepPointer("ProjectWingman-Win64-Shipping.exe", 0x9150ED0, 0x0, 0x180, 0x490);
        var fText = levelPtr.Deref<IntPtr>(game);

        var data = game.ReadPointer(fText);
        var length = game.ReadValue<short>(fText + 0x8);

        return game.ReadString(fText, ReadStringType.UTF16, length);
        });

}

split
{
    // Trigger a split when missionComplete transitions from 2 to 3 (for most missions) or at the end of Kings or Faust.
    if (vars.GetLevelID() == "mf_06" && !vars.beatFaust){
         return vars.FaustSplit();
        }
    else if (vars.GetLevelID() == "mf_04" && settings["TunnelRun"] == true){
        return (current.airUnitArrayLength == old.airUnitArrayLength + 4); // 4 helicopters spawn at the end of the tunnel run, before any other air units
    }
    else if (vars.GetLevelID() == "campaign_22" && !vars.beatKings){
        return vars.KingsSplit(current.levelSequencePhase, old.levelSequencePhase, current.missionComplete);
    }
    else{
        return (current.missionComplete == 3 && old.missionComplete == 2);
    }
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
        // Crash detection. Pauses timer if the player has not progressed beyond difficulty selection (onMissionSequence = 0)
        (
            current.onMissionSequence == 0
            &&
            settings["CrashProtection"] == true
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
    // for bug testing
    //print("levelSequencePhase: " + current.levelSequencePhase.ToString());
    //print("onMissionSequence: " + current.onMissionSequence.ToString());
    //print("level: " + vars.GetLevelID().ToString());
}
