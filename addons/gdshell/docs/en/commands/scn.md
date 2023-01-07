<a href="https://github.com/Kubulambula/Godot-GDShell">
  <img src="https://github.com/Kubulambula/Godot-GDShell/blob/main/addons/gdshell/docs/assets/logo.png" align="left" width="80" height="80">
</a>

# GDShell Command `scn`

> [!warning]
> This command is not currently implemented. 

The `scn` command is used to handle scene manipulation. 

Syntax: ``scn <instance <scene> | free | kill> {path}``

## Instnce

To instance a scene, do `scn instance <scene> (path)`. This will instance the specified scene at the specified path, for example doing `scn instance res://scenes/tree.tscn` will instance a scene beneth the current root node directly. You can specify a path in an optional argument, for example `scn instance res://scenes/tree.tscn /world/trees/` will instance it in that scene path based on the current world node. 

Using the `-r` (replace) will override the scene if it already exists. 

## Free

To remove a scene from the tree, use `scn free <path>`. For example, doing `scn free /world/trees` will destroy all the trees (assuming thats how your scene structure is organized). Attempting to free a kinematic body, root, or command line nodes will promt a warning, Use `-F` flag to override this, for example `scn free /` (NOT RECOMMENDED). 

The node or scene is removed by calling the `queue_free()` method on it, NOT `free()` as the name might imply, to free it instantly instead of at the next safe opportunity see `scn kill`. 

## Kill

The `scn kill <scene>` command calls the `free()` method on the scene that it is applied to. Doing this on a kinematic body, root, or the command line nodes will promt a warning. Use the `-F` flag to override it. 

It is recommended you only use the kill method when a scene is being unresponsive to `scn free` and you know it will be safe to terminate its process. 

## Closing Notes

For all of the commands, using `-F` flag will override all safeties. 

- `res://` is not required as it is the assumed default.
- `instance` can be replaced with `ins` for speed.
- `scene` is a valid alias for this command.
