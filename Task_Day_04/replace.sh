#!/bin/bash

echo "
This script will replace
from the 5th line
only on lines where 'Welcome' is present
"

if [ -z "$1" ]; then
    filename="sampletext.txt"
    echo "No file provided. Using default: $filename"
else
    filename=$1
fi

if [ ! -f "$filename" ]; then
    echo "ERROR: File '$filename' does not exist."
    exit 1
fi

read -p "Find (Default: give) : " input
read -p "Replace (Default: learning) : " output

if [ -z "$input" ]; then
        input="give"
fi

if [ -z "$output" ]; then
        output="learning"
fi

echo -e "\nFile Name : $filename \nFinding : $input  \nReplacing : $output";

echo "--------------------------------------------------------------------------"

tail -n +5 "$filename" | grep -i "welcome" | sed "s/$input/$output/gI"

echo "--------------------------------------------------------------------------"

read -n 1 -p "Are we good to replace these lines permanently? [y/n]: " cnfrm
echo""
if [ "$cnfrm" == "y" ] || [ "$cnfrm" == "Y" ]; then
    sed -i "5,$ { /welcome/I s/$input/$output/gI }" "$filename"
    echo "SUCCESS: Changes saved to $filename."
else
    echo "ABORTED: No changes were made to the file."
fi
