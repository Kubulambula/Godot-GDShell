<a href="https://github.com/Kubulambula/Godot-GDShell">
  <img src="https://github.com/Kubulambula/Godot-GDShell/blob/main/addons/gdshell/docs/assets/logo.png" align="left" width="80" height="80">
</a>

# GDShell Command `ls`

> [!warning]
> This command is not currently implemented. 

The `ls` command is used to list the current scenes tree. 

Syntax: ``ls (scene path)`` command prints a tree view layout of the scene tree. For example: 

```
game_manager (Node2D)
├── player (KinimaticBody2D) 📜 🎬
|   ├── hurtbox (CollisionShape2D)
|   ├── sprite 
|   ├── animation_player
|   ├── animation_tree 
|   ├── camera_2D
|   ├── hitbox_pivot (Position2D) 
|   └── user_interface 🎬
├── overworld 🎬
|   ├── trees (YSort)
|   |   ├── tree1 (StaticBody2D) 🎬
|   |   ├── tree2 (StaticBody2D) 🎬
|   |   ├── tree3 (StaticBody2D) 🎬
|   |   ├── tree4 (StaticBody2D) 🎬
|   |   ├── tree5 (StaticBody2D) 🎬
|   ├── cliffs (TileMap)
|   ├── skybox (Sprite)
|   └── enemy_bat 📜 🎬
└── etc.
```

The `📜` emoji indicates that it has a script attached, which can be CTRL clicked to open it in the terminal text editor. 
The `🎬` emoji indicates that it is a scene and not a stray node. 
The nodes have in brackets thier type next to them, unless its name is its type, in which case that can be excuded. 

if the nested nodes end without one at the base level, it will end with the following instead of what is demomontration above. 

```
|   └── NodeName
```

You can also get the tree for a specific scene or path by doing `ls (path)`. So if using the example above, you did `ls player` it would instead list: 

```
player (KinimaticBody2D) 📜 🎬
├── hurtbox (CollisionShape2D)
├── sprite 
├── animation_player
├── animation_tree 
├── camera_2D
├── hitbox_pivot (Position2D) 
└── user_interface 🎬
```

You can also get the scene tree for an unloaded scene, but you will need to specify `res://` and the path from that. 

