<a href="https://github.com/Kubulambula/Godot-GDShell">
  <img src="https://github.com/Kubulambula/Godot-GDShell/blob/main/addons/gdshell/docs/assets/logo.png" align="left" width="80" height="80">
</a>

# Step by step


## Installation

Before you can do anything, you will have to install the GDShell plugin. Note that GDShell is only awailable for Godot 4.x

If you never installed any Godot plugin, checkout the Godot's [Installing plugins](https://docs.godotengine.org/en/latest/tutorials/plugins/editor/installing_plugins.html?highlight=installing%20plugins) docs or follow one of these simple guides:

#### Installation via [AssetLib](https://godotengine.org/asset-library/asset/1526)
1. Open AssetLib in your project (AssetLib button in the top center)
2. Search for: **GDShell**
3. Open **GDShell**
4. Click **Download**
5. Click **Install**
6. Go to `Project > Project Settings > Plugins` and check the `Enable` checkbox for GDShell


#### Installation via Git
1. **Clone** or **download** the [latest release](https://github.com/Kubulambula/Godot-GDShell/releases/latest)
2. Copy the `gdshell/` folder into your project's `res://addons/` folder.
3. Go to `Project > Project Settings > Plugins` and check the `Enable` checkbox for GDShell

<br>After enabling the GDShell plugin, there will be a GDShell [singleton](https://docs.godotengine.org/en/latest/tutorials/scripting/singletons_autoload.html?highlight=singletons) automatically added to your project.
<br>This plugin will also create `gdshell_toggle_ui` input action in the [input map](https://docs.godotengine.org/en/latest/tutorials/inputs/input_examples.html?highlight=input%20actions#inputmap), that will toggle your default ui.
You can change this action's events at any time and GDShell will respond to them as usual.


## Running GDShell

After installation, run your project and trigger the `gdshell_toggle_ui` event (by default it's the `LEFT QUOTE` key. That is the weird key under Esc on the top-left of your keyboard).
If you see a window to popup inside your project, then it's success! You now have officially installed GDShell!

To close the window, just trigger `gdshell_toggle_ui` again.


## Running GDShell commands

To run a GDShell command, you need to type the command name (or alias) into the input line inside GDShell window and press enter.

To see if everything works, you can try the default `gdfetch` command. This command will show you various information about your project.


## Command arguments

Commands can accept various number of arguments, that tell the command what and/or how to do anythig.<br>
For example the `man` command alone does nothing, but if you give it a command name (or alias) as a argument, it will show you the manual to that command.

Arguments are separated by spaces and passed to the command in left to right order.

`man gdfetch`<br>
`man` is a command name<br>
`gdfetch` is the argument for the `man` command. NOT another command even though `gdfetch` by itself is a command.

**Shortly:** The first word is the command that is called and all the words after are arguments for that command.

For more information you can continue by reading the [GDShell syntax](https://github.com/Kubulambula/Godot-GDShell/blob/main/addons/gdshell/docs/en/tutorials/gdshell_syntax.md) page.


## But how I do make my own commands?
Continue by reading the [Your first command](https://github.com/Kubulambula/Godot-GDShell/blob/main/addons/gdshell/docs/en/tutorials/your_first_command.md) page.


