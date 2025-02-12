# ProjectWingman_Autosplitter
Autosplitter for Project Wingman made by NitrogenCynic and Hilimii.

Speedrun.com forum thread here: https://www.speedrun.com/project_wingman/forums/j9ro5

# Installation
### Manual
Download the main .asl file. In Livesplit, edit your layout and add a scriptable autosplitter under the control suboption. Select the file you downloaded and it should be good to go! Please note that if an update is released, you will not be informed or automatically recieve the new version.
### LiveSplit
When editing your splits in LiveSplit, if you have Project Wingman selected as your game you will be able to activate the most recent release of the Autosplitter.

## Known Issues That May Inconvenience You
### Autostart Broken on Three Missions
Mission Mode does not automatically start your timer on the following missions:
* M11 Coldwar
* M12 Midnight Light
* M19 Red Sea

To maintain parity with an Autosplitter start, apply a -1.00s offset to your timer and begin your run at the same time you press 'Start' to begin a mission.
### Timer Starting in Main Menu
You may notice your timer autostarting whenever you launch the game or return to the main menu, this is due to a limitation with a value currently being used.

# Options
In Livesplit you can choose from the following options in the autosplitter:

## Mission Mode
* Autostarts the timer when gameplay begins, this is approximately 1.00s after pressing start to begin the mission.
* Autosplits once at the end of the mission when 'Mission Complete' appears on the screen.
* Autoresets every time you reset the mission. This will not work if you have completed a run and you haven't saved/cleared your splits.
## Campaign Mode
* Autosplits once at the end of each mission.
* No autoreset functionality.
### Campaign Mode - Campaign Auto Starter (Vanilla Only)
* Autostarts the timer when you pick your difficulty and leave the lowest level main menu.
* This is disabled by default.
* This only works for Vanilla runs. Does not work for the F59 DLC.
## Pausing Stops Timer
* Pauses your timer whenever you pause the game during a mission.
* Requires you to be comparing against Game Time in Livesplit in order for this to work.
