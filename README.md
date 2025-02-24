# Migrate RootFS to SSD

This script migrates your current root filesystem (`/`) from internal storage (eMMC) to an SSD partition. It mounts the SSD partition, duplicates the filesystem using `rsync` (while excluding dynamic directories), and updates the boot configuration (`extlinux.conf`) so that the system boots from the SSD.

---

## Author

**Rajesh Roy**  
Email: [rajeshroy402@gmail.com](mailto:rajeshroy402@gmail.com)

---

## Overview

Migrating your root filesystem to an SSD can improve boot times and overall performance. This script performs the following actions:

- **Checks prerequisites:** Ensures the script is run as root, that the SSD partition exists, and that it is not already mounted.
- **Mounts the SSD:** Temporarily mounts the SSD partition at `/mnt`.
- **Copies the filesystem:** Uses `rsync` to copy your `/` to `/mnt`, while excluding directories that are dynamically generated (e.g., `/proc`, `/dev`, etc.).
- **Updates boot configuration:** Modifies `extlinux.conf` to change the `root=` parameter so that your system boots from the SSD.

---

## Prerequisites

- **Root Access:**  
  You must run this script with root privileges (using `sudo`).

- **SSD Partition:**  
  Ensure that your SSD partition exists. By default, the script uses `/dev/nvme0n1p1`.  
  If the partition is unformatted, create a filesystem (e.g., ext4) with:
  ```bash
  sudo mkfs.ext4 /dev/nvme0n1p1
  ```
  To verify if the partition is formatted, use:
  ```bash
  sudo blkid /dev/nvme0n1p1
  lsblk -f
  sudo file -s /dev/nvme0n1p1
  ```

- **Backup Your Data:**  
  **WARNING:** This process will mirror your current root filesystem. Ensure you have an up-to-date backup of any critical data.

---

## How to Use

### 1. Download the Script

Save the following script as `migrate-rootfs-to-ssd.sh` on your system.

### 2. Make the Script Executable

```bash
sudo chmod a+x migrate-rootfs-to-ssd.sh
```

### 3. Review & Configure

- **Default Device:**  
  The script defaults to using `/dev/nvme0n1p1` as the SSD device.

- **Passing a Device Name:**  
  You can pass a different device name as an argument. For example, to use `/dev/sda1`, run:
  ```bash
  sudo ./migrate-rootfs-to-ssd.sh /dev/sda1
  ```

- **Update extlinux.conf Flag:**  
  Adjust the `UPDATE_MOUNTED_EXTLINUX` flag inside the script if you want to update the extlinux configuration on the mounted SSD directly.

### 4. Run the Script

Execute the script with:
```bash
sudo ./migrate-rootfs-to-ssd.sh [SSD_DEVICE]
```
Replace `[SSD_DEVICE]` with your target device (e.g., `/dev/sda1`). If no device is provided, it defaults to `/dev/nvme0n1p1`.

The script will:
- Mount the SSD partition at `/mnt`.
- Copy your root filesystem (`/`) to the mounted SSD using `rsync`.
- Update the `extlinux.conf` file to point to the new SSD.

### 5. Reboot Your System

After the script finishes, reboot with:
```bash
sudo reboot
```
Your system should now boot from the SSD. If you encounter any issues, review the boot configuration or verify that the SSD partition is correctly formatted.

---

## Troubleshooting

- **SSD Already Mounted:**  
  If you receive an error stating that the SSD is already mounted, unmount it with:
  ```bash
  sudo umount [SSD_DEVICE]
  ```
  Then re-run the script.

- **Partition Not Formatted:**  
  If the SSD partition is unformatted, format it as shown above.

- **Boot Configuration Issues:**  
  If the `extlinux.conf` update does not work as expected, double-check the device paths and the `sed` commands used for updating the file.

---

## License

This script is provided "as-is" without any warranty. You are free to modify and use it as needed.

---

## Contact

For any issues or suggestions, please reach out to Rajesh Roy at [rajeshroy402@gmail.com](mailto:rajeshroy402@gmail.com).


---

## License

MIT License

Copyright (c) 2025 Rajesh Roy

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
