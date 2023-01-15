<a href="https://github.com/Kubulambula/Godot-GDShell">
  <img src="https://github.com/Kubulambula/Godot-GDShell/blob/main/addons/gdshell/docs/assets/logo.png" align="left" width="80" height="80">
</a>

# Default Command List

This article is a list of default commands. Each command has its own article explaining syntax, flags, and usage. All commands are subject to change.

<!--
  - Your README.md says you are trying to mimic the feel of BASH, so
  - I am trying to make them in line with that, but feel free
  - to change any you feel could be better!
  -->

Command arguments in brackets `()` are optional, arguments in `{}` are sometimes required, in `<>` are always required. This article does not exaustively list the arguments, only the basic ones. 

The following are **curently implemented** in some way or another: 
- [`gdfetch`](gdfetch.md): Prints basic project information to the terminal. 
- [`man (command)`](man.md): Prints manual info about the command specified. (Defult value: `man man`)
- [`echo <string>`](echo.md): Prints back the string passed in.
- [`clear`](clear.md): Clears the terminals text. 
- [`bool`](bool.md): Sets a boolean value in code. <!-- can you confirm? Your code isnt super clear. -->


The following are likely to be added at some point in the future. 
<!-- 
  - Your existing docs aren't super clear on what commands you intend to add, 
  - So I needed to take some liberties with this, feel free to edit it as needed.
  - for what you actually intend to add
  -->

- [`ls`](ls.md): list scene
- [`scn`](scn.md): handles getting setting and editing the scene tree
