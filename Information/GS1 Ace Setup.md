# Consistent Beginner Friendly ACE setup for GS1:

### Step 1: Acquire this inventory

![inventory](gs1_ace_setup_images/inventory.png)

```
Bone, Herb*3, Cotton Shirt, Nut*2, Elixir*18
Mint, Bandit's Sword, Sleep Bomb*2, Game Ticket*3, Mace(E)
Smoke Bomb*2, Shaman's Rod, Bramble Seed, Battle Axe
```

Ensure that the items are in the correct order.  

If you can edit memory, you can give Isaac this inventory by writing the following at address `020005D8` (in 32-bit mode):
```
10B400E7 08B50059 00C388BC 08E3001B
022B10E4 004108E2 001F00F0
```

### Step 2: Save inside of Lunpa Fortress

![lunpa](gs1_ace_setup_images/lunpa.png)

### Step 3: Enter Tret
Cast **Avoid** to prevent encounters.  Run up the vine ladder in the back of the room, run out the left door, drain your **PP** to **5 or less**, cast **Retreat** with **L** or **R** (you should get the message **"Not enough PP"**), and save in another slot.

![tret](gs1_ace_setup_images/tret.png)

### Step 4: Out of bounds
**Hard reset**, load the Tret save, and **run up+right** until you see Isaac.

![bottom_left_corner](gs1_ace_setup_images/bottom_left_corner.png)

Run around the top of the room until you're standing in this corner:

![corner](gs1_ace_setup_images/corner.png)

### Step 5: Move to the spot
**Run right** for at least **1 second**.  
**Run up** for at least **9 seconds**.
Save over the Tret file.

### Step 6: Load Lunpa Fortress
**Hard reset**, then load the **Lunpa** file.
**Soft reset**, then load the **Tret** file.
If you are unable to make savestates, then you can return to this step after any mistakes.

### Step 7: Room Transitions
Run **up+right** for at least **1 second**, then **move left**.  You should pop out here:

![left_branch](gs1_ace_setup_images/left_branch.png)

Run inside, then move down and up on the vine ladder repeatedly, for a total of **9 room transitions** on the vine.  You will end up on the bottom.

![vine_bottom](gs1_ace_setup_images/vine_bottom.png)

**Soft reset**, and load the **Tret** file again.

### Step 8: Talk to the Water Tile
Drain your **PP to zero** again, and if you can, make a savestate here.
Try to **move one tile to the right**, then **press A**.  If you moved enough, you will see the text: **"Isaac peered into the water..."**
If you moved too far, the game will crash and you will be unable to open menus.  If the game crashed, or if there's no water tile, return to step 6.

You should now be standing on the green **20**.  If you step on a **01**, the game will crash.  Your goal is the green **BC**.

![final_movement](gs1_ace_setup_images/final_movement.png)

### Step 9: The Final Movement
**Run left** for at least **2 seconds**, but in the middle of the first second, hold **Down** briefly, at least enough to move down one tile.

If you didn't move down enough, you will appear here, and need to load your savestate:

![psy_stone_room](gs1_ace_setup_images/psy_stone_room.png)

If you moved down 2-3 tiles, and held **Left** afterwards, you will appear here, and will have successfully stepped on the trigger tile:

![left_branch](gs1_ace_setup_images/left_branch.png)

If you moved down exactly one tile, you will not pop out anywhere.  In this case, **run straight down** (at least one tile, into a wall).  You may make a savestate here.  If you **press A**, the game will crash, but you will see the text: **"Isaac looked on the table..."**, confirming that the trigger tile is one tile directly to your left.  Stepping on that tile will trigger ACE.

### Step 10: Open Debug Menu
Press Start to see the expanded menu.  Hold B and press Start to open the teleportation menu.  Hold B and press select to open the flag menu.  Hold L and press Start to open the palette menu.  Hold L to walk through walls.

![teleport_menu](gs1_ace_setup_images/teleport_menu.png)
