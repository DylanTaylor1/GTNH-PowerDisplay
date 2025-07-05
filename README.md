These OpenComputers (OC) scripts create a highly customizable HUD to share LSC data with the player in real-time. OC is a very powerful yet complicated mod using custom scripts, but fear not. This guide walks through every step of the process, from building the required computer to configuring the HUD. No prior knowledge of OC is necessary.

![FoxHUD](media/FoxHUD.png?)

# Bare Minimum Components

The following requires EV circuits, epoxid, and titanium (late HV). It is possible to save some resources by not including the internet card, but that will require manually copying and pasting the code from GitHub which is NOT recommended for multiple reasons.
- Tier 3 Computer Case
- Tier 2 Screen
- Tier 2 Memory
- Tier 1 Central Processing Unit
- Tier 2 Graphics Card
- Tier 1 Hard Disk Drive
- Internet Card
- Glasses Terminal
- Adapter
- Keyboard
- MFU (Optional)
- EEPROM (Lua BIOS)
- OpenOS Floppy Disk
- AR Glasses
- 1+ Cables

The MFU is an optional upgrade that allows the adapter to reach machines up to 16 blocks away--helpful if your LSC is surrounded with energy detector covers. To use the MFU upgrade, sneak right-click the LSC controller before placing it inside the adapter. The LSC controller should highlight green to indicate that the location is set. The power converter is also optional.

![MinimumComponents](media/MinimumComponents.png?)

# Building the Setup

1) Place the adapter next to the LSC, or within 16 blocks if using the MFU upgrade.
2) Connect the adapter, computer case, screen, and glasses terminal with OC cables. They do not need to be in the same location or orientation as in the image below. Also place the keyboard next to the screen, either in front or on top.
3) Power everything by connecting a GregTech or AE2 cable directly to the computer case. Alternatively, use a power converter.
4) Right-click the glasses terminal with a pair of AR glasses to link it. Equip them in a bauble slot, tinkers mask slot, or helmet slot.
5) Shift-click all the components into the computer case and press the power button.
6) Follow the commands on screen install --> Y --> Y (The OpenOS floppy disk is no longer needed in the computer afterwards).
7) Install the required scripts by copying this line of code into the computer (middle-click to paste).

        wget https://raw.githubusercontent.com/DylanTaylor1/GTNH-PowerDisplay/main/setup.lua && setup

9) Edit the config by entering edit config.lua. Change the monitor settings as needed and personalize it to your liking. Restart the computer after changing anything in the config.

        edit config.lua

![Setup](media/Setup.png?)

# Running the Program

Launch the display by entering hud. The script runs forever so restart the computer if you ever need to return to the shell. A separate computer is needed for each individual player. The available configuration options are listed below.
- Resolution - Depends on monitor (ie. 1920x1080).
- Fullscreen - Adds a vertical offset if playing on fullscreen mode.
- GUI Scale - Depends on settings (ie. 3).
- Show Current EU - Shows the amount of EU stored in the LSC, in metric or scientific notation.
- Show Rate - Shows the rate of change in EU with chevrons. Ranges from <<< to >>> depending on the speed and direction.
- Show Max EU - Shows the maximum amount of EU stored in the LSC, in metric or scientific notation.
- Wireless Mode - Enables wireless mode. This changes the current EU to the amount stored in the wireless network.
- Wireless Max - Sets the "maximum" value for the HUD to reach 100%. There is no maximum to the wireless network so this is purely visual.
- Rate Threshold - Determines how quickly the capacity of the LSC needs to be changing to increase/decrease the amount of chevrons.
- Metric - Determines metric or scientific notation for the current EU and maximum EU.
- Dimension - Change the height, length, border thickness, and font size of the HUD.
- Transparency - Change the alpha values of the shapes and the text.
- Colors - Change the colors of the energy bar, the background, the border, and the text.
- Sleep - Seconds between updates.

## Other Helpful Commands

To list all of the files installed on the robot, enter

    ls

To edit (or create) a new file, enter

    edit <filename>.lua

To remove any one file installed on the robot, enter

    rm <filename>

To uninstall all of the files from this repo, enter

    uninstall

To view an entire error message regardless of how long it may be, enter

    <program> 2>/errors.log

    edit /errors.log

## Thanks
Huge thanks to Sampsa and Vlamonster for their initial implementations and letting me take this project even further!
