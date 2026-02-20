#!/bin/bash

# Function to check if the number is odd or even
function check_odd_even {
    if (( $1 % 2 == 0 )); then
        echo "$1 is Even."
    else
        echo "$1 is Odd."
    fi
}

# Main script
read -p "Enter a number: " number
check_odd_even $number

