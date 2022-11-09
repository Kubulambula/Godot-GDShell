[link_variant]: https://docs.godotengine.org/en/stable/classes/class_variant.html
[link_bool]: https://docs.godotengine.org/en/latest/classes/class_bool.html
[link_string]: https://docs.godotengine.org/en/latest/classes/class_string.html
[link_array]: https://docs.godotengine.org/en/stable/classes/class_array.html
[link_dictionary]: https://docs.godotengine.org/en/latest/classes/class_dictionary.html
[link_rich_text_label]: https://docs.godotengine.org/en/latest/classes/class_richtextlabel.html
[link_gdshell_command_runner]: https://github.com/Kubulambula/Godot-GDShell/blob/main/addons/gdshell/docs/en/references/gdshell_command_runner.md
[link_gdshell_ui_handler]: https://github.com/Kubulambula/Godot-GDShell/blob/main/addons/gdshell/docs/en/references/gdshell_ui_handler.md

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
| [`String`][link_string]  | [COMMAND_NAME](#string-command_name)  | `script name` |
| [`Dictionary`][link_dictionary]  | [COMMAND_AUTO_ALIASES](#dictionary-command_auto_aliases)  | {} |
| [`GDShellCommandRunner`][link_gdshell_command_runner] | [\_PARENT_PROCESS](#gdshellcommandrunner-_parent_process) | null |
| | | |


### Methods

| | | |
| --- | --- | --- |
| [`Dictionary`][link_dictionary] | [\_main](#_main) ([Array][link_array] argv, [Variant][link_variant] data) | `virtual` |
| [`String`][link_string] | [\_get_manual](#_get_manual) () | `virtual` |
| [`Dictionary`][link_dictionary] | [execute](#execute) ([`String`][link_string] command) | |
| [`String`][link_string] | [input](#input) ([`String`][link_string] out) | |
| `void` | [output](#output) ([`String`][link_string] out, [`bool`][link_bool] append_new_line=true) | |
| [`GDShellUIHandler`][link_gdshell_ui_handler] | [get_ui_handler](#get_ui_handler) () | |
| [`RichTextLabel`][link_rich_text_label] | [get_ui_handler_rich_text_label](#get_ui_handler_rich_text_label) () | |
| | | |


---


### Signals

#### command_end ()


---


### Constants

#### [`Dictionary`][link_dictionary] DEFAULT_COMMAND_RESULT


---


### Property descriptions

#### [`String`][link_string] COMMAND_NAME

#### [`Dictionary`][link_dictionary] COMMAND_AUTO_ALIASES

#### [`GDShellCommandRunner`][link_gdshell_command_runner] _PARENT_PROCESS


---


### Method descriptions

<span id="_main"><span>
#### [`Dictionary`][link_dictionary] _main ([`Array`][link_array] argv, [`Variant`][link_variant] data) - `virtual`

<span id="_get_manual"><span>
#### [`String`][link_string] _get_manual () - `virtual`

<span id="execute"><span>
#### [`Dictionary`][link_dictionary] execute ([`String`][link_string] command)

<span id="input"><span>
#### [`String`][link_string] input ([`String`][link_string] out)

<span id="output"><span>
#### `void` output ([`String`][link_string] out, [`bool`][link_bool] append_new_line=true)

<span id="get_ui_handler"><span>
#### [`GDShellUIHandler`][link_gdshell_ui_handler] get_ui_handler ()

<span id="get_ui_handler_rich_text_label"><span>
#### [`RichTextLabel`][link_rich_text_label] get_ui_handler_rich_text_label ()
