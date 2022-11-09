<a href="https://github.com/Kubulambula/Godot-GDShell">
  <img src="https://github.com/Kubulambula/Godot-GDShell/blob/main/addons/gdshell/docs/assets/logo.png" align="left" width="80" height="80">
</a>

# GDShellCommand


## Tutorials
- [Your first command](https://github.com/Kubulambula/Godot-GDShell/blob/main/addons/gdshell/docs/en/getting_started/your_first_command.md)
- [Commands](https://github.com/Kubulambula/Godot-GDShell/blob/main/addons/gdshell/docs/en/tutorials/commands.md)


---


### Properties


| | | |
| --- | --- | --- |
| [`String`](https://docs.godotengine.org/en/latest/classes/class_string.html)  | [COMMAND_NAME](#string-command_name)  | `script name` |
| [`Dictionary`](https://docs.godotengine.org/en/latest/classes/class_dictionary.html)  | [COMMAND_AUTO_ALIASES](#dictionary-command_auto_aliases)  | {} |
| [`GDShellCommandRunner`](https://github.com/Kubulambula/Godot-GDShell/blob/main/addons/gdshell/docs/en/references/gdshell_command_runner.md) | [_PARENT_PROCESS](#gdshellcommandrunner-_parent_process) | null |
| | | |


### Methods
| | | |
| --- | --- | --- |
| [`Dictionary`](https://docs.godotengine.org/en/latest/classes/class_dictionary.html) | [_main](#_main) ([Array](https://docs.godotengine.org/en/stable/classes/class_array.html) argv, [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) data) | `virtual` |
| [`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) | [_get_manual](#_get_manual) () | `virtual` |
| [`Dictionary`](https://docs.godotengine.org/en/latest/classes/class_dictionary.html) | [execute](#execute) ([`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) command) | |
| [`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) | [input](#input) ([`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) out) | |
| `void` | [output](#output) ([`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) out, [`bool`](https://docs.godotengine.org/en/latest/classes/class_bool.html) append_new_line=true) | |
| [`GDShellUIHandler`](https://github.com/Kubulambula/Godot-GDShell/blob/main/addons/gdshell/docs/en/references/gdshell_ui_handler.md) | [get_ui_handler](#get_ui_handler) () | |
| [`RichTextLabel`](https://docs.godotengine.org/en/latest/classes/class_richtextlabel.html) | [get_ui_handler_rich_text_label](#get_ui_handler_rich_text_label) () | |
| | | |


---


### Signals

#### command_end ()


---


### Constants

#### [`Dictionary`](https://docs.godotengine.org/en/latest/classes/class_dictionary.html) DEFAULT_COMMAND_RESULT


---


### Property descriptions

#### [`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) COMMAND_NAME

#### [`Dictionary`](https://docs.godotengine.org/en/latest/classes/class_dictionary.html) COMMAND_AUTO_ALIASES

#### [`GDShellCommandRunner`](https://github.com/Kubulambula/Godot-GDShell/blob/main/addons/gdshell/docs/en/references/gdshell_command_runner.md) _PARENT_PROCESS


---


### Method descriptions

<span id="_main"><span>
#### [`Dictionary`](https://docs.godotengine.org/en/latest/classes/class_dictionary.html) _main ([`Array`](https://docs.godotengine.org/en/stable/classes/class_array.html) argv, [`Variant`](https://docs.godotengine.org/en/stable/classes/class_variant.html) data) - `virtual`

<span id="_get_manual"><span>
#### [`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) _get_manual () - `virtual`

<span id="execute"><span>
#### [`Dictionary`](https://docs.godotengine.org/en/latest/classes/class_dictionary.html) execute ([`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) command)

<span id="input"><span>
#### [`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) input ([`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) out)

<span id="output"><span>
#### `void` output ([`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) out, [`bool`](https://docs.godotengine.org/en/latest/classes/class_bool.html) append_new_line=true)

<span id="get_ui_handler"><span>
#### [`GDShellUIHandler`](https://github.com/Kubulambula/Godot-GDShell/blob/main/addons/gdshell/docs/en/references/gdshell_ui_handler.md) get_ui_handler ()

<span id="get_ui_handler_rich_text_label"><span>
#### [`RichTextLabel`](https://docs.godotengine.org/en/latest/classes/class_richtextlabel.html) get_ui_handler_rich_text_label ()
