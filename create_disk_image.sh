#!/bin/bash

# Script to create the forensic disk image with deleted files
# Run this after all files are ready

echo "Creating forensic disk image for lab..."

# Create a 100MB disk image
dd if=/dev/zero of=employee_disk.img bs=1M count=100 status=progress

# Create FAT32 filesystem
mkfs.fat -F 32 -n EVIDENCE employee_disk.img

# Mount the image
mkdir -p /tmp/forensics_mount
sudo mount -o loop employee_disk.img /tmp/forensics_mount

# Copy files to the disk image
echo "Copying files to disk image..."
cp financial_report_q4_2023.txt /tmp/forensics_mount/financial_report_q4_2023.xlsx
cp customer_database_export.csv /tmp/forensics_mount/customer_database_export.csv
cp project_alpha_docs.txt /tmp/forensics_mount/project_alpha_docs.zip
cp email_archive_metadata.txt /tmp/forensics_mount/email_archive_2023.pst
cp salary_information.txt /tmp/forensics_mount/salary_information.pdf
cp contracts_2023.txt /tmp/forensics_mount/contracts_2023.docx

# Copy non-sensitive files
cp notes.txt /tmp/forensics_mount/notes.txt
cp todo.txt /tmp/forensics_mount/todo.txt
cp lunch_menu.txt /tmp/forensics_mount/lunch_menu.txt

# Wait for filesystem to sync
sync
sleep 2

# Now delete the sensitive files to simulate the incident
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
