<a href="https://github.com/Kubulambula/Godot-GDShell">
  <img src="../../../docs/assets/logo.png" align="left" width="80" height="80">
</a>

# Custom commands

This tutorial is a follow-up to the [Your first command](../getting_started/your_first_command.md) page.

Also check out the [`GDShellCommand` reference](../references/gdshell_command.md) 


## Changing the name and auto aliases

By default the command name is the name of the file (`../commands/hello.gd` -> `hello`). But sometimes you want the name to be different from the file name.

You can achieve this by changing the [`COMMAND_NAME`](../references/gdshell_command.md#string-command_name) variable inside the `_init()` method. If you change the command name at any other time, the command name will stay the same.

```gdscript
extends GDShellCommand
# res://addons/gdshell/commands/hello.gd

func _init():
	COMMAND_NAME = "sayHello" # The `hello` command renamed to `sayHello`

func _main(argv, data):
	output("Hello World!")
	return {}
```

You can change the auto aliases ([`COMMAND_AUTO_ALIASES`](../references/gdshell_command.md#dictionary-command_auto_aliases)) of the command the same way with the same rules.

```gdscript
extends GDShellCommand
# res://addons/gdshell/commands/hello.gd

func _init():
	COMMAND_NAME = "sayHello" # The `hello` command renamed to `sayHello`
  
  	COMMAND_AUTO_ALIASES = {
		"sayHelloAlias": "sayHello", # `sayHelloAlias` is alias to `sayHello`
		"abc": "sayHelloAlias --argument", # Aliases can be aliases to other aliases. Event with arguments
		"original_name": "command_2", # Auto aliases can be created even for other commands
  	}

func _main(argv, data):
	output("Hello World!")
  	return {}
```

Note that the aliases do not have to be tied to the same command. `command_1` can set aliases for `command_2` without it knowing.

Aliases and names **CAN CONTAIN** spaces, but GDShell splits the input by spaces. If you want the name or alias to contain spaces, you need to specify the name inside quotes.

```gdscript
COMMAND_NAME = "name with spaces"
```
To call this command, you would have to call it like this: `"name with spaces" --argument`


## Command data

### Getting data

Any command can accept any other command's result data. This happens when you use the pipe operator (`|`). When using the pipe, the result data of the first command will be passed to the next command.

`command_1 | command_2` - result data of `command_1` will be passed to `command_2`

Command result data is of type [`Variant`](https://docs.godotengine.org/en/latest/classes/class_variant.html), so it can hold any value, including your custom objects.

You can access the result data as the [`_main()`](../references/gdshell_command.md#_main) function argument just as the `argv`. If there is no data passed, the value of `data` will be `null`.

```gdscript
extends GDShellCommand
# res://addons/gdshell/commands/hello.gd

func _main(argv, data):
	output("Data: %s" % str(data)) # Prints the passed data to the command.
	return {}
```

### Passing data

But how do you return the data? The result data is part of the result, that the command returns.

Every GDShell command must return a [`Dictionary`](https://docs.godotengine.org/en/latest/classes/class_dictionary.html), that has the following keys:

- "error" : [`int`](https://docs.godotengine.org/en/latest/classes/class_int.html) 
- "error_string" : [`String`](https://docs.godotengine.org/en/latest/classes/class_string.html)
- "data": [`Variant`](https://docs.godotengine.org/en/latest/classes/class_variant.html)

If any of the keys is missing, it will be added with it's default value. Meaning, that returning `{}` is the same as returning the `DEFAULT_COMMAND_RESULT` constant, that already contains the default values.

```gdscript
extends GDShellCommand
# res://addons/gdshell/commands/hello.gd

func _main(argv, data):
  # All the returns below are the same 
  
	return {}
  
	return DEFAULT_COMMAND_RESULT
  
	return {
		"error": 0,
		"error_string": "No error description",
		"data": null,
	}
```

So to return the result, just set the `"data"` key to your desired value.

```gdscript
extends GDShellCommand
# res://addons/gdshell/commands/hello.gd

func _main(argv, data):
	# The data will now be preserved and passed as it contains non-default value
	return {"data": "Some return data"}
```


## Command errors

Any command can fail for various reasons so GDShell provides logical `&&` and `||` operators. The error is part of the command result and can be accessed under the `"error"` key.

Error with value `0` means, that no error occured and the command execution was successful. Any other value means, that an error occured and the value describes what type of error was encountered.

It is recommended, that you use error constants compatible with the [Godot built-in error emun](https://docs.godotengine.org/en/latest/classes/class_@globalscope.html#enum-globalscope-error)

```gdscript
extends GDShellCommand
# res://addons/gdshell/commands/hello.gd

func _main(argv, data):
	return {
		"error": 1, # Error 1 - command failer with error code 1
	}
```

Additionally you can add an error description to clearly communicate what error occured.

```gdscript
extends GDShellCommand
# res://addons/gdshell/commands/hello.gd

func _main(argv, data):
	return {
		"error": 1, # Error 1 - command failer with error code 1
		"error_string": "Waiting for Godot took too long!", # Added error description
	}
```

Note that the if the command fails, the console will not print anything on its own. If you want an error message appear, you must print that the command failed inside the command yourself.


## Executing commads inside of commands

If your command relies on another commands result, you don't have to type `command_1 | command_2` every time. Just type `command_2` and execute `command_1` inside of it.
You can call commands inside other commands by using the [`execute()`](../references/gdshell_command.md#execute) method.

```gdscript
extends GDShellCommand
# res://addons/gdshell/commands/command_2.gd

func _main(argv, data):
	var called_command_result = execute("command_1") # Executes command_1
	output("%s" % called_command_result["data"]) # Prints command_1 data
	return {}
```

You can execute either a simple command or a chain of multiple commands.
```gdscript
execute("command_1 --argument | command_2 --argument --other_argument | command_3") # result of command_3 will be returned
```


## Background commands

Your commands can be executed in the background, if they are run with the `&` suffix (`command --argument &`).

These commands immediately return [`GDShellCommand.DEFAULT_COMMAND_RESULT`](../references/gdshell_command.md#dictionary-default_command_result) and another command can be run immediately, so you loose the potential return value of the command in background. The command however continues as usual and will end when the [`_main()`](https://github.com/Kubulambula/Godot-GDShell/blob/main/addons/gdshell/docs/en/references/gdshell_command.md#_main) method ends.

So why would you want a command that runs in the background? For example you want your command to log the game's FPS, but still be able to use any other commands.

You can do this in the built-in [`_process()`](https://docs.godotengine.org/en/latest/classes/class_node.html#class-node-method-process) method as the command is a [Node](https://docs.godotengine.org/en/latest/classes/class_node.html#class-node) in the SceneTree.

```gdscript
extends GDShellCommand
# res://addons/gdshell/commands/log_fps.gd

func _main(argv, data):
	await command_end
	return {}

func _process(_delta):
	print(Engine.get_frames_per_second()) # print FPS
```

The [`command_end`](../references/gdshell_command.md#command_end-) si a built-in signal that the you can use to end the [`_main()`](../references/gdshell_command.md#_main) method from outside. As you can see, the signal is never emmited, so that the command will run forever.

Now let's see how the code would look if the command would end after 10 frames.

```gdscript
extends GDShellCommand
# res://addons/gdshell/commands/log_fps.gd

var frame_count = 0

func _main(argv, data):
	await command_end
	return {}

func _process(_delta):
	print(Engine.get_frames_per_second()) # print FPS
	frame_count += 1
	if frame_count > 10:
		command_end.emit()
```

Note that there is no built-in way to terminate a command that will run forever. The command must either end itself or be terminated by another command.

## Command manual

The default `man` command accesses the command's manual and prints it to the console. It get's the manual via the [`_get_manual()`](../references/gdshell_command.md#_get_manual) method.
This method is supposed to be overridden to return a manual of the command as [`String`](https://docs.godotengine.org/en/latest/classes/class_string.html).

You can optionally use [`BBCode`](https://docs.godotengine.org/en/latest/tutorials/ui/bbcode_in_richtextlabel.html) for enhanced and cool looks.

```gdscript
extends GDShellCommand
# res://addons/gdshell/commands/hello.gd

func _main(argv, data):
	output("Hello World!")
	return {}

func _get_manual():
	return """\
[b]NAME[/b]
	{COMMAND_NAME}

[b]AUTO ALIASES[/b]
	{COMMAND_AUTO_ALIASES}

[b]DESCRIPTION[/b]
	Prints \"Hello World!\"
""".format({
	"COMMAND_NAME": COMMAND_NAME,
	"COMMAND_AUTO_ALIASES": COMMAND_AUTO_ALIASES,
	})
```

## UIHandler direct access

UIHandler is a [`GDShellUIHandler`](../references/gdshell_ui_handler.md) instance, that has the responsibility over the console window, that the command runs in.

Sometimes, you want your command to change the appearance of the console. You might want to split the window in half and have two separate consoles.
You would have to make this feature yourself and the command would have to call the methods in your custom UIHandler.
So to make things easier, you can use the [`get_ui_handler()`](../references/gdshell_command.md#get_ui_handler) method to get the instance of the UIHandler, that handler the current console window.

But most of the time you just want to access the UIHandler's [`RichTextLabel`](https://docs.godotengine.org/en/latest/classes/class_richtextlabel.html), so you can for example get the whole console text and erase it.
For this you can use the [`get_ui_handler_rich_text_label()`](../references/gdshell_command.md#get_ui_handler_rich_text_label) method.

The example below is from the `clear` default command.

```gdscript
extends GDShellCommand
# res://addons/gdshell/commands/default_commands/clear.gd

func _main(_argv: Array, _data) -> Dictionary:
	get_ui_handler_rich_text_label().clear()
	return DEFAULT_COMMAND_RESULT
```