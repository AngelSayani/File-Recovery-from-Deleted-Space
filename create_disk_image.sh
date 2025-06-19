#!/bin/bash

# Script to create the forensic disk image with deleted files
echo "Creating forensic disk image for lab..."

# Create a 100MB disk image with proper partition table
dd if=/dev/zero of=employee_disk.img bs=1M count=100 status=progress

# Create DOS partition table with FAT32 partition
parted employee_disk.img --script -- mklabel msdos
parted employee_disk.img --script -- mkpart primary fat32 1MiB 100%

# Setup loop device
LOOP_DEVICE=$(sudo losetup -f --show -P employee_disk.img)

# Format the partition as FAT32
sudo mkfs.vfat -F 32 ${LOOP_DEVICE}p1

# Mount the partition
mkdir -p /tmp/forensics_mount
sudo mount ${LOOP_DEVICE}p1 /tmp/forensics_mount

# Create files with real content
echo "Creating evidence files..."

# Financial report with Excel-like content
sudo bash -c 'cat > /tmp/forensics_mount/financial_report_q4_2023.xlsx << EOF
PK'$(echo -e '\003\004')$(cat financial_report_q4_2023.txt)
EOF'

# CSV is plain text
sudo cp customer_database_export.csv /tmp/forensics_mount/

# ZIP file
sudo bash -c 'echo -e "PK\003\004" > /tmp/forensics_mount/project_alpha_docs.zip'
sudo bash -c 'cat project_alpha_docs.txt >> /tmp/forensics_mount/project_alpha_docs.zip'

# PST file
sudo bash -c 'echo "!BDN" > /tmp/forensics_mount/email_archive_2023.pst'
sudo bash -c 'cat email_archive_metadata.txt >> /tmp/forensics_mount/email_archive_2023.pst'

# PDF file
sudo bash -c 'echo "%PDF-1.4" > /tmp/forensics_mount/salary_information.pdf'
sudo bash -c 'cat salary_information.txt >> /tmp/forensics_mount/salary_information.pdf'

# DOCX file
sudo bash -c 'echo -e "PK\003\004" > /tmp/forensics_mount/contracts_2023.docx'
sudo bash -c 'cat contracts_2023.txt >> /tmp/forensics_mount/contracts_2023.docx'

# Regular files
sudo cp notes.txt todo.txt lunch_menu.txt /tmp/forensics_mount/

# Create files with sensitive data that will remain in slack space
sudo bash -c 'echo "CompanyPassword123" > /tmp/forensics_mount/.passwords.tmp'
sudo bash -c 'echo "CONFIDENTIAL - Do not distribute" >> /tmp/forensics_mount/.passwords.tmp'
sudo bash -c 'echo "DELETE ALL FINANCIAL RECORDS" >> /tmp/forensics_mount/.passwords.tmp'
sudo bash -c 'echo "admin:password123" >> /tmp/forensics_mount/.passwords.tmp'
sudo bash -c 'echo "root:topsecret456" >> /tmp/forensics_mount/.passwords.tmp'

# Write and delete to create slack space
sudo dd if=/dev/urandom of=/tmp/forensics_mount/.bigfile bs=1M count=5
sudo rm /tmp/forensics_mount/.bigfile
sudo rm /tmp/forensics_mount/.passwords.tmp

# Calculate hashes before deletion
echo "# Known file hashes for integrity verification" > known_hashes.txt
echo "# Format: HASH_TYPE:HASH_VALUE:FILENAME" >> known_hashes.txt
echo "" >> known_hashes.txt

for file in financial_report_q4_2023.xlsx customer_database_export.csv project_alpha_docs.zip email_archive_2023.pst salary_information.pdf contracts_2023.docx; do
    md5hash=$(sudo md5sum "/tmp/forensics_mount/$file" | cut -d' ' -f1)
    sha256hash=$(sudo sha256sum "/tmp/forensics_mount/$file" | cut -d' ' -f1)
    echo "MD5:$md5hash:$file" >> known_hashes.txt
    echo "SHA256:$sha256hash:$file" >> known_hashes.txt
done

# Sync before deletion
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
sudo losetup -d $LOOP_DEVICE
rmdir /tmp/forensics_mount

echo "Disk image created with partition table!"
