# Arbitrary Code Execution Project

A simple framework for writing and testing arbitrary code in emulator games.
- If you're someone who just wants to try out flappy bird, a hex editor, or anything else ACE-hacked into your favorite game, all you need is a supported emulator ([mGBA](https://mgba.io/downloads.html), [Bizhawk](https://tasvideos.org/Bizhawk), or [VBA-RR](https://tasvideos.org/EmulatorResources/VBA)) and your own game ROM.
- If you want to write your own projects to share, you will need to [download ARMIPS](https://buildbot.orphis.net/armips/), and add it to your PATH or project folder.  Click [here](https://gist.github.com/nex3/c395b2f8fd4b02068be37c961301caa7) to learn how to add files/folders to the PATH.

### Try it out
- Download the repository
- open your ROM in an emulator
- open "ace_projects.lua" in your emulator's lua console
  - **mGBA**    : go to `Tools > Scripting > File > Load script...`
  - **Bizhawk** : go to `Tools > Lua Console > Script > Open Script...`  Double-click on the script to run it.
  - **VBA-RR**  : go to `Tools > Lua Scripting > New Lua Script Window... > Browse...`
- in the lua console (or overlayed input box if in VBA-RR), type `run("project_name")` where `project_name` is the name of any of the project folders in `ace_projects`
  - if using VBA-RR, you must manually load a project savestate because lua can't do it natively (go to `File > Load Game > Load From File...`)

### Writing a project
- Create a folder with a different name than other project folders
- Create an asm file to be run using **armips.exe**
- Navigate to your folder in a terminal, and use the command `armips [main asm file name] -temp temp.txt`
- Optionally create a folder within the project folder named `saves`
  - within this folder, include a savestate named `state` for each emulator that you want to auto-load a state when run (VBA-RR cannot auto-load)
- Optionally add a file named `init.lua` for any code you want to run each time your project is run
- See the `sample` project for a simple example.  You can also copy paste it and rename the folder to make a new project.

- ### Requirements and Restrictions
  - You must have a copy of **armips.exe** in your project folder, or in your PATH
  - The `-temp` parameter is necessary for the lua script to work; it parses the file to determine where to write the output
  - You must use the names `main` and `temp` for your output and temp files, or set `path.main` and `path.temp` in `init.lua`
  - Do NOT use the shorthand of `add rx, ry`.  Instead use the equivalent `add rx, rx, ry`, because the current ARMIPS assembler assembles the former into an illegal opcode when both `rx` and `ry` are less than 8.  The shorthand also has issues with CPU flag updating.
  - Your program will only be able to write data to RAM regions `(02000000-07FFFFFF)`