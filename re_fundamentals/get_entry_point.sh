#!/bin/bash

source ./messages.sh

# Check arguments
if [ $# -eq 0 ]; then
    echo "Error: No file specified"
    echo "Usage: $0 <elf_file>"
    exit 1
fi

file_name="$1"

# Check if file exists
if [ ! -f "$file_name" ]; then
    echo "Error: File '$file_name' does not exist"
    exit 1
fi

# Check if it's an ELF file using file command
file_type=$(file -b "$file_name")
if [[ ! "$file_type" =~ "ELF" ]]; then
    echo "Error: File '$file_name' is not a valid ELF file"
    exit 1
fi

# Extract Magic Number (first 4 bytes)
magic_number=$(xxd -l 4 -p "$file_name" | sed 's/../0x& /g' | tr 'a-z' 'A-Z')

# Extract Class using readelf
class=$(readelf -h "$file_name" 2>/dev/null | grep "Class:" | awk '{print $2}')

# Extract Byte Order
byte_order=$(readelf -h "$file_name" 2>/dev/null | grep "Data:" | sed 's/.*, //' | sed 's/ .*//')

# Extract Entry Point Address
entry_point_address=$(readelf -h "$file_name" 2>/dev/null | grep "Entry point address:" | awk '{print $4}')

# Call display function
display_elf_header_info
