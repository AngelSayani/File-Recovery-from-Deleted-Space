#!/bin/bash

# Script to create a  disk image for the forensics lab
# This creates a small FAT32 image with deleted files

echo "Creating forensic disk image..."

# Create a 100MB disk image
dd if=/dev/zero of=employee_disk.img bs=1M count=100

# Create FAT32 filesystem
mkfs.fat -F 32 employee_disk.img

# Mount the image
mkdir -p /tmp/forensics_mount
sudo mount -o loop employee_disk.img /tmp/forensics_mount

# Create some files
echo "Q4 2023 Financial Report - Confidential" > /tmp/forensics_mount/financial_report_q4_2023.xlsx
echo "Customer ID,Name,Email,Phone" > /tmp/forensics_mount/customer_database_export.csv
echo "customer1,John Doe,john@example.com,555-0101" >> /tmp/forensics_mount/customer_database_export.csv
echo "Project Alpha Documentation" > /tmp/forensics_mount/project_alpha_docs.zip
echo "Email Archive 2023" > /tmp/forensics_mount/email_archive_2023.pst
echo "Salary Information - Confidential" > /tmp/forensics_mount/salary_information.pdf
echo "Contracts 2023" > /tmp/forensics_mount/contracts_2023.docx

# Create some decoy files
echo "Meeting notes" > /tmp/forensics_mount/notes.txt
echo "Todo list" > /tmp/forensics_mount/todo.txt

# Sync and wait
sync
sleep 2

# Delete the sensitive files (this simulates the employee's actions)
rm /tmp/forensics_mount/financial_report_q4_2023.xlsx
rm /tmp/forensics_mount/customer_database_export.csv
rm /tmp/forensics_mount/project_alpha_docs.zip
rm /tmp/forensics_mount/email_archive_2023.pst
rm /tmp/forensics_mount/salary_information.pdf
rm /tmp/forensics_mount/contracts_2023.docx

# Unmount
sudo umount /tmp/forensics_mount
rmdir /tmp/forensics_mount

# Calculate hashes of the image
echo "Calculating image hashes..."
md5sum employee_disk.img > image_hashes.txt
sha256sum employee_disk.img >> image_hashes.txt

# Compress the image
zip disk_image.zip employee_disk.img

echo "Sample disk image created: disk_image.zip"
