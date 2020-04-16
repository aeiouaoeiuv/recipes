# vim:ft=zsh ts=4 sw=4 sts=4

() {
	. ${HOME}/.git-prompt.sh

	# NOTE: This variable was used to control displaying git status info in prompt.
	# For a huge git repository, showing git status in prompt will be very slow,
	# especially in a shared folder in virtual machine.
	# Set to 0 to closing git status info in prompt.
	# Default is 1.
	AGNOSTER_RANDOM_GIT_STATUS=1

	local LC_ALL="" LC_CTYPE="en_US.UTF-8"
	# NOTE: This segment separator character is correct.  In 2012, Powerline changed
	# the code points they use for their special characters. This is the new code point.
	# If this is not working for you, you probably have an old version of the
	# Powerline-patched fonts installed. Download and install the new version.
	# Do not submit PRs to change this unless you have reviewed the Powerline code point
	# history and have new information.
	# This is defined using a Unicode escape sequence so it is unambiguously readable, regardless of
	# what font the user is viewing this source code in. Do not replace the
	# escape sequence with a single literal character.
	# Do not change this! Do not make it '\u2b80'; that is the old, wrong code point.
	SEGMENT_SEPARATOR=$'\ue0b0'

	# https://blog.walterlv.com/post/get-gray-reversed-color.html
	calc_gray_level() {
		local r=${1}
		local g=${2}
		local b=${3}
		# expand 10000 times to avoid too many float calculation
		local gray_level=$(((2990 * ${r} + 5870 * ${g} + 1140 * ${b}) / 255 ))
		echo "${gray_level}"
	}

	generate_rgb() {
		local r=$(shuf -i0-255 -n1)
		local g=$(shuf -i0-255 -n1)
		local b=$(shuf -i0-255 -n1)
		echo "${r} ${g} ${b}"
	}

	generate_color_pair() {
		local bg_r bg_g bg_b
		read bg_r bg_g bg_b < <(generate_rgb)
		local bg_color="${bg_r};${bg_g};${bg_b}"

		local bg_gray_level
		read bg_gray_level < <(calc_gray_level ${bg_r} ${bg_g} ${bg_b})

		local fg_r fg_g fg_b
		local fg_gray_level
		local fg_color=""
		local gray_level_diff

		for i in {1..3}; do
			read fg_r fg_g fg_b < <(generate_rgb)
			read fg_gray_level < <(calc_gray_level ${fg_r} ${fg_g} ${fg_b})

			gray_level_diff=$((${bg_gray_level} - ${fg_gray_level}))
			if [ ${gray_level_diff} -ge 3000 -o ${gray_level_diff} -le -3000 ]; then
				fg_color="${fg_r};${fg_g};${fg_b}"
				break
			fi
		done

		if [ -z ${fg_color} ]; then
			if [ ${bg_gray_level} -ge 5000 ]; then
				fg_color="0;0;0"
			else
				fg_color="255;255;255"
			fi
		fi

		echo "${bg_color} ${fg_color}"
	}

	# this place for shell script will be executed once
	read status_bg status_fg < <(generate_color_pair)
	read dir_bg dir_fg < <(generate_color_pair)
	read git_bg git_fg < <(generate_color_pair)
}

LAST_BG=""
LAST_FG=""

prompt_segment() {
	local bg="${1}"
	local fg="${2}"
	# color codes should be wrapped by %{..%} and normal text should not
	echo -n "%{\033[48;2;${bg}m%}%{\033[38;2;${fg}m%}${3}"
}

prompt_status() {
	local -a txt
	() {
		local LC_ALL="" LC_CTYPE="en_US.UTF-8"
		JOBS_CHAR=$'\u2699' # ⚙
	}

	[[ ${RETVAL} -ne 0 ]] && txt+=${RETVAL}
	[[ $(jobs -l | wc -l) -gt 0 ]] && txt+="${JOBS_CHAR}"

	if [ -n "${txt}" ]; then
		LAST_BG="${status_bg}"
		LAST_FG="${status_fg}"
		prompt_segment ${status_bg} ${status_fg} " ${txt} "
	fi
}

prompt_dir() {
	if [ -n "${LAST_BG}" -a -n "${LAST_FG}" ]; then
		prompt_segment ${dir_bg} ${LAST_BG} ${SEGMENT_SEPARATOR}
	fi
	() {
		local LC_ALL="" LC_CTYPE="en_US.UTF-8"
		LOCK_CHAR=$'\ue0a2' # 
	}

	local txt="%~" # prompt dir

	# check dir writable
	if [ ! -w "$PWD" ]; then
		txt+=" ${LOCK_CHAR}"
	fi

	LAST_BG="${dir_bg}"
	LAST_FG="${dir_fg}"
	prompt_segment ${dir_bg} ${dir_fg} " ${txt} "
}

prompt_git() {
	(( $+commands[git] )) || return
	if [[ "$(git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
		return
	fi
	() {
		local LC_ALL="" LC_CTYPE="en_US.UTF-8"
		GIT_CHAR=$'\ue0a0' # 
		STASH_CHAR=$'\u25fc' # ◼
		STAGE_CHAR=$'\u271a' # ✚
		UNSTAGE_CHAR=$'\u2217' # ∗
		UNTRACK_CHAR="?"
	}

    if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
		if [ -n "${LAST_BG}" -a -n "${LAST_FG}" ]; then
			prompt_segment ${git_bg} ${LAST_BG} ${SEGMENT_SEPARATOR}
		fi

		local txt="${GIT_CHAR} $(__git_ps1 %s)"

		if ! $(git rev-parse --is-inside-git-dir); then
			# check stash list
			$(git rev-parse --verify refs/stash >/dev/null 2>&1)
			if [ $? -eq 0 ]; then
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

		LAST_BG="${git_bg}"
		LAST_FG="${git_fg}"
		prompt_segment "${git_bg}m%}%{\033[1" ${git_fg} " ${txt} "
	fi
}

prompt_end() {
	if [ -n "${LAST_BG}" -a -n "${LAST_FG}" ]; then
		# color codes should be wrapped by %{..%} and normal text should not
		echo -n "%{${reset_color}%}%{\033[38;2;${LAST_BG}m%}${SEGMENT_SEPARATOR}%{${reset_color}%} "
	fi
}

build_prompt() {
	RETVAL=$?
	prompt_status
	prompt_dir
	prompt_git
	prompt_end
}

# http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Prompt-Expansion or "man zshmisc"
PROMPT='%{%f%b%k%}$(build_prompt)'

