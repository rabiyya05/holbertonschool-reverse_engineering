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

# Extract Magic Number (first 16 bytes) - without 0x prefix
# Try xxd first, if not available use od
if command -v xxd &> /dev/null; then
    magic_number=$(xxd -l 16 -p "$file_name" | sed 's/\(..\)/\1 /g' | sed 's/ $//' | tr 'a-z' 'A-Z')
else
    magic_number=$(od -An -tx1 -N16 "$file_name" | tr -d '\n' | sed 's/ //g' | sed 's/\(..\)/\1 /g' | sed 's/ $//' | tr 'a-z' 'A-Z')
fi

# Alternative: use readelf to get magic number (more reliable)
# Uncomment if the above doesn't work:
# magic_number=$(readelf -h "$file_name" 2>/dev/null | grep "Magic:" | sed 's/Magic://' | sed 's/^[ \t]*//')

# Extract Class using readelf
class=$(readelf -h "$file_name" 2>/dev/null | grep "Class:" | awk '{print $2}')

# Extract Byte Order and format as "little endian" or "big endian"
byte_order_raw=$(readelf -h "$file_name" 2>/dev/null | grep "Data:" | sed 's/.*, //' | sed 's/ .*//')
if [ "$byte_order_raw" = "little" ]; then
    byte_order="little endian"
elif [ "$byte_order_raw" = "big" ]; then
    byte_order="big endian"
else
    byte_order="$byte_order_raw"
fi

# Extract Entry Point Address
entry_point_address=$(readelf -h "$file_name" 2>/dev/null | grep "Entry point address:" | awk '{print $4}')

# Call display function
display_elf_header_info
