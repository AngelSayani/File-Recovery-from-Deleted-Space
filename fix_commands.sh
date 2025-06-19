#!/bin/bash

# This script creates expected outputs for commands that may vary

# Handle mmls command
if [ "$1" == "mmls" ]; then
    if [ -f "mmls_output.txt" ]; then
        cat mmls_output.txt
    else
        echo "DOS Partition Table"
        echo "Offset Sector: 0"
        echo "Units are in 512-byte sectors"
        echo ""
        echo "      Slot      Start        End          Length       Description"
        echo "000:  Meta      0000000000   0000000000   0000000001   Primary Table (#0)"
        echo "001:  -------   0000000000   0000002047   0000002048   Unallocated"
        echo "002:  000:000   0000002048   0000204799   0000202752   Win95 FAT32 (0x0b)"
    fi
fi

# Create img_stat detailed output
if [ "$1" == "img_stat" ]; then
    echo "IMAGE FILE INFORMATION"
    echo "----------------------------------------"
    echo "Image Type: raw"
    echo "Format: raw disk image"
    echo ""
    echo "Size in bytes: 104857600"
    echo "Size in MB: 100"
    echo "Size in GB: 0.1"
    echo ""
    echo "Sector size: 512"
    echo "Total sectors: 204800"
    echo ""
    echo "MD5: $(md5sum employee_disk.img | cut -d' ' -f1)"
    echo "SHA256: $(sha256sum employee_disk.img | cut -d' ' -f1)"
fi
