# Migrate RootFS to SSD

This script migrates your current root filesystem (`/`) from internal storage (eMMC) to an SSD partition. It mounts the SSD partition, duplicates the filesystem using `rsync` (while excluding dynamic directories), and updates the boot configuration (`extlinux.conf`) so that the system boots from the SSD.

---

## Author

**Rajesh Roy**  
Email: [rajeshroy402@gmail.com](mailto:rajeshroy402@gmail.com)

---

## Overview

Migrating your root filesystem to an SSD can improve boot times and overall performance. This script performs the following actions:

- **Checks prerequisites:** Ensures the script is run as root, the SSD partition exists, and is not already mounted.
- **Mounts the SSD:** Temporarily mounts the SSD partition at `/mnt`.
- **Copies the filesystem:** Uses `rsync` to copy the root filesystem while excluding directories that are recreated at boot (e.g., `/proc`, `/dev`, etc.).
- **Updates boot configuration:** Edits the `extlinux.conf` file to change the `root=` parameter to point to the SSD.

---

## Prerequisites

- **Root Access:**  
  The script must be executed with root privileges (using `sudo`).

- **SSD Partition:**  
  Make sure your SSD partition exists (default is `/dev/nvme0n1p1`).  
  - **If the partition is unformatted:**  
    Create a filesystem (e.g., ext4) with:
    ```
    sudo mkfs.ext4 /dev/nvme0n1p1
    ```
  - **To verify if formatted:**
    ```
    sudo blkid /dev/nvme0n1p1
    lsblk -f
    sudo file -s /dev/nvme0n1p1
    ```

- **Backup Your Data:**  
  **WARNING:** This process will mirror your current root filesystem. Please ensure you have an up-to-date backup of any critical data.

---

## How to Use

1. **Download the Script:**

   Save the following script as `migrate-rootfs-to-ssd.sh` on your system.

2. **Make the Script Executable:**

   ```
   sudo chmod a+x migrate-rootfs-to-ssd.sh
Review & Configure:

Verify the SSD_DEVICE variable is correct (default is /dev/nvme0n1p1).
Adjust the UPDATE_MOUNTED_EXTLINUX flag if needed.
Run the Script:

Execute the script with:

``` sudo ./migrate-rootfs-to-ssd.sh ```

The script will:

Mount the SSD partition at /mnt.
Copy your root filesystem (/) to the mounted SSD using rsync.
Update extlinux.conf so that the system boots from the SSD.
Reboot Your System:

After the script finishes, reboot:

```
sudo reboot
```
Your system should now boot from the SSD. If issues occur, you may need to adjust the boot configuration.

Troubleshooting
SSD Already Mounted:
If you see an error stating that the SSD is already mounted, unmount it with:

```
sudo umount /dev/nvme0n1p1
```
Then re-run the script.

Partition Not Formatted:
If the SSD partition is unformatted, create a filesystem as described above.

Boot Configuration Issues:
If the extlinux.conf update does not work as expected, verify that the sed commands are correctly escaping the device paths.
