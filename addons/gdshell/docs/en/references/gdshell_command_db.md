[link_bool]: https://docs.godotengine.org/en/latest/classes/class_bool.html
[link_string]: https://docs.godotengine.org/en/latest/classes/class_string.html
[link_array]: https://docs.godotengine.org/en/stable/classes/class_array.html
[link_dictionary]: https://docs.godotengine.org/en/latest/classes/class_dictionary.html

<a href="https://github.com/Kubulambula/Godot-GDShell">
  <img src="../../../docs/assets/logo.png" align="left" width="80" height="80">
</a>

# GDShellCommandDB


### Properties

| | | |
| --- | --- | --- |
| [`Dictionary`][link_dictionary]  | [\_commands](#dictionary-_commands)  | {} |
| [`Dictionary`][link_dictionary]  | [\_aliases](#dictionary-_aliases)  | {} |
| | | |


---


### Methods
| | | |
| --- | --- | --- |
| [`bool`][link_bool] | [add_command](#add_command) ([`String`][link_string] path) | |
| `void` | [add_commands_in_directory](#add_commands_in_directory) ([`String`][link_string] path, [`bool`][link_bool] recursive=true) | |
| [`bool`][link_bool] | [remove_command](#remove_command) ([`String`][link_string] command_name) | |
| [`String`][link_string] | [get_command_path](#get_command_path) ([`String`][link_string] command_name) | `const` |
| [`Array`][link_array] | [get_all_command_names](#get_all_command_names) () | `const` |
| [`bool`][link_bool] | [add_alias](#add_alias) ([`String`][link_string] alias, [`String`][link_string] command) | |
| [`bool`][link_bool] | [remove_alias](#remove_alias) ([`String`][link_string] alias) | |
| [`Dictionary`][link_dictionary] | [get_all_aliases](#get_all_aliases) () | `const` |
| [`Array`][link_array] | [get_file_paths_in_directory](#get_file_paths_in_directory) ([`String`][link_string] path, [`bool`][link_bool] recursive=true) | `static` |
| [`Array`][link_array] | [get_command_file_paths_in_directory](#get_command_file_paths_in_directory) ([`String`][link_string] path, [`bool`][link_bool] recursive=true) | `static` |
| [`bool`][link_bool] | [is_file_gdshell_command](#is_file_gdshell_command) ([`String`][link_string] path) | `static` |
| [`Dictionary`][link_dictionary] | [get_command_name_and_autoaliases](#get_command_name_and_autoaliases) ([`String`][link_string] path) | `static` |
| | | |


---


### Property descriptions

#### [`Dictionary`][link_dictionary] \_commands

#### [`Dictionary`][link_dictionary] \_aliases


---


### Method descriptions

<span id="add_command"><span>
#### [`bool`][link_bool] add_command ([`String`][link_string] path)

<span id="add_commands_in_directory"><span>
#### `void` add_commands_in_directory ([`String`][link_string] path, [`bool`][link_bool] recursive=true)

<span id="remove_command"><span>
#### [`bool`][link_bool] remove_command ([`String`][link_string] command_name)

<span id="get_command_path"><span>
#### [`String`][link_string] get_coget_command_pathmmand_path ([`String`][link_string] command_name) - `const`

<span id="get_all_command_names"><span>
#### [`Array`][link_array] get_all_command_names () - `const`

<span id="add_alias"><span>
#### [`bool`][link_bool] add_alias ([`String`][link_string] alias, [`String`][link_string] command)

<span id="remove_alias"><span>
#### [`bool`][link_bool] remove_alias ([`String`][link_string] alias)

<span id="get_all_aliases"><span>
#### [`Dictionary`][link_dictionary] get_all_aliases () - `const`

<span id="get_file_paths_in_directory"><span>
#### [`Array`][link_array] get_file_paths_in_directory ([`String`][link_string] path, [`bool`][link_bool] recursive=true) - `static`

<span id="get_command_file_paths_in_directory"><span>
#### [`Array`][link_array] get_command_file_paths_in_directory ([`String`][link_string] path, [`bool`][link_bool] recursive=true) - `static`

<span id="is_file_gdshell_command"><span>
#### [`bool`][link_bool] is_file_gdshell_command ([`String`][link_string] path) - `static`

<span id="get_command_name_and_autoaliases"><span>
#### [`Dictionary`][link_dictionary] get_command_name_and_autoaliases ([`String`][link_string] path) - `static`
