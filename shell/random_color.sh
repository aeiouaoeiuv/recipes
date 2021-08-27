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

print_usage() {
    printf "usage: %s [OPTION] [VALUE]
Options:
    --rgb               text displayed in rgb
    --hex               text displayed in hex(default in hex)
    --count N           display N times colors(N >= 0, default 8)
    -h|--help           this help

Examples:
    1: %s --rgb
    2: %s --hex
    3: %s --rgb --count 3
" "$0" "$0" "$0" "$0"

}

main() {
    local target="$1"
    local count="$2"

    for i in $(seq "$count"); do
        read -r text_bg text_fg < <(generate_color_pair)

        if [ "$target" == "rgb" ]; then
            echo ""
            echo "$i: $(fgcolor "${text_bg}")$(defbgcolor)$(reverse)$(rscolor)$(bgcolor "${text_bg}")$(fgcolor "${text_fg}") fg_rgb: ${text_fg} bg_rgb: ${text_bg} $(fgcolor "${text_bg}")$(defbgcolor)$(rscolor)"
        else
            IFS=';' read -ra bg_rgb_arr <<< "$text_bg"
            IFS=';' read -ra fg_rgb_arr <<< "$text_fg"
            echo ""
            printf "$i: $(fgcolor "${text_bg}")$(defbgcolor)$(reverse)$(rscolor)$(bgcolor "${text_bg}")$(fgcolor "${text_fg}") fg_hex: #%02x%02x%02x bg_hex: #%02x%02x%02x $(fgcolor "${text_bg}")$(defbgcolor)$(rscolor)\n" \
                "${fg_rgb_arr[0]}" "${fg_rgb_arr[1]}" "${fg_rgb_arr[2]}" \
                "${bg_rgb_arr[0]}" "${bg_rgb_arr[1]}" "${bg_rgb_arr[2]}"
        fi
    done
    echo ""
}

g_target="hex"
g_count="8"

if ! ARGS=$(getopt -a -o lh -l list,rgb,hex,count:,help -- "$@"); then
    print_usage
fi
eval set -- "${ARGS}"
while true; do
    case "$1" in
    --hex)
        g_target="hex"
        shift
        ;;
    --rgb)
        g_target="rgb"
        shift
        ;;
    --count)
        g_count="$2"
        shift 2
        ;;
    -h|--help)
        print_usage
        exit 0
        ;;
    --)
        shift
        break
        ;;
    *)
        echo "Internal error"
        exit 1
        ;;
    esac
done

main "$g_target" "$g_count"

