#!/bin/bash

# File Recovery Integrity Verification Script
echo "==================================="
echo "File Integrity Verification Script"
echo "==================================="

RECOVERED_DIR="./recovered_files"
HASH_FILE="./known_hashes.txt"
REPORT_FILE="./analysis/integrity_report.txt"

mkdir -p ./analysis

echo "Integrity Verification Report" > $REPORT_FILE
echo "Generated: $(date)" >> $REPORT_FILE
echo "===================================" >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "Starting integrity verification..."
echo ""

# Function to calculate hash
calculate_hash() {
    local file=$1
    local hash_type=$2
    
    if [ "$hash_type" == "MD5" ]; then
        md5sum "$file" 2>/dev/null | cut -d' ' -f1
    elif [ "$hash_type" == "SHA256" ]; then
        sha256sum "$file" 2>/dev/null | cut -d' ' -f1
    fi
}

# Check each file
while IFS=':' read -r hash_type known_hash filename; do
    [[ "$hash_type" =~ ^#.*$ ]] && continue
    [[ -z "$hash_type" ]] && continue
    
    # Try multiple locations
    for dir in "$RECOVERED_DIR" "./targeted_recovery" "."; do
        filepath="$dir/$filename"
        
        if [ -f "$filepath" ]; then
            echo "Checking: $filename"
            echo "File: $filename" >> $REPORT_FILE
            
            calculated_hash=$(calculate_hash "$filepath" "$hash_type")
            echo "  Expected $hash_type: $known_hash" >> $REPORT_FILE
            echo "  Calculated $hash_type: $calculated_hash" >> $REPORT_FILE
            
            if [ "$calculated_hash" == "$known_hash" ]; then
                echo "  ✓ MATCH - File integrity verified" | tee -a $REPORT_FILE
            else
                echo "  ✗ MISMATCH - File may be corrupted or tampered" | tee -a $REPORT_FILE
            fi
            echo "" >> $REPORT_FILE
            break
        fi
    done
done < "$HASH_FILE"

echo ""
echo "Verification complete. Report saved to: $REPORT_FILE"
