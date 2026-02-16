# Tera
Adult voxel styled MMORPG.

## Godot 4.7 traversal + voxel prototype

This repository is now structured as a Godot 4.7 project with a traversal-heavy first-person controller and a runtime voxel world.

### Current gameplay prototype

- **Traversal focused movement:** walk, sprint, crouch, crouch-slide, mantle, and hurdle.
- **Physical presence:** acceleration-based motion, gravity-driven jumps, stance transitions, and collision-driven movement through terrain.
- **Voxel interactions:** left click to break blocks and right click to place blocks.
- **Design direction:** blocks are for **building and editing space**, while vertical traversal is handled by the character's body movement systems.

### Project layout

- `project.godot` — engine settings and input map.
- `scenes/main/Main.tscn` — world root with lighting, voxel world, and player instance.
- `scenes/player/Player.tscn` — first-person character scene.
- `scripts/player/PlayerController.gd` — traversal + movement + block interaction logic.
- `scripts/voxel/VoxelWorld.gd` — procedural block terrain + runtime place/break API.

### Controls

- `W A S D` — move
- `Shift` — sprint
- `Space` — jump / mantle / hurdle attempt
- `C` — crouch (while sprinting: crouch-slide)
- `Left mouse` — break block
- `Right mouse` — place block
- `Esc` — release mouse
- `Middle mouse` — capture mouse
## Godot 4.7 project bootstrap

This repository now includes a Godot 4.7-compatible project layout so you can open it directly in Godot and start building gameplay systems.

### Structure

- `project.godot` — engine/project settings and startup scene.
- `scenes/main/Main.tscn` — root 3D scene with environment, light and camera.
- `scripts/main/Main.gd` — bootstrap script used by the main scene.
- `assets/` — organized placeholders for art, audio and UI resources.
- `addons/` — plugin directory for future Godot editor/runtime extensions.

### Open in Godot

1. Open Godot 4.7.
2. Select **Import** and choose this repository folder.
3. Run (`F5`) and test movement + block interactions.
3. Open the project and run it (`F5`).

From there you can wire networking, player controllers and MMO systems into the provided structure.
