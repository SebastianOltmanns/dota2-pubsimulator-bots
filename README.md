# dota2-pubsimulator-bots
Bots for Dota2
######Taken from https://www.reddit.com/r/DotA2/comments/5lyk8l/pubsimulator_new_bots_for_dota_2/ which refers to https://drive.google.com/drive/folders/0B_EM8FzbqIOPOVJvd2lkSnZmR1k
######Written by PLATINUM (Pooya J. also known as PLATINUM_DOTA2) (https://www.reddit.com/user/PLATINUM_DOTA) (Email: platinum.dota2@gmail.com)
######Uploaded by Sebastian Oltmanns (contact: sebastian.oltmanns.developer@gmail.com)
######Read bots/README.txt for further information by author
######Reddit-Post visited 07 Januar 2017:

This is a complete takeover of dota 2 bots for 5 heroes (Timber, Zeus, Furion, Bloodseeker and Treant) that play and interact with each other.

Some of the features are:

    Bots now are equipted with the most advanced ShitTalking™ technology
    3 new heroes: Timber, Treant and Furion
    A Zeus bot that doesn't suck with a top of the line KSing technology
    A jungle Bloodseeker
    A new path finding function that doesn't suck (read "sucks less")
    A support (Treant) that buys and upgrades courier and places wards. He also changes the warding locations during the game and tries to avoid enemies while placing them.
    Rotations/Ganks (by BS and Furion)
    Ratting technology by Furion
    A Timbersaw that always (read sometimes) hits his spells
    I have overwritten item uses and builds for all of the 5 heroes (changing builds are easy, you can do that yourself in about 2 minutes if you don't like my builds)
    Super high win-rate (more than 90%) against default bots with good K/D/A s
    Bots can play both radiant and dire and you can switch their lanes (read the readme.txt file)

Bugs/issues I'm aware of:

    Bots have difficulty pushing high ground (this is because the API only gives access to towers and barracks)
    Bots cannot see/attack ancients! (Same issue)
    Bots don't defend objectives much (mostly because default bots couldn't get to my bots' racks often, and holidays are over blah blah)
    Bots feed courier sometimes (the problem is with the API, not my code)
    Bots sometimes become stupid and the framerate drops (this is also problem with the back-end, if you open console, you'll probably see bunch of yellow lines/warnings)
    You play with them and they sometimes follow you blindly (there is a hidden bot mode I couldn't overwrite (assemble with humans) which causes some problems). To (somewhat) avoid this don't ping while playing with them.
    Bots don't react to some spells (this is because I didn't tell them how to play against each specific hero, so they are bad against heroes like Pudge, Witch doctor, Kunkka, Lich etc.)

I suggest opening console once in a while, specially if something weird happened. If you saw purple lines of warning/error it is my script, otherwise (yellow, red, etc.) it is the back-end. Otherwise, I forgot to consider something in the script.

Instructions on how to use the bots can be found in the readme.txt file (just copy all the files in the "bots" folder).

Here is the link to the files:

Link

Some remarks:

    I suggest playing against them, and choosing your teammates to be the default bots or your friends.
    Thanks to the guys at Valve's dota bot scripting wiki for their useful comments and posts. Also thanks to ChrisC for updating the API (the API still sucks btw, but it is getting better).
    You are welcome to use any part of this code (for non-commercial uses of course), a reference will be appreciated. I did this for fun during the holidays (and learning lua/bot scripting at the same time). If you are a coder, you will find a shit ton of useful functions/generic modules in these files. I will be pissed off if others don't make bots that beat mine heavily in couple of weeks.
    I will not participate in bot tournaments (don't have much time).
    Let me know if you found any major problems

I hope you like them and happy new year!

Edit: Thanks for the up-votes and the comments! Some responses:

    You should choose local host in the lobby settings. I also only tested their "unfair" difficulty. They don't abuse the fact that they are bots (i.e. they don't build SoV and hex you instantly etc.).
    Treant doesn't do much other than warding and healing heroes/towers: He is the only support in the team and prioritize buying wards and courier. I tried making him do more but he feeds since he is under farmed. One reason I didn't pick an actual hard carry was this (also the fact that writing a bot for timber was more challenging/fun)
    They lose against humans: I mostly tested them against default bots. Keep in mind that I wrote these codes in 10 days, some of us has played this game for more than 10 years.
    Furion only uses his lvl 3 for pushing towers: currently there is nothing in the API for controlling summons, so they are mostly like zombies running around. If he summons more treants then they block him (sometimes this happens even now).
    They don't 5 man until the end: I was planning to make them 5 man often, but ran out of time. Feel free to add these yourself.
    They don't last hit/farm well: They usually farm better than the default bots. It is easy to write a bot that last hits near perfection in a lane without an enemy. I had to make them play more passive and last hit more carefully to not die (the bots became worse at last hitting as I added new things).
    Why not Github: I have no Idea when I'll have time to work on this again. If I changed something, I'll post it here. I also thought it would be easier for general audience to use google drive. I'm hoping others take over from here (just add your name as an author in the files) and add new heroes and modes (there are a lot of useful tools in the files that I didn't have at the beginning, adding new heroes is much easier now).
    Deep learning, Neural netweorks etc: I don't think this is going to happen. The best thing you may be able to do is adjusting some parameters with learning algorithms (even doing this is unlikely). There are 2 limitations: 1. Your code should run in real time 2. The game is too complicated.

Edit2: I challenge /u/SirActionSlacks- to win against my bots 1v5 :D!
