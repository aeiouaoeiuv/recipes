#!/bin/bash

# Function to display usage information
display_usage() {
    echo "Usage: $0 bank_group_pin"
    echo "Example: $0 gpio1_b4"
    echo "Arguments:"
    echo "  bank: GPIO bank number"
    echo "  group: GPIO group (A-Z)"
    echo "  pin: GPIO pin number"
}

# Function to calculate GPIO formula
calculate_gpio() {
    local input="$1"
    input=$(echo "$input" | tr '[:lower:]' '[:upper:]')  # Convert to uppercase

    local bank="${input:4:1}"  # Extracting bank from argument
    local group="${input:6:1}"  # Extracting group from argument
    local pin="${input:7}"      # Extracting pin from argument

    local bank_val=$((bank * 32))
    local group_val=$(( ( $(printf '%d' "'$group") - $(printf '%d' "'A") ) * 8 ))
    local pin_val=$pin

    local result=$((bank_val + group_val + pin_val))
    echo "Result: $result"
}

# Main script
if [[ $# -eq 0 || "$1" == "-h" || "$1" == "--help" ]]; then
    display_usage
    exit 0
fi

if [[ $# -ne 1 ]]; then
    echo "Error: Incorrect number of arguments!"
    display_usage
    exit 1
fi

calculate_gpio "$1"

