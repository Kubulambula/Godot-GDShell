<a href="https://github.com/Kubulambula/Godot-GDShell">
  <img src="https://github.com/Kubulambula/Godot-GDShell/blob/main/addons/gdshell/docs/assets/logo.png" align="left" width="80" height="80">
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


## Pipe


## OR


## AND


## Not
