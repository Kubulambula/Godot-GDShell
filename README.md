# GDShell

<p align="center">
  <a href="https://github.com/Kubulambula/Godot-GDShell">
    <img src="https://github.com/Kubulambula/Godot-GDShell/blob/main/addons/gdshell/docs/logo_text.png" width="700" alt="GDShell logo">
  </a>
</p>


#### :warning: This plugin is still in early development


## The only console for Godot 4, you'll ever need
GDShell is a feature-packed in-game console for development, debugging, cheats and/or any other interaction with your game. 


## Out of the box
GDShell works right away after installation with no need for a complex setup. Add you own commands, don't reinvent the wheel and get back to the important stuff that makes your game fun.


## Easy to use
Forget creating commands from [`Callable`](https://docs.godotengine.org/en/latest/classes/class_callable.html)s, with messy object and method relations. Now every command is it's own script, resulting in better code organization and project structure by design.


**Just create a script, place it in a command folder and you're good to go!**

```gdscript
extends GDShellCommand
# res://addons/gdshell/commands/hello.gd

func _main(params):
    output("Hello World!")
    return {}
```


## Simple, yet powerful
Don't let the ease of use fool you. GDShell can be used even for more complex tasks like:

* sequential and conditional command chaining

    `alias cls clear && echo "Success" || echo "Failed"; echo ":("`

* executing commands in background

    `wait_for_godot& ; think_about_your_game_project`


* command result passing

    `gdfetch -s | echo`

The sky is the limit here. Even if you never need any of these features, you can sleep knowing, that they are here, if you ever will.


## Modular and customizable
* Do you dislike the default UI?
* Do you wish to have a new operator?
* Do you want to have bunch of buttons that call the commands directly without the console interface?

Every part of GDShell can be modified, extended or replaced as long as you implement the necessary methods.

Nearly anything your heart desire can be done done!


## Installation
### Installation with AssetLib
1. Open AssetLib in your project (AssetLib button in the top center)
2. Search for: **GDShell**
3. Open **GDShell** and click **Download**
4. Click **Install**
5. Go to `Project > Project Settings > Plugins` and check the `Enable` checkbox for GDShell


### Installation with Git
1. Clone or download the [latest release](https://github.com/Kubulambula/Godot-GDShell/releases/latest)
2. Copy the `gdshell/` folder into your project's `res://addons/` folder.
3. Go to `Project > Project Settings > Plugins` and check the `Enable` checkbox for GDShell


## Exaple usage
\*Insert examples here\*


## Documentation
See **[Docs](https://github.com/Kubulambula/Godot-GDShell/blob/main/addons/gdshell/docs/docs.md)**.


## Contributing
All contributions are very welcome, so feel free to make [issues](https://github.com/Kubulambula/Godot-GDShell/issues), [proposals](https://github.com/Kubulambula/Godot-GDShell/issues/proposal) and [pull requests](https://github.com/Kubulambula/Godot-GDShell/pulls). 


### License (It's free, baby!)
GDShell is available under the **MIT license**.
See [`LICENSE.md`](https://github.com/Kubulambula/Godot-GDShell/LICENSE.md).

GDShell logo is available under the **Free Art License 1.3**. See [`LOGO_LICENSE.md`](https://github.com/Kubulambula/Godot-GDShell/LOGO_LICENSE.md)
