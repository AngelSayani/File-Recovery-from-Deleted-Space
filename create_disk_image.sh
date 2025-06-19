#!/bin/bash

# Script to create the forensic disk image with deleted files
# Run this after all files are ready

echo "Creating forensic disk image for lab..."

# Create a 100MB disk image
dd if=/dev/zero of=employee_disk.img bs=1M count=100 status=progress

# Create FAT32 filesystem directly (no partition table for simplicity)
mkfs.fat -F 32 -n EVIDENCE employee_disk.img

# Mount the image
mkdir -p /tmp/forensics_mount
sudo mount -o loop employee_disk.img /tmp/forensics_mount

# Create files with proper headers/signatures
echo "Creating files with proper signatures..."

# Excel file (XLSX has specific header)
echo -e "PK\x03\x04" > /tmp/forensics_mount/financial_report_q4_2023.xlsx
cat financial_report_q4_2023.txt >> /tmp/forensics_mount/financial_report_q4_2023.xlsx

# CSV is plain text - just copy
cp customer_database_export.csv /tmp/forensics_mount/customer_database_export.csv

# ZIP file needs PK header
echo -e "PK\x03\x04" > /tmp/forensics_mount/project_alpha_docs.zip
cat project_alpha_docs.txt >> /tmp/forensics_mount/project_alpha_docs.zip

# PST file (Outlook) - add header
echo -e "!BDN" > /tmp/forensics_mount/email_archive_2023.pst
cat email_archive_metadata.txt >> /tmp/forensics_mount/email_archive_2023.pst

# PDF needs PDF header
echo "%PDF-1.4" > /tmp/forensics_mount/salary_information.pdf
cat salary_information.txt >> /tmp/forensics_mount/salary_information.pdf

# DOCX is also ZIP-based
echo -e "PK\x03\x04" > /tmp/forensics_mount/contracts_2023.docx
cat contracts_2023.txt >> /tmp/forensics_mount/contracts_2023.docx

# Copy non-sensitive files
cp notes.txt /tmp/forensics_mount/notes.txt
cp todo.txt /tmp/forensics_mount/todo.txt
cp lunch_menu.txt /tmp/forensics_mount/lunch_menu.txt

# Add some additional data to make slack space more interesting
echo "CompanyPassword123" >> /tmp/forensics_mount/.temp_passwords
echo "CONFIDENTIAL - Do not distribute" >> /tmp/forensics_mount/.temp_notice
echo "DELETE ALL FINANCIAL RECORDS" >> /tmp/forensics_mount/.temp_commands
rm /tmp/forensics_mount/.temp*

# Calculate hashes BEFORE deletion
echo "# Known file hashes for integrity verification" > known_hashes.txt
echo "# Format: HASH_TYPE:HASH_VALUE:FILENAME" >> known_hashes.txt
echo "" >> known_hashes.txt

for file in financial_report_q4_2023.xlsx customer_database_export.csv project_alpha_docs.zip email_archive_2023.pst salary_information.pdf contracts_2023.docx; do
    if [ -f "/tmp/forensics_mount/$file" ]; then
        md5hash=$(md5sum "/tmp/forensics_mount/$file" | cut -d' ' -f1)
        sha256hash=$(sha256sum "/tmp/forensics_mount/$file" | cut -d' ' -f1)
        echo "MD5:$md5hash:$file" >> known_hashes.txt
        echo "SHA256:$sha256hash:$file" >> known_hashes.txt
    fi
done

# Wait for filesystem to sync
sync
sleep 2

# Now delete the sensitive files
echo "Simulating file deletion..."
rm /tmp/forensics_mount/financial_report_q4_2023.xlsx
rm /tmp/forensics_mount/customer_database_export.csv
rm /tmp/forensics_mount/project_alpha_docs.zip
rm /tmp/forensics_mount/email_archive_2023.pst
rm /tmp/forensics_mount/salary_information.pdf
rm /tmp/forensics_mount/contracts_2023.docx

# Unmount
sync
sudo umount /tmp/forensics_mount
rmdir /tmp/forensics_mount

echo "Disk image created successfully!"
