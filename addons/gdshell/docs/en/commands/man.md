<a href="https://github.com/Kubulambula/Godot-GDShell">
  <img src="../../../docs/assets/logo.png" align="left" width="80" height="80">
</a>

# `man`

> ⚠️
> Not all arguments and flags in this docs article are currently implemented. 

Command arguments in brackets `()` are optional, arguments in `{}` are sometimes required, in `<>` are always required. This article does not exaustively list the arguments, only the basic ones. 

The `man` command is used to retrieve information and manuals for commands. 

Syntax: ``man (command)``

## (command)

You can specify a command to list the manual article for, for example `man gdfetch` will print the manual for the `gdfetch` command. If no command is specified, it will default to the manual article for the manual (being the same as `man man`). 

The manual command gets the manual by calling the passed commands `_get_manual()` function. See [Custom commands](custom_commands.md#command-manual)

## Flags

- `-L` or `--list`: List all avaible commands, sorted into core and every module you have added. 
<!-- - `-D` or `--docs`: Links you to the apropriate documentation instead of printing in the terminal. --> <!-- TODO -->

## Aliases

- `help` is an alias for the manual command.
- `manual` is an alias for the manual command.
