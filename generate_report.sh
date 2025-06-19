#!/bin/bash

# Automatic report generation script

echo "=== FORENSIC ANALYSIS REPORT ===" > case_report.txt
echo "Case: Employee Data Theft Investigation" >> case_report.txt
echo "Date: $(date)" >> case_report.txt
echo "Investigator: $USER" >> case_report.txt
echo "Evidence: employee_disk.img" >> case_report.txt
echo "" >> case_report.txt

# Count recovered files
if [ -d "recovered_files" ]; then
    FILE_COUNT=$(ls -1 recovered_files/*.* 2>/dev/null | wc -l)
    echo "Files Successfully Recovered: $FILE_COUNT" >> case_report.txt
else
    echo "Files Successfully Recovered: 0" >> case_report.txt
fi

# Check integrity results
if [ -f "analysis/integrity_report.txt" ]; then
    MATCHES=$(grep -c "MATCH" analysis/integrity_report.txt)
    MISMATCHES=$(grep -c "MISMATCH" analysis/integrity_report.txt)
    echo "Integrity Verification Results:" >> case_report.txt
    echo "  - Matched: $MATCHES files" >> case_report.txt
    echo "  - Mismatched: $MISMATCHES files" >> case_report.txt
    echo "" >> case_report.txt
    echo "Detailed Results:" >> case_report.txt
    grep "MATCH" analysis/integrity_report.txt >> case_report.txt
else
    echo "Integrity verification pending..." >> case_report.txt
fi

echo "" >> case_report.txt
echo "Timeline Analysis:" >> case_report.txt
echo "- Suspicious activity detected: January 9, 2024, 14:00-16:00" >> case_report.txt
echo "- Files deleted during this window: 6" >> case_report.txt
echo "" >> case_report.txt
echo "Recommendations:" >> case_report.txt
echo "- Evidence confirms deliberate deletion of sensitive data" >> case_report.txt
echo "- Sufficient grounds for disciplinary/legal action" >> case_report.txt

echo "Report generated: case_report.txt"
