#!/bin/bash

# Script to create the forensic disk image with deleted files
echo "Creating forensic disk image for lab..."

# Create a 100MB disk image
dd if=/dev/zero of=employee_disk.img bs=1M count=100 status=progress

# Option 1: Create WITHOUT partition table (simpler for TSK tools)
# Just create FAT32 filesystem directly
mkfs.vfat -F 32 -n EVIDENCE employee_disk.img

# Mount the image
mkdir -p /tmp/forensics_mount
sudo mount -o loop employee_disk.img /tmp/forensics_mount

# Create files with real content
echo "Creating evidence files..."

# Financial report
sudo bash -c 'echo "CONFIDENTIAL - Q4 2023 Financial Report" > /tmp/forensics_mount/financial_report_q4_2023.xlsx'
sudo bash -c 'cat financial_report_q4_2023.txt >> /tmp/forensics_mount/financial_report_q4_2023.xlsx'

# CSV 
sudo cp customer_database_export.csv /tmp/forensics_mount/

# Other files
sudo bash -c 'echo "PROJECT ALPHA DOCUMENTATION" > /tmp/forensics_mount/project_alpha_docs.zip'
sudo bash -c 'cat project_alpha_docs.txt >> /tmp/forensics_mount/project_alpha_docs.zip'

sudo bash -c 'echo "EMAIL ARCHIVE 2023" > /tmp/forensics_mount/email_archive_2023.pst'
sudo bash -c 'cat email_archive_metadata.txt >> /tmp/forensics_mount/email_archive_2023.pst'

sudo bash -c 'echo "SALARY INFORMATION" > /tmp/forensics_mount/salary_information.pdf'
sudo bash -c 'cat salary_information.txt >> /tmp/forensics_mount/salary_information.pdf'

sudo bash -c 'echo "CONTRACTS 2023" > /tmp/forensics_mount/contracts_2023.docx'
sudo bash -c 'cat contracts_2023.txt >> /tmp/forensics_mount/contracts_2023.docx'

# Regular files
sudo cp notes.txt todo.txt lunch_menu.txt /tmp/forensics_mount/

# Create slack space data
sudo bash -c 'echo "CompanyPassword123" > /tmp/forensics_mount/.passwords.tmp'
sudo bash -c 'echo "CONFIDENTIAL - Do not distribute" >> /tmp/forensics_mount/.passwords.tmp'
sudo bash -c 'echo "DELETE ALL FINANCIAL RECORDS" >> /tmp/forensics_mount/.passwords.tmp'
sudo bash -c 'echo "admin:password123" >> /tmp/forensics_mount/.passwords.tmp'
sudo bash -c 'echo "root:topsecret456" >> /tmp/forensics_mount/.passwords.tmp'

# Fill some space and delete to create slack
sudo dd if=/dev/urandom of=/tmp/forensics_mount/.bigfile bs=1K count=500 2>/dev/null
sudo rm /tmp/forensics_mount/.bigfile
sudo rm /tmp/forensics_mount/.passwords.tmp

# Calculate hashes before deletion
echo "# Known file hashes for integrity verification" > known_hashes.txt
echo "# Format: HASH_TYPE:HASH_VALUE:FILENAME" >> known_hashes.txt
echo "" >> known_hashes.txt

for file in financial_report_q4_2023.xlsx customer_database_export.csv project_alpha_docs.zip email_archive_2023.pst salary_information.pdf contracts_2023.docx; do
    if [ -f "/tmp/forensics_mount/$file" ]; then
        md5hash=$(sudo md5sum "/tmp/forensics_mount/$file" | cut -d' ' -f1)
        sha256hash=$(sudo sha256sum "/tmp/forensics_mount/$file" | cut -d' ' -f1)
        echo "MD5:$md5hash:$file" >> known_hashes.txt
        echo "SHA256:$sha256hash:$file" >> known_hashes.txt
    fi
done

# Sync
sync

# Delete sensitive files
echo "Simulating file deletion..."
sudo rm /tmp/forensics_mount/financial_report_q4_2023.xlsx
sudo rm /tmp/forensics_mount/customer_database_export.csv  
sudo rm /tmp/forensics_mount/project_alpha_docs.zip
sudo rm /tmp/forensics_mount/email_archive_2023.pst
sudo rm /tmp/forensics_mount/salary_information.pdf
sudo rm /tmp/forensics_mount/contracts_2023.docx

# Final sync and unmount
sync
sudo umount /tmp/forensics_mount
rmdir /tmp/forensics_mount

# Calculate and save the actual hashes
ACTUAL_MD5=$(md5sum employee_disk.img | cut -d' ' -f1)
ACTUAL_SHA256=$(sha256sum employee_disk.img | cut -d' ' -f1)

# Create a proper case_notes.txt with actual hashes
cat > case_notes.txt << EOF
CASE: Employee Data Theft Investigation
DATE: 2024-01-15
INVESTIGATOR: Digital Forensics Team

INCIDENT SUMMARY:
Employee John Smith (ID: JS-4521) left the company on January 10, 2024.
IT Security noticed unusual deletion activity on his workstation on January 9, 2024.
Multiple sensitive files were reportedly deleted between 14:00-16:00 hours.

EVIDENCE COLLECTED:
- Disk image created: January 11, 2024 09:00 AM
- Image file: employee_disk.img
- Image hash (MD5): $ACTUAL_MD5
- Image hash (SHA256): $ACTUAL_SHA256

SUSPECTED FILES DELETED:
- Financial reports (Q4 2023)
- Customer database exports
- Project documentation
- Email archives

INVESTIGATION OBJECTIVES:
1. Recover deleted files from the disk image
2. Verify integrity of recovered data
3. Create timeline of deletion activities
4. Document all findings for legal proceedings
EOF

echo "Disk image created successfully!"
echo "MD5: $ACTUAL_MD5"
echo "SHA256: $ACTUAL_SHA256"
