<a href="https://github.com/Kubulambula/Godot-GDShell">
  <img src="../../../docs/assets/logo.png" align="left" width="80" height="80">
</a>

# GDShell syntax

GDShell breaks the input down into words and operators while respecting quotes and expands alliases.

This is inspired by [Bash](https://www.gnu.org/software/bash/) and it (very loosely) follows the parsing process.


## Quotes

Quotes are used to remove the special meaning of certain words and operators. Quotes can be used to disable special treatment for special characters, to prevent reserved words from being recognized, and to prevent parameter expansion.

GDShell supports both single `'` and double `"` quotes. Both can be used within the other freely, but the same quote type must be escaped.

```'This -> "\'" is excaped single quote '```<br>
```"This -> '\"' is excaped double quote "```

Quoted text will always be recognized as a single word. This can be used for long or multiline arguments and commands with names that contain spaces.
This word will be always escaped using the [`c_unescape()`](https://docs.godotengine.org/en/latest/classes/class_string.html#class-string-method-c-unescape) method.

```"command name with spaces" --argument```<br>
```echo "This a super long text with spaces and \nmultiple \nlines"```


## Sequence

Command can be separated and executed sequentially using the `;` operator.

The commands will always be executed in left-to-right order. If any previous command fails, it does not affect the execution of the next commands.

```
echo Hello ; echo World ; echo "!"

output:
Hello
World
!
```

## Background

Any command can be executed in background using the `&` operator. These commands are detached from the user input, but still can access output.
These commands are great for anything that is supposed to run for a longer period of time while still allowing you to use other commands.

Commands sent into background will return [`GDShellCommand.DEFAULT_COMMAND_RESULT`](../references/gdshell_command.md#dictionary-default_command_result) and another command can be run immediately. While the background command is still running.

The command ends after the [`_main()`](../references/gdshell_command.md#_main) returns giving you total control over its lifetime.

Commands can be sent into background using this syntax: `command_name &` or `command_name&`

For more information see [Backgroun commands](custom_commands.md#background-commands)


## Pipe

Any command can accept any other command's result data. This happens when you use the `|` operator. When using the pipe, the result data of the first command will be passed to the next command.

`command_1 | command_2` - result data of `command_1` will be passed to `command_2`

The command after the pipe is executed only after the first one ends and returns its result, but you want to be careful around background commands as they will always return [`GDShellCommand.DEFAULT_COMMAND_RESULT`](../references/gdshell_command.md#dictionary-default_command_result) before ending themself.

`gdfetch | echo` - outputs `gdfetch` graphics, passes the data to `echo` and echo prints the data<br>
`gdfetch& | echo` - outputs `gdfetch` graphics, but the returned data is null, so `echo` does not print anythig

For more information see [Command data](custom_commands.md#command-data)


## AND

The conditional AND (`&&`) operator is used for creating complex command chains.

`command_1 && command_2`

In the previous example the `command_2` is executed if, and only if the `command_1` returns error code `0`.
If the command returns anythig else, the `command_2` is not executed.

`true && echo "I executed!"` - outputs "I executed!"<br>
`false && echo "I executed!"` - outputs nothing. `echo` was not executed


## OR

The conditional OR (`||`) operator is the polar opposite to conditional AND (`&&`) with the same syntax.

`command_1 || command_2`

The only difference is, that the `command_2` in the example above is executed only if the `command_1` fails.

`false || echo "I executed!"` - outputs "I executed!"<br>
`true || echo "I executed!"` - outputs nothing. `echo` was not executed


## Not

The `!` operator can be used together with contitional (`&&` and `||`) operators to create more complex command chains.
The `!` operator simply changes the result error code while keeping the command result data, following this rule:
- If the error code is `0`, it gets changed to `1`
- If the error code is not `0`, it gets changed to `0`

You can use the operator like this: `!false && echo "I false was changed to \"true\""`
