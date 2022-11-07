<a href="https://github.com/Kubulambula/Godot-GDShell">
  <img src="https://github.com/Kubulambula/Godot-GDShell/blob/main/addons/gdshell/docs/assets/logo.png" align="left" width="80" height="80">
</a>

# Introduction

## About GDShell

GDShell was originally developed as a small plugin for a small indie game that is yet to be released.

Over time it evolved into a full plugin and as there was a only few Godot 4 console plugins at the time and every single one used the same system of [`Callables`](https://docs.godotengine.org/en/latest/classes/class_callable.html) GDShell was born.


## What is GDShell?

GDShell is a feature-packed linux-like in-game console for development, debugging, cheats and/or any other interaction with your game.

It is inspired by [Bash](https://www.gnu.org/software/bash/) and it imitates it's syntax. Any Linux user will be instantly familiar with it.


## Commands as files and why does GDShell work this way

If you ever used any other Godot console, you are most likely familiar with it's command structure.
You have a console script and in that script you have an array of `Callables` that you have to write to, or you register the commands trough a function.

Often you can pass along function as a command and the return value of that function is the command result that gets printed.
That works and is really simple, but what if you want to run a command in background?
What if you want to run the command every frame as to log the FPS?
What if you want the command to respond to the user input at runtime without freezing your project?

Because every GDShell command is in it's own file and extends the [`GDShellCommand`](https://github.com/Kubulambula/Godot-GDShell/blob/main/addons/gdshell/docs/en/references/gdshell_command.md) class, 
it can be instanced on it's own as a Node and be managed in parallel with other commands.

This approach also makes the GDShell commands more organized, resulting in a clean file structure, that is easy to follow and refactor.


## So how do I use it?
Continue by reading on the [Step by step](https://github.com/Kubulambula/Godot-GDShell/blob/main/addons/gdshell/docs/en/getting_started/step_by_step.md) page.
