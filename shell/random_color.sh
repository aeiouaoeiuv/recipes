#!/bin/bash

calc_gray_level() {
    local r="${1}"
    local g="${2}"
    local b="${3}"
    # expand 10000 times to avoid too many float calculation
    local gray_level=$(((2990 * r + 5870 * g + 1140 * b) / 255 ))
    echo "${gray_level}"
}

generate_rgb() {
    local r
    local g
    local b
    r=$(shuf -i0-255 -n1)
    g=$(shuf -i0-255 -n1)
    b=$(shuf -i0-255 -n1)
    echo "${r} ${g} ${b}"
}

generate_color_pair() {
    local bg_r bg_g bg_b
    read -r bg_r bg_g bg_b < <(generate_rgb)
    local bg_color="${bg_r};${bg_g};${bg_b}"

    local bg_gray_level
    read -r bg_gray_level < <(calc_gray_level "${bg_r}" "${bg_g}" "${bg_b}")

    local fg_r fg_g fg_b
    local fg_gray_level
    local fg_color=""
    local gray_level_diff

    for i in {1..3}; do
        read -r fg_r fg_g fg_b < <(generate_rgb)
        read -r fg_gray_level < <(calc_gray_level "${fg_r}" "${fg_g}" "${fg_b}")

        gray_level_diff=$((bg_gray_level - fg_gray_level))
        if [ ${gray_level_diff} -ge 3000 ] || [ ${gray_level_diff} -le -3000 ]; then
            fg_color="${fg_r};${fg_g};${fg_b}"
            break
        fi
    done

    if [ -z "${fg_color}" ]; then
        if [ "${bg_gray_level}" -ge 5000 ]; then
            fg_color="0;0;0"
        else
            fg_color="255;255;255"
        fi
    fi

    echo "${bg_color} ${fg_color}"
}

bgcolor() { # background color
    echo -e "\033[48;2;${1}m"
}
fgcolor() { # foreground color
    echo -e "\033[38;2;${1}m"
}
defbgcolor() { # default background color
    echo -e "\033[49m"
}
reverse() { # reverse foreground color and background color
    echo -e "\033[7m"
}
rscolor() { # reset color
    echo -e "\033[0m"
}

for i in {1..10}; do
    read -r text_bg text_fg < <(generate_color_pair)

    #printf "$(fgcolor "${text_bg}")$(defbgcolor)$(reverse)$(rscolor)$(bgcolor "${text_bg}")$(fgcolor "${text_fg}") fg_rgb: ${text_fg} bg_rgb: ${text_bg} $(fgcolor "${text_bg}")$(defbgcolor)\n\n"

    IFS=';' read -ra bg_rgb_arr <<< "$text_bg"
    IFS=';' read -ra fg_rgb_arr <<< "$text_fg"
    printf "$(fgcolor "${text_bg}")$(defbgcolor)$(reverse)$(rscolor)$(bgcolor "${text_bg}")$(fgcolor "${text_fg}") fg_hex: #%02x%02x%02x bg_hex: #%02x%02x%02x $(fgcolor "${text_bg}")$(defbgcolor)\n\n" \
        "${fg_rgb_arr[0]}" "${fg_rgb_arr[1]}" "${fg_rgb_arr[2]}" \
        "${bg_rgb_arr[0]}" "${bg_rgb_arr[1]}" "${bg_rgb_arr[2]}"
done

