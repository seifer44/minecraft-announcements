# minecraft-announcements
Announcements plugin for Vanilla Minecraft servers. Runs via a bash script.

# Installation and Startup
1. Move the shell script to the appropriate directory and make an **announcements.d** folder in the same directory.
2. Populate that folder with individual files for different announcement messages (See below).
3. Execute the script ad-hock or on startup of your system. This would be a good candidate for screen!
    screen -d -m -S minecraft-announcements /opt/minecraft/scripts/announcements.sh

# Announcement Files
There must be a single file for each announcement message that you wish to fire off via this script. That file must have at least two lines:
* A trigger command.
* Your Minecraft JSON whisper message.

There can be multiple trigger commands present. This allows for aliases to be configured for each command. Regardless of the number of aliases, there must only be **one** JSON message, and that *must* be at the bottom of the file.

Triggers can be wildcarded as necessary. This is useful for announcements upon login, as the tail of the user login line varies widely between users. Be careful with wildcarding, as you may have your announcements triggering too frequently and incorrectly.

Please refer to the announcements.d-examples folder for examples of these configuration files.

# Issues
* This script can output a lot of noise into your log file if users are hitting it constantly. This is unavoidable.
* Only one JSON message per file.
