<a href="https://github.com/Kubulambula/Godot-GDShell">
  <img src="https://github.com/Kubulambula/Godot-GDShell/blob/main/addons/gdshell/docs/assets/logo.png" align="left" width="80" height="80">
</a>

# GDShell Command `man`

> [!alert]
> Not all arguments and flags in this docs article are currently implemented. 

The `man` command is used to retrive information about the terminal and its commands. 

Syntax: ``man (command)``

## (command)

You can specify a command to list the manual article for, for example `man gdfetch` will print the manual for the `gdfetch` command. If no command is specified, it will defult to the manual article for the manual (being the same as `man man`). 

The manual command simply calls the passed commands `_get_manual()` function. 

## Flags

- `-L` or `--list`: List all avaible commands, sorted into core and every module you have added. 
- `-D` or `--docs`: Links you to the apropriate documentation instead of printing in the terminal. 

## Aliases

- `help` is an alias for the manual command.
- `manual` is an alias for the manual command.
