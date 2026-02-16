# Tera
Adult voxel styled MMORPG.

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
3. Open the project and run it (`F5`).

From there you can wire networking, player controllers and MMO systems into the provided structure.
