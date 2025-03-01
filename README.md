# ProjectWingman_Autosplitter
Autosplitter for Project Wingman made by NitrogenCynic and Hilimii.

Speedrun.com forum thread here: https://www.speedrun.com/project_wingman/forums/j9ro5

# Installation
### Manual
Download the main .asl file. In Livesplit, edit your layout and add a scriptable autosplitter under the control suboption. Select the file you downloaded and it should be good to go! Please note that if an update is released, you will not be informed or automatically receive the new version.
### LiveSplit
When editing your splits in LiveSplit, if you have Project Wingman selected as your game you will be able to activate the most recent release of the Autosplitter.

## Issues
See: https://github.com/Hilimii/ProjectWingman_Autosplitter/issues for currently known issues.

## Tips for Usage
It's generally good practice to ensure that your number of splits match the number of autosplits you expect to trigger during a run. For example:
### Campaign Run - Vanilla
Ensure that you have 21 splits, one for each mission.
### Campaign Run - F59
Ensure that you have 6 splits, one for each mission.
### Single Mission Runs
Generally, you want one split. However, if you wish to gauge your pace at pivotal moments, it's okay to have additional manual splits. Just don't forget them!
### F59 4 - Tunnel Run
For full runs of F59 mission 4 when you have the 'Tunnel Run' option ON, you should have 2 splits. This allows you to run the mission category and tunnel run category at once.
## Chosing the Right Options
When running full campaign runs, use the Campaign category. When running single mission runs, use mission mode. Ensure that you have only one of these options selected at a time.

# Options
In Livesplit you can choose from the following options in the autosplitter:

## Mission Mode
* Autostarts the timer when gameplay begins, this is approximately 1.00s after pressing start to begin the mission.
* Autosplits once at the end of the mission when 'Mission Complete' appears on the screen.
* Autoresets every time you reset the mission. This will not work if you have completed a run or if you have gold splits.
### Autostart Ignores Takeoff Sequence
* Prevents the timer from automatically starting when beginning a takeoff sequence on any mission.
### Tunnel Run
* For running the F59 Mission 4: Express Lane tunnel run category. Triggers a split when you exit the tunnel.
* If you intend to run the entire mission as well (which you can), ensure you have 2 splits!
## Campaign Mode
* Autosplits once at the end of each mission.
* Autostarts when you select your difficulty to begin the campaign.
* Autoresets whenever you start a new campaign, useful if you reset on mission 1 often. This will not work if you have completed a run or you have gold splits.
### Campaign Mode - Crash Protection
* Pauses your timer if you have not progressed beyond difficulty selection.
* If your game crashes, your timer will be paused until you select 'Resume' to continue your campaign run.
* Requires you to be comparing against Game Time in Livesplit in order for this to work.
## Pausing Stops Timer
* Pauses your timer whenever you pause the game during a mission.
* Requires you to be comparing against Game Time in Livesplit in order for this to work.
