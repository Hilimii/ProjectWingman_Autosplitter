# ProjectWingman_Autosplitter
Autosplitter for Project Wingman made by NitrogenCynic and Hilimii.

Speedrun.com forum thread here: https://www.speedrun.com/project_wingman/forums/j9ro5

# Installation
### Within LiveSplit (Recommended)
When editing your splits in LiveSplit, if you have Project Wingman selected as your game you will be able to activate the most recent release of the Autosplitter.

<img width="843" height="218" alt="image" src="https://github.com/user-attachments/assets/63f07db2-f4e7-4150-86f1-db831a9a4491" />

### Manual
Download the main .asl file. In Livesplit, edit your layout and add a scriptable autosplitter under the control suboption. Select the file you downloaded, and it should be good to go! Please note that if an update is released, you will not be informed or automatically receive the new version.

## Issues
See: https://github.com/Hilimii/ProjectWingman_Autosplitter/issues for currently known issues.

## Tips for Usage
It's generally good practice to ensure that you match your splits to the number of autosplits you expect to trigger during a run. For example:
### Campaign Run - Vanilla
Ensure that you have 21 splits, one for each mission.
### Campaign Run - F59
Ensure that you have 6 splits, one for each mission.
### Campaign Start Splits
If you have this setting enabled, your split number will double for the entire campaign you are running. I.e. an additional split triggers at the start of each mission.
### Single Mission Runs
Generally, you want one split. However, if you wish to gauge your pace at pivotal moments, it's okay to have additional manual splits. Just don't forget them!
### F59 M4 - Express Lane & Tunnel Run
For full runs of F59 mission 4 when you have the 'Tunnel Run' option ON, you should have 2 splits. This allows you to run the Express Lane and Tunnel Run categories simultaneously. If you are only running Tunnel Run, one split is plenty.
## Choosing the Right Options
When running full campaign runs, use the Campaign mode in the autosplitter. When running single mission runs, use mission mode. Ensure that you have only one of these options selected at a time.

# Options
In Livesplit, when editing your splits, you can access the settings menu for the autosplitter:

<img width="849" height="270" alt="image" src="https://github.com/user-attachments/assets/40214605-eb9d-45b0-80e3-1367d93b0a45" />

In this settings menu, you can check various options depending on which kind of category you wish to run, and how you want timing and splits to behave.

<img width="628" height="335" alt="image" src="https://github.com/user-attachments/assets/e5ca788a-837b-491a-90cc-d840e8fd682f" />

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
### Campaign Mode - Campaign Start Splits
* Triggers an additional split at the start of each mission. Once only per run, even if you die, return to the hangar, or restart the mission.
* Doubles your split count!!
* Allows you to accurately measure and compare to IL run times whilst running a campaign category without any additional work. You will likely need to tinker with your Livesplit layout to make use of this information.
### Campaign Mode - Crash Protection
* Pauses your timer if you have not progressed beyond difficulty selection.
* If your game closes, your timer will be paused until you select 'Resume' to continue your campaign run. This can sometimes take a few seconds to take effect.
* This is best used when your game softlocks or hard freezes. Immediately ALT+F4 to close the game and pause your timer.
* Requires you to be comparing against Game Time in Livesplit in order for this to work.
### Campaign Mode - In Game Timer (IGT)
* Pauses your timer when not in a mission, when not flying, and when you complete a mission. This includes all other sequences such as menus, cutscenes, briefings, debriefings, the hangar, takeoffs, and landings.
* Effectively emulates the IGT method utilised in AC7 speedruns.
* This timing method is NOT LEGAL for runs.
* Requires you to be comparing against Game Time in Livesplit in order for this to work.
## Pausing Stops Timer
* Pauses your timer whenever you pause the game during a mission.
* Requires you to be comparing against Game Time in Livesplit in order for this to work.
