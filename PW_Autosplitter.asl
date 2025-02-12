// Version: 1.0.0
// By NitrogenCynic (https://www.speedrun.com/users/NitrogenCynic) and Hilimii (https://www.speedrun.com/users/Hilimii)
state("ProjectWingman-Win64-Shipping")
{
    byte inGame: "ProjectWingman-Win64-Shipping.exe", 0x9124420; //1 when in game, 0 when in menu. Found by NitrogenCynic
    byte missionComplete: "ProjectWingman-Win64-Shipping.exe", 0x093EFDC8, 0x0, 0x438; //2 normally, 3 when mission complete trigger has been activated. Found by Hilimii
    byte isPaused: "ProjectWingman-Win64-Shipping.exe", 0x95C00C4; //2 when unpaused, 3 when paused. Found by NitrogenCynic

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

}

startup
{
    settings.Add("ModeWrapper", true, "Mode Selector: Pick One");
        // Has no functionality other than to give directions to the user and contain the two operating modes under a single title
    settings.Add("Mission", true, "Mission Mode", "ModeWrapper");
    // Mission mode has the following properties:
        // Starts timer when inGame changes to 1
        // Resets timer when the player resets the level. If the player completes a run, they must reset manually
        // Automatically splits once upon the mission ending
    settings.Add("Campaign", false, "Campaign Mode", "ModeWrapper");
    // Campaign mode has the following properties:
        // Does not automatically start timer, unfortunately not possible with our current variables
        // Does not reset automatically, again not possible with current variables.
        // Automatically splits once at the end of each mission (only if you complete it)
    settings.Add("CampaignStarter", false, "Campaign Auto Starter (Vanilla Only)", "Campaign");
        // Enables auto starting in campaign mode, specifically when entering the first loading screen after selecting difficulty. This can proc every time the player returns to menu, hence being annoying and worth turning off.
    settings.Add("EnablePause",true,"Pausing Stops Timer");
        // Enables functionality for pausing the timer when the player pauses the game
}

reset
{
    //Reset timer when missionComplete transitions from 3 (complete) to 2 (default state).
    //Mission mode only.
    return (current.inGame == 0 && old.inGame == 1 && settings["Mission"] == true);
}

start
{
    // Mission mode only
        // Start the timer when inGame transitions from 0 (menu) to 1 (in mission)
    return
    (current.inGame == 1 && old.inGame == 0 && settings["Mission"] == true) ||
    // Campaign mode only
        //Start the timer when the player selects difficulty and enters the first loading screen. For some reason, InGame = 1 in the vanilla main menu, so we can use this to start the campaign run by watching when it turns from 1 to 0.
    (current.inGame == 0 && old.inGame == 1 && settings["CampaignStarter"] == true);
}
split
{
    // Trigger a split when missionComplete transitions from 2 (not complete) to 3 (mission complete)
    return current.missionComplete == 3 && old.missionComplete == 2;
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
