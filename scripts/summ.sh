#!/bin/bash

# Function to process each file
process_file() {
    local file="$1"
    local dir=$(dirname "$file")
    local filename=$(basename "$file")

    echo "## directory: $dir"
    echo "### file: $filename"
    echo "----------------------------------------------------------"
    cat "$file"
    echo -e "\n"
}

# Function to traverse the directory recursively
traverse_directory() {
    local dir="$1"

    # Loop through all files in the directory
    for file in "$dir"/*; do
        if [ -d "$file" ]; then
            # If it's a directory, recursively traverse it
            traverse_directory "$file"
        elif [ -f "$file" ]; then
            # If the file is a README.md file, skip it
            if [ "$(basename "$file")" == "README.md" ]; then
                continue
            fi
            # If it's a file, process it
            process_file "$file"
        fi
    done
}

# Get the directory path from the command line argument
dir_path="$1"

# Check if the directory exists
if [ -d "$dir_path" ]; then
    # Start traversing the directory recursively
    echo "##############################################################################"
    echo -e "\n"
    echo "# Tree structure of the directory: $dir_path"
    lsd --tree  "$dir_path"
    echo -e "\n"
    echo "##############################################################################"
    echo -e "\n"
    echo "# Contents of the files in the directory: $dir_path"
    echo -e "\n"
    echo "----------------------------------------------------------"
    echo -e "\n"
    traverse_directory "$dir_path"
else
    echo "Directory not found: $dir_path"
    exit 1
fi
