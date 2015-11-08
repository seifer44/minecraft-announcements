# minecraft-announcements
Announcements plugin for Vanilla Minecraft servers. Runs via a bash script.

# Installation and Startup
1. Move the shell script to the appropriate directory and make an **announcements.d** folder in the same directory.
2. Populate that folder with individual files for different announcement messages (See below).
3. Execute the script ad-hock or on startup of your system. This would be a good candidate for screen!
````
screen -d -m -S minecraft-announcements /opt/minecraft/scripts/announcements.sh
````

# Announcement Files
There must be a single file for each announcement message that you wish to fire off via this script. That file must have at least two lines:
* A trigger command.
* Your Minecraft JSON whisper message.

Please refer to the announcements.d-examples folder for examples of these configuration files.

## Multiple Triggers
There can be multiple trigger commands present for one message. This allows for aliases to be configured for each command. To configure multiple triggers, simply make a new line with the new trigger underneath the first trigger. Regardless of the number of triggers, there must only be **one** JSON message, and that *must* be at the bottom of the file. For an example of this, please refer to the map_1 example file.

## Multiple Pages for Triggers
You can have a trigger with multiple pages available as well. This can be useful if the topic your users are inquiring about needs to consist of multiple messages. Simply create a trigger with a space-delimited number afterward, and create a similar file naming structure afteward.

Please note that the naming of the files themselves have almost no impact on the script at all. The exception is for multiple pages of a trigger. There is an additional message output to users if there is more information for them to review.

In-game Example:
````
!argument 1
<Your Text output>
"There are more arguments for $arg. Try $arg $secondarg+1 for more info."
````

The initialization of the script will discover the maximum number of pages correctly, as long as you name the files in the following format:

````
name_1
name_2
name_3
````

In this case, !name 1 and !name 2 will prompt the user that there are additional pages of information left to go through. !name 3 will not have this prompt.

If you have more than 10 arguments, then name your files in the following format to ensure this maximum page discovery feature doesn't break:

````
name_01
name_02
...
name_14
````

## Wildcarding Triggers
By default, the announcements script will only respond to exact matches of the trigger you specify. Triggers can be wildcarded as needed. This is useful for announcements upon login, as the end of the Minecraft login line varies widely between users. To wildcard, simply add a * where necessary.

Be careful with wildcarding, as you may have your announcements triggering too frequently and incorrectly. For an example of wildcarding, please refer to the loggedin example file.

# Issues
* This script can output a lot of noise into your log file if users are hitting it constantly. This is unavoidable.
