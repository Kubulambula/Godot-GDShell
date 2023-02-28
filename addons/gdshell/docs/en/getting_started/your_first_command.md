<a href="https://github.com/Kubulambula/Godot-GDShell">
  <img src="../../../docs/assets/logo.png" align="left" width="80" height="80">
</a>

# Your first command

[`GDShellCommand` reference](../references/gdshell_command.md)

## Creating a command

By default GDShell recursively scans the `res://addons/gdshell/commands/` directory for scripts extending [`GDShellCommand`](../references/gdshell_command.md) and adds them to [`GDShellCommandDB`](https://github.com/Kubulambula/Godot-GDShell/blob/main/addons/gdshell/docs/en/references/gdshell_command_db.md).
All the commands in GDShellCommandDB are able to be called by the user at any time.

The command can be called by the name of it's file (`../commands/hello.gd` -> `hello`)

To create a command, create a new script, that extends [`GDShellCommand`](../references/gdshell_command.md).<br>
Inside this command, you must create a `_main(argv, data)` function, that returns a [`Dictionary`](https://docs.godotengine.org/en/latest/classes/class_dictionary.html?highlight=Dictionary).
This is the function, that will be called, when the command starts.

```gdscript
extends GDShellCommand
# res://addons/gdshell/commands/hello.gd

func _main(argv, data):
  output("Hello World!") # Outputs "Hello World!"
  return {}
```

## Input/Output

You can request input from the user at any time from (almost) every command by using `await input()`.

Any command can print to the console by using the `output()` method. Any variant can be passed to this function and it will be converted to `String` and printed.

When combined, you can create a command, that responds to the user without the use of arguments.

```gdscript
extends GDShellCommand
# res://addons/gdshell/commands/hello.gd

func _main(argv, data):
  var name = await input("Hello! What is your name? ") # Peter
  output("Hello %s!" % name) # Outputs "Hello Peter!"
  return {}
```


## Arguments

All the arguments that were passed to the command can be accessed inside `argv`.<br>
All the arguments are `String`s and the first argument is always the command's name (even when the command has no arguments passed).

```gdscript
extends GDShellCommand
# res://addons/gdshell/commands/hello.gd

func _main(argv, data):
  for i in range(argv.size()):
    output("Argument %s: %s" % [i, argv[i]])
  return {}

# input:  hello Hello World!
# output: hello
#         Hello
#         World!
```


If you want to have more complex command arguments with options like `do_something --somethig=crash`, checkout [`argv_parse_options()`](../references/gdshell_command.md#argv_parse_options)


## I want a more complex command
Continue by reading on the [Custom Commands](../tutorials/custom_commands.md) page.
