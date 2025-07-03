//=====================================================================================================================================================================================================
// Version: 1.5.0
// By NitrogenCynic (https://www.speedrun.com/users/NitrogenCynic) and Hilimii (https://www.speedrun.com/users/Hilimii)

// Added in this version:
    // IGT Setting. Pauses when the player has no control over the plane. Mimics IGT timing for AC7.
    // IgnoreTakeoffLanding setting. Applies the IGT setting to takeoff and landing sequences too.
//=====================================================================================================================================================================================================
state("ProjectWingman-Win64-Shipping")
// Defines pointers which are being read from game memory
{
    byte inGame: "ProjectWingman-Win64-Shipping.exe", 0x9124420; //1 when in game, 0 when in menu. Found by NitrogenCynic
    byte missionComplete: "ProjectWingman-Win64-Shipping.exe", 0x093EFDC8, 0x0, 0x438; //2 normally, 3 when mission complete trigger has been activated. Found by Hilimii
    byte isPaused: "ProjectWingman-Win64-Shipping.exe", 0x95C00C4; //2 when unpaused, 3 when paused. Found by NitrogenCynic
    byte playerRef: "ProjectWingman-Win64-Shipping.exe", 0x95C3A28, 0x118, 0x320; // Reference to the player FlyingPawn, 0 when undefined (as in menus).
    byte intoLevel: "ProjectWingman-Win64-Shipping.exe", 0x9150ED0, 0x0, 0x180, 0x658, 0x41F; // 1 When player is in mission, 0 otherwise. Also flips to 0 upon resets and deaths. 

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
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
startup
// Establishing settings and variables
{
    // User Settings

    //Mode Wrapper
    settings.Add("ModeWrapper", true, "Mode Selector: Pick One");
        // Has no functionality other than to give directions to the user and contain the two operating modes under a single title
        settings.SetToolTip("ModeWrapper", "Select only one mode at a time. They don't conflict, but having the wrong mode turned on will cause splits and timer resets at unwanted times");

    // Mission Mode
    settings.Add("Mission", true, "Mission Mode", "ModeWrapper");
    // Mission mode has the following properties:
        // Starts timer when playerRef transitions from undefined to defined (in mission)
        // Resets timer when the player resets the level. If the player completes a run, they must reset manually
        // Automatically splits once upon the mission ending
        settings.SetToolTip("Mission", "For running IL categories using Free Mission Mode. Autostarts after pressing start, autosplits once upon mission end, and resets when you restart the level");

        // Ignore Takeoff
        settings.Add("IgnoreTakeoff", true, "Autostart Ignores Takeoff Sequence", "Mission");
            // When true, tells the Start function to ignore takeoff sequences whilst in Mission Mode
            settings.SetToolTip("IgnoreTakeoff", "Your timer will no longer auto-start in takeoff sequences before missions");

        // Tunnel Run Split
        settings.Add("TunnelRun", false, "Autosplit Tunnel Run", "Mission");
            // When true, tells the Split function to split when the player completes the tunnel run in MF04
            settings.SetToolTip("TunnelRun", "Splits when the player completes the tunnel run in F59 Mission 4");

    // Campaign Mode
    settings.Add("Campaign", false, "Campaign Mode", "ModeWrapper");
    // Campaign mode has the following properties:
        // Automatically starts timer on difficulty select.
        // Does not reset automatically
        // Automatically splits once at the end of each mission (only if you complete it)
        settings.SetToolTip("Campaign", "For running full playthrough categories using campaign mode. Autostarts upon difficulty selection, splits once at the end of each mission, and resets when starting a new campaign");

        // Crash Protection
        settings.Add("CrashProtection", false, "Crash Protection", "Campaign");
            // Basic crash option. Stops the timer if the game is closed.
                settings.SetToolTip("CrashProtection", "Pauses the timer if you have not progressed beyond difficulty selection. If your game crashes, your timer will be paused until you select 'Resume' to continue a campaign run.");
       
        // Mission Start Splits
        settings.Add("StartSplits", false, "Mission Start Splits", "Campaign");
            // Adds a split to the start of each mission. Each triggers only once.
                settings.SetToolTip("StartSplits", "!!Doubles split count!! Triggers a split at the start of each mission, once only. Useful for comparing pace to IL mission times");
            
        // IGT Timer
        settings.Add("IGT", false, "In Game Timer", "Campaign");
            // Stops the timer if the player in not in mission
                settings.SetToolTip("IGT", "!!NOT LEGAL FOR RUNS!! Pauses the timer whilst not flying in mission, or, if the mission has ended.");

    // Timer pausing
    settings.Add("EnablePause",true,"Pausing Stops Timer");
        // Enables functionality for pausing the timer when the player pauses the game
        settings.SetToolTip("EnablePause", "Pauses your timer whenever you pause during a mission. No effect outside of missions.");

    // AutoSplitter settings
    refreshRate = 30;   // Autosplitter refresh rate. At 60Hz, at least on my end (Hilimii), some ticks give repeated values in debug, thereby tricking logic into believing nothing has changed, when it should have.
}
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
reset
// Establishes the criteria for reseting the timer
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
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
start
// Establish variables that need to be reset when the timer begins
// Establish criteria for beginning the timer
{
    // Tricky Mission Split Variables
    vars.beatKings = false; // Var for checking if kings split has fired
    vars.beatFaust = false; // Var for checking if faust split has fired
    vars.beatTunnel = false; // Var for checking if Tunnel run split has fired

    // Mission start split variable
    vars.prevent_start_splits = false; // Becomes true whenever a mission begins during a campaign run, false whenever a mission finishes.

    // Dictionary of Missions
    // For future use, a list of every mission and the result they return when GetLevelID function is used.
    // Key : ID - Tuple of (GetLevelID result)
    vars.StartSplitTable = new Dictionary<string, Tuple< string>>
    {
        { "mf_01"      ,    Tuple.Create(   "mf_01"        )},
        { "mf_02"      ,    Tuple.Create(   "mf_02"        )},
        { "mf_03"      ,    Tuple.Create(   "mf_03"        )},
        { "mf_04"      ,    Tuple.Create(   "mf_04"        )},
        { "mf_05"      ,    Tuple.Create(   "mf_05"        )},
        { "mf_06"      ,    Tuple.Create(   "mf_06"        )},
        { "campaign_01",    Tuple.Create(   "campaign_01"  )},
        { "campaign_02",    Tuple.Create(   "campaign_02"  )},
        { "campaign_03",    Tuple.Create(   "campaign_03"  )},
        { "campaign_04",    Tuple.Create(   "campaign_04"  )},
        { "campaign_05",    Tuple.Create(   "campaign_05"  )},
        { "campaign_06",    Tuple.Create(   "campaign_06"  )},
        { "campaign_07",    Tuple.Create(   "campaign_07"  )},
        { "campaign_08",    Tuple.Create(   "campaign_08"  )},
        { "campaign_09",    Tuple.Create(   "campaign_09"  )},
        { "campaign_10",    Tuple.Create(   "campaign_10"  )},
        { "campaign_11",    Tuple.Create(   "campaign_11"  )},
        { "campaign_12",    Tuple.Create(   "campaign_12"  )},
        { "campaign_13",    Tuple.Create(   "campaign_13"  )},
        { "campaign_14",    Tuple.Create(   "campaign_14"  )},
        { "campaign_15",    Tuple.Create(   "campaign_16"  )},
        { "campaign_16",    Tuple.Create(   "campaign_16.2")},
        { "campaign_17",    Tuple.Create(   "campaign_17"  )},
        { "campaign_18",    Tuple.Create(   "campaign_18"  )},
        { "campaign_19",    Tuple.Create(   "campaign_19"  )},
        { "campaign_20",    Tuple.Create(   "campaign_20"  )},
        { "campaign_21",    Tuple.Create(   "campaign_22"  )},
    };

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
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
init
// Establish functions
{
    // Kings Split
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
    // Faust Split
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

    // Tunnel Run Split
        // Returns true when the 4 helis spawn at the end of the tunnel in F59 4 Express Lane
        // Additionally sets the split for beatTunnel to true so it cannot repeat
    vars.TunnelSplit = (Func<int,int,bool>)((newAirUnits,oldAirUnits) =>
        {
            if
            (
            newAirUnits == ( oldAirUnits + 4) // Triggers when 4 helis spawn upon exiting tunnel
            )
            {
                vars.beatTunnel = true; // Stop repeats
                return true;
            };
                return false;
        }
    );

    // Get level ID
        // Returns a string of the current level in format "campaign"/"mf" + "_" + "num", where part 1 is vanilla/DLC, and part 2 is the mission number
        // Notable unexpected results:
            // Mission 15 is "campaign_16"
            // Mission 16 is "campaign_16.2"
            // Mission 21 is "campaign_22"
    vars.GetLevelID = (Func<string>)(() =>
        {
        var levelPtr = new DeepPointer("ProjectWingman-Win64-Shipping.exe", 0x9150ED0, 0x0, 0x180, 0x490);
        var fText = levelPtr.Deref<IntPtr>(game);

        var data = game.ReadPointer(fText);
        var length = game.ReadValue<short>(fText + 0x8);

        return game.ReadString(fText, ReadStringType.UTF16, length);
        });

    // Check Mission Start
        // Checks the criteria normally ascociated with an IL mission timer autostart. Used for mission start splits.
        // Returns true for only one tick when the mission starts.
        // Ignores takeoff and landing sequences
    vars.hasMissionStarted = (Func<byte, byte, byte, bool>)((newplayerref,oldplayerref,newlevelsequencephase) =>
        {
            if
            (
                newplayerref != 0 && oldplayerref == 0 && newlevelsequencephase == 6
            )
            {
                return true;
            };
                return false;
        }
    );
}
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
split
// Establish criteria for a split
{

    // Default logic for mission end splits.
        // Check if missioncomplete has transitioned from 2 to 3
    if
    (
        current.missionComplete == 3 && old.missionComplete == 2
    )
        {
            vars.prevent_start_splits = false;
            return true;
        }

    // Special Splits
        // These are splits that trigger at special times, not demarked by a mission ending or beginning

    // Tunnel Run
        // Check if we're on the right mission, if the split has already triggered, and if the tunnel run setting is on.
        // If true, call TunnelSplit function to test whether the 4 helicopters have spawned, which denote this split timing.
    else if
    (
        vars.GetLevelID() == "mf_04" && vars.beatTunnel == false && settings["TunnelRun"] == true
    )
    {
       return vars.TunnelSplit(current.airUnitArrayLength, old.airUnitArrayLength);
    }

    // Tricky Mission End Splits
        // Calls relevant functions in 'init' to trigger splits for the end of Kings and Faust.

    //Faust
        // Check if we're on the right mission and if we've already triggered this split
        // Compare StartSplits option with prevent_start_splits variable for this mission using XNOR. Allows this section to be bypassed before a start split activates in campaign mode on Faust.
        // If true, call FaustSplit function, which tests whether the player controller transitions to the credits controller.
    else if 
    (
        vars.GetLevelID() == "mf_06" && !vars.beatFaust && ( vars.prevent_start_splits == settings["StartSplits"] )
    )
    {
        return vars.FaustSplit();
    }

    // Kings
        // Check if we're on the right mission, and if we've already triggered this split
        // Compare StartSplits option with prevent_start_splits variable for this mission using XNOR. Allows this section to be bypassed before a start split activates in campaign mode on Kings.
        // If true, call KingsSplit function, which tests whether levelSequencePhase transitions from 6 (in mission) to 7 (in cutscene) and if we're NOT on M16 Wayback.
    else if
    (
        vars.GetLevelID() == "campaign_22" && !vars.beatKings && ( vars.prevent_start_splits == settings["StartSplits"] )
    )
    {
        return vars.KingsSplit(current.levelSequencePhase, old.levelSequencePhase, current.missionComplete);
    }

    // Mission Start Splits
        // Triggers a split at the start of each mission during a campaign run when the startsplits option is turned on

    else if
    (
        vars.hasMissionStarted(current.playerRef,old.playerRef,current.levelSequencePhase) == true // Check if mission has started using function in init
        && settings["StartSplits"] == true // Check if startsplits option is turned
        && vars.prevent_start_splits == false // Check if prevent_start_splits is currently false. This should be the case before beginning the first mission, or after completing a mission.
    )
    {
        vars.prevent_start_splits = true; // Set prevent_start_splits to true so that repeat triggers can't occur in the case of a death
        return true;
    }
}
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
isLoading
// Establish when the timer should be paused
{
    // Note that isLoading only works when comparing to Game Time in Livesplit. RTA splits will cause this functionality to cease.
    if
    (
        // Pausing - Pauses the timer if the player pauses during a mission (isPaused = 3)
        // Applies to the pause setting and the IGT setting
        (
            current.isPaused == 3
            &&
            (
                settings["EnablePause"] == true
                ||
                settings["IGT"] == true
            )
        )
        ||
        // Crash detection. Pauses timer if the player has not progressed beyond difficulty selection (onMissionSequence = 0)
        (
            current.onMissionSequence == 0
            &&
            settings["CrashProtection"] == true
        )
        ||
        // IG Timer. Pauses the timer if the player is not actively flying during a mission
            // Checks if the player is in mission by comparing intoLevel and playerRef and seeing if either is undefined. If so, pause.
            (
                (
                    (current.intoLevel == 0)
                    ||
                    (current.playerRef == 0)
                )
                ||
                // Checks if the current mission has been completed (=3) and if the player is in mission. If so, pause.
                (
                    current.missionComplete == 3
                    &&
                    current.playerRef != 0
                )
                // Checks if the IGT setting is on
                &&
                settings["IGT"] == true
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
    //print(current.airUnitArrayLength.ToString());
    //print(vars.beatTunnel.ToString());
    //print(vars.prevent_start_splits.ToString());
}
