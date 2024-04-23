# GBA Emulator Arbitrary Code Execution Project

A simple framework for writing and testing arbitrary code in emulator games.
- If you're someone who just wants to try out flappy bird, a hex editor, or anything else ACE-hacked into your favorite game, all you need is a supported emulator ([mGBA](https://mgba.io/downloads.html), [Bizhawk](https://tasvideos.org/Bizhawk), or [VBA-RR](https://tasvideos.org/EmulatorResources/VBA)) and your own game ROM.
- If you want to write your own projects to share, you will need to [download ARMIPS](https://buildbot.orphis.net/armips/), and add it to your PATH or project folder.  Click [here](https://github.com/Kingcom/armips) for a reference on how to use ARMIPS, and take a peek at the `sample` in the `Projects` folder if you're unfamiliar with it.  Click [here](https://gist.github.com/nex3/c395b2f8fd4b02068be37c961301caa7) to learn how to add files/folders to the PATH.

### Try it out
- Download the repository
- open your ROM in an emulator
- open `ace_projects.lua` in your emulator's lua console
  - **mGBA**    : go to `Tools > Scripting > File > Load script...`
  - **Bizhawk** : go to `Tools > Lua Console > Script > Open Script...`  Double-click on the script to run it.
  - **VBA-RR**  : go to `Tools > Lua Scripting > New Lua Script Window... > Browse...`
- in the lua console (or overlayed input box if in **VBA-RR**), type `run("project_name")` where `project_name` is the name of any of the projects in the **Projects** folder (all projects contain an `init.lua` file, otherwise it's just a folder)
- alternatively, you can type `loadstate("filename")`, where `filename` is the name (just the name, no extension or relative path) of any savestate files in the `saves` folder of the game that you're running.  The function will detect which emulator you're using and load the corresponding file.  Example: `loadstate("hex_editor")`
- Unfortunately, if using **VBA-RR**, you must manually load savestates because lua can't do it from files. (go to `File > Load Game > Load From File...`)

### Creating a project
- Create a folder within the `Projects` folder.  If it's designed for a specific game, put your folder in that game's folder.
- Within your folder, add a file named `init.lua`.  This designates your folder as a project.
  - You may leave this file blank, or write any lua code you want to run each time your project is run.
  - To run your code from a savestate, write `loadstate("filename")` in `init.lua`
- Create an asm file within your folder to be assembled using **armips.exe**
- See the `sample` project for a simple example.  You can also copy paste it and rename the folder to make a new project.

### Testing your project
- Navigate to your folder in a terminal, and use the command `armips [main asm file name] -temp temp.txt` to assemble it.  You MUST make a temp file named `temp` for the program to copy the ARMIPS output into RAM.  You may use a name other than `temp` by setting `paths.temp` in `init.lua`
- Run `ace_projects.lua` in your emulator and Type `run("project_name")` in the lua console/input box.  You don't have to restart the script to run your code. This will automatically:
  - run `init.lua`
  - edit RAM directly using data from binaries specified in the `temp` file generated by ARMIPS

#### Notes
- Do NOT use the shorthand of `add rx, ry` when both `x` and `y` are less than 8.  Instead use the equivalent `add rx, rx, ry`, because the current ARMIPS assembler assembles the former into an illegal opcode.  The shorthand also has issues with CPU flag updating.
- Your program should only write data to RAM regions `(02000000-07FFFFFF)`
- You can have multiple output files with different header sizes to save space
