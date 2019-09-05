#!/bin/sh

function boldtext() { # bold text
    echo "\\[\\033[1m\\]"
}
function bgcolor() { # background color
    echo "\\[\\033[48;5;"$1"m\\]"
}
function defbgcolor() { # default background color
    echo "\\[\\033[49m\\]"
}
function fgcolor() { # foreground color
    echo "\\[\\033[38;5;"$1"m\\]"
}
function reverse() { # reverse foreground color and background color
    echo "\\[\\033[7m\\]"
}
function rscolor() { # reset color
    echo "\\[\\033[0m\\]"
}

. /mingw64/share/git/completion/git-completion.bash
. /mingw64/share/git/completion/git-prompt.sh

set_prompt() {
    local git_info="$(__git_ps1 %s)"
    if [ -z ${git_info} ]; then
        PS1="$(fgcolor 251)$(bgcolor 24) \w $(fgcolor 24)$(defbgcolor)$(rscolor) "
    else
        PS1="$(fgcolor 251)$(bgcolor 24) \w $(fgcolor 24)$(bgcolor 228)$(fgcolor 24)$(bgcolor 228)$(boldtext) ${git_info} $(fgcolor 228)$(defbgcolor)$(rscolor) "
    fi
}
PROMPT_COMMAND=set_prompt
MSYS2_PS1="$PS1"

if [ -e $HOME/.ls_colors ]; then
    eval $( dircolors -b $HOME/.ls_colors )
fi

