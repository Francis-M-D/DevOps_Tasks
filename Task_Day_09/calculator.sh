#!/bin/bash

# Function to display the menu
function display_menu {
    echo "Simple Calculator"
    echo "1. Addition"
    echo "2. Subtraction"
    echo "3. Multiplication"
    echo "4. Division"
    echo "5. Exit"
}

# Function to perform calculations
function calculate {
    case $1 in
        1) echo "$2 + $3" | bc ;;
        2) echo "$2 - $3" | bc ;;
        3) echo "$2 \* $3" | bc ;;
        4) echo "$2 / $3" | bc ;;
        *) echo "Invalid option" ;;
    esac
}

# Main script loop
while true; do
    display_menu
    read -p "Select an operation (1-5): " option

    if [[ "$option" -eq 5 ]]; then
        echo "Exiting..."
        break
    fi

    read -p "Enter first number: " num1
    read -p "Enter second number: " num2

    result=$(calculate "$option" "$num1" "$num2")
    echo "Result: $result"
    echo ""
done
