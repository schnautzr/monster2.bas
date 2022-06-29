IMPORTANT!!! Before first run, ensure that "Run > Output EXE to Source Folder" is selected. Otherwise you'll get a "File not found" error when you run.

![Screenshot](https://raw.githubusercontent.com/schnautzr/monster2.bas/master/img/Screenshot.png)

## Monster Combat 2
In February of 1981, a BASIC program written by Lee J. Chapel appeared in the *Creative Computing* magazine. Monster Combat 2 is a new and improved version of the game that can run in QB64. It has a number of changes, many of which will be immediately apparent:

 - An improved map interface that allows the user to always see 5 spaces away in any direction. Additionally, the map is now in color with easier-to-read symbols. Trees are now green clubs, paths are empty spaces, inns are represented by black houses, castles are a blue capital omega, walls are gray piping symbols, and the player is a yellow smiley face.
 - I'm not entirely sure whether the castle image is intended to be shown using 16 colors or 32-bit, but the castle is shown in 32-bit colors now regardless.
 - Colored text makes it easier to play.
 - Since the keyword GET doesn't translate well to QB64, prompts for numeric options have been turned into standard input statements, which provide visual feedback and the chance to press backspace before committing your choice.
 - Hundreds of monsters have been introduced, taken from the D&D sources I have access to. Monsters that return in Monster Combat 2 have been given new stats to match their D&D stats.
 - Monsters now show their Challenge Rating so you can make a more informed decision how to approach them.
 - The currency system has had a complete overhaul. Treasure points are still used to track treasure, but are converted to coins when you visit an inn, significantly reducing your load you carry, which aids in combat.
 - The player no longer uses combat points to move. Instead, movement is the way in which time is tracked. Encumbered movement causes time to pass quicker.
 - Map refreshes happen automatically when the player is displaced.
 - The helpful giant eagle no longer rudely takes you out of the forest when you aren't in danger.
 - Distances have been converted. What used to be 10 yards is now 2 yards.
 - When a player discovers a pit, the pit is added to the map as a black dot and becomes a permanent obstacle.
 - To aid in combat calculations, Monster Combat 2 provides a helpful recommended combat strength, which tells you the maximum number required to ensure a victory. If the number you enter is greater than that or less than half of that, you are asked to confirm. You also are asked to confirm now if this would reduce your combat strength to a critical level.
 - Your combat strength is now shown in red if it's 100 or less.
 - You can easily track experience points and your own level, which guide the program in determining appropriate encounters.
 - If you inspect the code, you'll find the program flow has been improved to reduce the number of GOTOs and GOSUBs used, aiding in memory management.
 - Data has been moved out of the program code and put into modular files.
 - A trove of treasures have been added from various D&D sources.
 - Castles no longer vanish before you sack them.
 - Bribes now use coinage instead of treasure.
 - Certain creatures can no longer be targeted by certain spells.
 - Certain creatures are immune to bribing.
 - When you leave an inn, you exit the way you came in.
