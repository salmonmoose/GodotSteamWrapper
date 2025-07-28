# Mist
## The GodotSteam Wrapper

Mist is a collection of wrapper functions to implement the excellent GodotSteam libraries.

Each part is broken out into it's own implementation file, and configuration is handled in the project settings.

There are extra facilities to help with handling changing game configuration on Steam itself, such as leaderboards and achievements.

## SteamInput
**Mist** attempts to bind controls automatically between Godot and Steam, it does this by matching Godot `InputEventJoypadMotion` and `InputEventJoypadDigital` items handles from Steam.

#TODO: Mist should be able to create *at least* initial .vdf files.

