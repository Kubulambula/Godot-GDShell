<a href="https://github.com/Kubulambula/Godot-GDShell">
  <img src="https://github.com/Kubulambula/Godot-GDShell/blob/main/addons/gdshell/docs/assets/logo.png" align="left" width="80" height="80">
</a>

# GDShellCommandDB


### Methods
| | | |
| --- | --- | --- |
| [`bool`](https://docs.godotengine.org/en/latest/classes/class_bool.html) | [add_command](#add_command) ([`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) path) | |
| `void` | [add_commands_in_directory](#add_commands_in_directory) ([`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) path, [`bool`](https://docs.godotengine.org/en/latest/classes/class_bool.html) recursive=true) | |
| [`bool`](https://docs.godotengine.org/en/latest/classes/class_bool.html) | [remove_command](#remove_command) ([`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) command_name) | |
| [`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) | [get_command_path](#get_command_path) ([`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) command_name) | `const` |
| [`Array`](https://docs.godotengine.org/en/stable/classes/class_array.html) | [get_all_command_names](#get_all_command_names) () | `const` |
| [`bool`](https://docs.godotengine.org/en/latest/classes/class_bool.html) | [add_alias](#add_alias) ([`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) alias, [`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) command) | |
| [`bool`](https://docs.godotengine.org/en/latest/classes/class_bool.html) | [remove_alias](#remove_alias) ([`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) alias) | |
| [`Dictionary`](https://docs.godotengine.org/en/latest/classes/class_dictionary.html) | [get_all_aliases](#get_all_aliases) () | `const` |
| [`Array`](https://docs.godotengine.org/en/stable/classes/class_array.html) | [get_file_paths_in_directory](#get_file_paths_in_directory) ([`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) path, [`bool`](https://docs.godotengine.org/en/latest/classes/class_bool.html) recursive=true) | `static` |
| [`Array`](https://docs.godotengine.org/en/stable/classes/class_array.html) | [get_command_file_paths_in_directory](#get_command_file_paths_in_directory) ([`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) path, [`bool`](https://docs.godotengine.org/en/latest/classes/class_bool.html) recursive=true) | `static` |
| [`bool`](https://docs.godotengine.org/en/latest/classes/class_bool.html) | [is_file_gdshell_command](#is_file_gdshell_command) ([`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) path) | `static` |
| [`Dictionary`](https://docs.godotengine.org/en/latest/classes/class_dictionary.html) | [get_command_name_and_autoaliases](#get_command_name_and_autoaliases) ([`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) path) | `static` |
| | | |


---


### Method descriptions

<span id="add_command"><span>
#### [`bool`](https://docs.godotengine.org/en/latest/classes/class_bool.html) add_command ([`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) path)

<span id="add_commands_in_directory"><span>
#### `void` add_commands_in_directory ([`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) path, [`bool`](https://docs.godotengine.org/en/latest/classes/class_bool.html) recursive=true)

<span id="remove_command"><span>
#### [`bool`](https://docs.godotengine.org/en/latest/classes/class_bool.html) remove_command ([`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) command_name)

<span id="get_command_path"><span>
#### [`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) get_coget_command_pathmmand_path ([`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) command_name) - `const`

<span id="get_all_command_names"><span>
#### [`Array`](https://docs.godotengine.org/en/stable/classes/class_array.html) get_all_command_names () - `const`

<span id="add_alias"><span>
#### [`bool`](https://docs.godotengine.org/en/latest/classes/class_bool.html) add_alias ([`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) alias, [`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) command)

<span id="remove_alias"><span>
#### [`bool`](https://docs.godotengine.org/en/latest/classes/class_bool.html) remove_alias ([`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) alias)

<span id="get_all_aliases"><span>
#### [`Dictionary`](https://docs.godotengine.org/en/latest/classes/class_dictionary.html) get_all_aliases () - `const`

<span id="get_file_paths_in_directory"><span>
#### [`Array`](https://docs.godotengine.org/en/stable/classes/class_array.html) get_file_paths_in_directory ([`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) path, [`bool`](https://docs.godotengine.org/en/latest/classes/class_bool.html) recursive=true) - `static`

<span id="get_command_file_paths_in_directory"><span>
#### [`Array`](https://docs.godotengine.org/en/stable/classes/class_array.html) get_command_file_paths_in_directory ([`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) path, [`bool`](https://docs.godotengine.org/en/latest/classes/class_bool.html) recursive=true) - `static`

<span id="is_file_gdshell_command"><span>
#### [`bool`](https://docs.godotengine.org/en/latest/classes/class_bool.html) is_file_gdshell_command ([`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) path) - `static`

<span id="get_command_name_and_autoaliases"><span>
#### [`Dictionary`](https://docs.godotengine.org/en/latest/classes/class_dictionary.html) get_command_name_and_autoaliases ([`String`](https://docs.godotengine.org/en/latest/classes/class_string.html) path) - `static`
