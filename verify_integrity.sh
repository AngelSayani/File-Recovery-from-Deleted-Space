#!/bin/bash

# File Recovery Integrity Verification Script
# This script verifies the integrity of recovered files against known good hashes

echo "==================================="
echo "File Integrity Verification Script"
echo "==================================="

RECOVERED_DIR="./recovered_files"
HASH_FILE="./known_hashes.txt"
REPORT_FILE="./analysis/integrity_report.txt"

# Create analysis directory if it doesn't exist
mkdir -p ./analysis

# Initialize report
echo "Integrity Verification Report" > $REPORT_FILE
echo "Generated: $(date)" >> $REPORT_FILE
echo "===================================" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# Function to calculate hash
calculate_hash() {
    local file=$1
    local hash_type=$2
    
    if [ "$hash_type" == "MD5" ]; then
        md5sum "$file" | cut -d' ' -f1
    elif [ "$hash_type" == "SHA256" ]; then
        sha256sum "$file" | cut -d' ' -f1
    fi
}

# Read known hashes and verify
echo "Starting integrity verification..."
echo ""

while IFS=':' read -r hash_type known_hash filename; do
    # Skip comments and empty lines
    [[ "$hash_type" =~ ^#.*$ ]] && continue
    [[ -z "$hash_type" ]] && continue
    
    filepath="$RECOVERED_DIR/$filename"
    
    echo "Checking: $filename"
    echo "File: $filename" >> $REPORT_FILE
    
    if [ -f "$filepath" ]; then
        calculated_hash=$(calculate_hash "$filepath" "$hash_type")
        echo "  Expected $hash_type: $known_hash" >> $REPORT_FILE
        echo "  Calculated $hash_type: $calculated_hash" >> $REPORT_FILE
        
        if [ "$calculated_hash" == "$known_hash" ]; then
            echo "  ✓ MATCH - File integrity verified" | tee -a $REPORT_FILE
        else
            echo "  ✗ MISMATCH - File may be corrupted or tampered" | tee -a $REPORT_FILE
        fi
    else
        echo "  ✗ FILE NOT FOUND in recovered files" | tee -a $REPORT_FILE
    fi
    
    echo "" >> $REPORT_FILE
done < "$HASH_FILE"

echo ""
echo "Verification complete. Report saved to: $REPORT_FILE"
