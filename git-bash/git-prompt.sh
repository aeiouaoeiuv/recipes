#!/bin/bash
# vim:ft=zsh ts=4 sw=4 sts=4

. /mingw64/share/git/completion/git-completion.bash
. /mingw64/share/git/completion/git-prompt.sh

SEPARATER="" # Rightwards black arrowhead

function boldtext() { # bold text
	echo "\\[\\033[1m\\]"
}
function bgcolor() { # background color
	echo "\\[\\033[48;2;"$1"m\\]"
}
function defbgcolor() { # default background color
	echo "\\[\\033[49m\\]"
}
function fgcolor() { # foreground color
	echo "\\[\\033[38;2;"$1"m\\]"
}
function reverse() { # reverse foreground color and background color
	echo "\\[\\033[7m\\]"
}
function rscolor() { # reset color
	echo "\\[\\033[0m\\]"
}

prompt_status() {
	local -a txt
	local bg="40;121;162"
	local fg="243;211;89"
	local JOBS_CHAR="⚙"

	[[ ${RETVAL} -ne 0 ]] && txt+="${RETVAL}"
	[[ $(jobs -l | wc -l) -gt 0 ]] && {
		if [ -n "${txt}" ]; then
			txt+=" "
		fi
		txt+="${JOBS_CHAR}"
	}

	if [ -n "${txt}" ]; then
		LAST_FG="${fg}"
		LAST_BG="${bg}"
		PS1+="$(fgcolor ${fg})$(bgcolor ${bg}) ${txt} "
	fi
}

prompt_dir() {
	local bg="247;219;9"
	local fg="182;21;234"

	if [ -n "${LAST_BG}" -a -n "${LAST_FG}" ]; then
		PS1+="$(fgcolor ${LAST_BG})$(bgcolor ${LAST_FG})${SEPARATER}"
	fi

	local txt="\w"

	# check dir writable
	local LOCK_CHAR="" # Closed padlock
	if [ ! -w "$PWD" ]; then
		txt+=" ${LOCK_CHAR}"
	fi

	LAST_BG="${bg}"
	LAST_FG="${fg}"
	PS1+="$(fgcolor ${fg})$(bgcolor ${bg}) ${txt} "
}

prompt_git() {
	local GIT_CHAR="" # Version control branch
	local STASH_CHAR="◼"
	local STAGE_CHAR="✚"
	local UNSTAGE_CHAR="∗"
	local UNTRACK_CHAR="?"
	local bg="31;52;85"
	local fg="142;184;56"

	if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
		if [ -n "${LAST_BG}" -a -n "${LAST_FG}" ]; then
			PS1+="$(fgcolor ${LAST_BG})$(bgcolor ${bg})${SEPARATER}"
		fi

		local txt="${GIT_CHAR} $(__git_ps1 %s)"

		if ! $(git rev-parse --is-inside-git-dir); then
			# check stash list
			if [ $(git stash list | wc -l) -gt 0 ]; then
				txt+=" ${STASH_CHAR}"
			fi

			for i in {1}; do
				if [ "${AGNOSTER_RANDOM_GIT_STATUS}" -eq 0 ]; then
					break
				fi

				# check staged files
				$(git diff --no-ext-diff --quiet --cached)
				if [ $? -ne 0 ]; then
					txt+=" ${STAGE_CHAR}"
					break
				fi

				# check unstaged files
				$(git diff --no-ext-diff --quiet)
				if [ $? -ne 0 ]; then
					txt+=" ${UNSTAGE_CHAR}"
					break
				fi

				# check untracked files
				if [ ! -z "$(git status --porcelain)" ]; then
					txt+=" ${UNTRACK_CHAR}"
					break
				fi
			done
		fi

		LAST_BG="${bg}"
		LAST_FG="${fg}"
		PS1+="$(fgcolor ${fg})$(bgcolor ${bg}) ${txt} "
	fi
}

prompt_end() {
	if [ -n "${LAST_BG}" -a -n "${LAST_FG}" ]; then
		PS1+="$(fgcolor ${LAST_BG})$(defbgcolor)${SEPARATER}$(rscolor) "
	fi
}

build_prompt() {
	RETVAL=$?
	LAST_BG=""
	LAST_FG=""
	AGNOSTER_RANDOM_GIT_STATUS=1
	PS1=""
	prompt_status
	prompt_dir
	prompt_git
	prompt_end
}

PROMPT_COMMAND=build_prompt
MSYS2_PS1="$PS1"

if [ -e $HOME/.ls_colors ]; then
	eval $( dircolors -b $HOME/.ls_colors )
fi

