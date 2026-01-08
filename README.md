# VHDX Mount Tool for Linux

A simple, user-friendly tool to mount and visualize VHDX (Virtual Hard Disk) files on Linux with just a click!

## Features

- **One-Click Mounting**: Double-click or right-click .vhdx files in your file manager to mount them
- **GUI Integration**: Works seamlessly with your Linux desktop environment (GNOME, KDE, XFCE, etc.)
- **Automatic Detection**: Automatically detects and mounts partitions within VHDX files
- **NTFS Support**: Full support for NTFS filesystems commonly found in Windows VHDX files
- **Visual Notifications**: Desktop notifications for mount/unmount operations
- **Multiple File Managers**: Support for Nautilus, Dolphin, Thunar, and more
- **Easy Management**: List and unmount VHDX files with simple commands
- **🔓 Passwordless Option**: Optional automatic mounting without password prompts!

## 🚀 Fully Automatic Mounting (Recommended!)

For the best experience, enable **passwordless mounting** so you can just double-click a .vhdx file and it opens automatically without any password prompts!

### Enable Automatic Mounting

During installation, choose **Yes** when asked about passwordless mounting, or run:

```bash
./setup-passwordless.sh
```

This configures secure, passwordless sudo only for VHDX mounting operations. Once enabled:

1. **Double-click any .vhdx file** → It mounts and opens automatically!
2. **No password prompts** → Seamless experience
3. **Still secure** → Only specific mount commands are allowed without password

**This is completely safe** because it only allows mounting VHDX files, not general sudo access.

## Requirements

- Linux system with a GUI desktop environment
- qemu-utils (provides qemu-nbd)
- ntfs-3g (for NTFS filesystem support)
- zenity or kdialog (for GUI dialogs)
- sudo privileges (for mounting operations)

## Installation

### Quick Install

```bash
git clone <repository-url>
cd mount_vhdx_interactive
chmod +x install.sh
./install.sh
```

The installer will:
1. Check and install required dependencies
2. Install mount/unmount scripts
3. Register the VHDX MIME type
4. Set up file associations
5. Add context menu entries to your file manager
6. **Offer to setup passwordless mounting** (recommended for automatic operation)

### Manual Installation

If you prefer to install manually:

```bash
# Install dependencies (Debian/Ubuntu)
sudo apt install qemu-utils zenity ntfs-3g

# Install dependencies (Fedora)
sudo dnf install qemu-img zenity ntfs-3g

# Install dependencies (Arch)
sudo pacman -S qemu zenity ntfs-3g

# Run the installation script
./install.sh
```

## Usage

### Method 1: Double-Click (Easiest!)

1. Navigate to your .vhdx file in your file manager (Nautilus, Dolphin, etc.)
2. Double-click the .vhdx file
3. **With passwordless setup**: File opens automatically! 🎉
4. **Without passwordless setup**: Enter your sudo password when prompted
5. The file manager will automatically open showing the mounted contents

### Method 2: Right-Click Context Menu

1. Right-click on a .vhdx file in your file manager
2. Select "Mount VHDX" from the context menu
3. **With passwordless setup**: Mounts automatically! 🎉
4. **Without passwordless setup**: Enter your sudo password when prompted
5. The contents will be mounted and displayed

### Method 3: Command Line

Mount a VHDX file:
```bash
mount-vhdx.sh /path/to/your/file.vhdx
```

Unmount a VHDX file:
```bash
unmount-vhdx.sh /path/to/your/file.vhdx
# or simply
unmount-vhdx.sh
# (will show a list of mounted VHDX files to choose from)
```

List all mounted VHDX files:
```bash
list-vhdx-mounts.sh
```

### Method 4: Python GUI (Alternative)

If you prefer a standalone GUI application:

```bash
python3 vhdx_viewer.py
```

## How It Works

1. **NBD Module**: Loads the Network Block Device (NBD) kernel module
2. **QEMU-NBD**: Uses qemu-nbd to connect the VHDX file to an NBD device
3. **Partition Detection**: Automatically detects partitions within the VHDX
4. **Mounting**: Mounts the partitions to `/media/$USER/vhdx/<filename>/`
5. **File Access**: You can now access the files as if it were a regular disk

## Mounted File Location

VHDX files are mounted at:
```
/media/$USER/vhdx/<vhdx-filename>/
```

For example, if you mount `windows10.vhdx`, it will be available at:
```
/media/yourusername/vhdx/windows10/
```

If the VHDX contains multiple partitions:
```
/media/yourusername/vhdx/windows10/partition1/
/media/yourusername/vhdx/windows10/partition2/
```

## Supported Filesystems

- NTFS (Windows)
- ext4, ext3, ext2 (Linux)
- FAT32, FAT16
- exFAT
- And any other filesystem supported by your Linux kernel

## Troubleshooting

### "qemu-nbd not found"
Install qemu-utils:
```bash
# Debian/Ubuntu
sudo apt install qemu-utils

# Fedora
sudo dnf install qemu-img

# Arch
sudo pacman -S qemu
```

### "Failed to load NBD module"
Load the NBD kernel module manually:
```bash
sudo modprobe nbd max_part=8
```

To make it persistent across reboots:
```bash
echo "nbd" | sudo tee /etc/modules-load.d/nbd.conf
echo "options nbd max_part=8" | sudo tee /etc/modprobe.d/nbd.conf
```

### "No available NBD device found"
You may have too many VHDX files mounted. Unmount some:
```bash
list-vhdx-mounts.sh
unmount-vhdx.sh
```

### "Failed to mount: wrong fs type"
The VHDX may use a filesystem not supported by your kernel, or the partition table may be corrupted. Try:
```bash
# Check the partition table
sudo fdisk -l /dev/nbd0  # (after connecting with qemu-nbd)

# Try manual mounting with specific filesystem
sudo mount -t ntfs-3g /dev/nbd0p1 /mnt/test
```

### Permission Issues
Ensure you're in the appropriate groups:
```bash
sudo usermod -a -G disk,kvm $USER
# Log out and log back in for changes to take effect
```

## File Manager Support

### Nautilus (GNOME Files)
✅ Fully supported - Scripts installed to `~/.local/share/nautilus/scripts/`

### Dolphin (KDE)
✅ Fully supported - Service menu installed to `~/.local/share/kservices5/ServiceMenus/`

### Thunar (XFCE)
✅ Fully supported - Custom actions configured in `~/.config/Thunar/uca.xml`

### Nemo (Cinnamon)
✅ Compatible - Uses Nautilus scripts

### PCManFM (LXDE/LXQt)
⚠️ Partial - Can use double-click, context menu may not work

### Other File Managers
The double-click method should work with any file manager that respects XDG MIME associations.

## Security Considerations

- The tool requires sudo privileges to mount filesystems
- Only mount VHDX files from trusted sources
- Be cautious when mounting VHDX files with write permissions
- The tool doesn't automatically scan for malware

## Uninstallation

To remove the VHDX Mount Tool:

```bash
chmod +x uninstall.sh
./uninstall.sh
```

This will:
- Unmount any active VHDX files
- Remove all installed scripts and desktop files
- Clean up file manager integrations
- Remove MIME type associations

To also remove passwordless mounting configuration:
```bash
sudo rm /etc/sudoers.d/vhdx-mount
```

## Advanced Usage

### Mount with Read-Only Access

Edit `/usr/local/bin/mount-vhdx.sh` and change:
```bash
sudo mount -o rw "$part" "$PART_MOUNT"
```
to:
```bash
sudo mount -o ro "$part" "$PART_MOUNT"
```

### Auto-mount on System Startup

Add to `/etc/fstab` (not recommended for portable VHDX files):
```
# Not recommended - manual mounting is safer
```

### Integration with Other Tools

The mount scripts can be called from other applications:
```bash
#!/bin/bash
# Example: Batch mount multiple VHDX files
for vhdx in *.vhdx; do
    mount-vhdx.sh "$vhdx"
done
```

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

## License

This project is open source. Feel free to use, modify, and distribute as needed.

## Credits

- Uses QEMU NBD (Network Block Device) for VHDX access
- Integrates with FreeDesktop.org standards for Linux desktop environments

## Changelog

### Version 1.0.0
- Initial release
- Support for mounting VHDX files via double-click
- Context menu integration for major file managers
- Automatic partition detection
- NTFS filesystem support
- GUI notifications
- Command-line tools for advanced users
- Standalone Python GUI application (optional)

## FAQ

**Q: Can I write to the VHDX file?**
A: Yes, by default the VHDX is mounted with read-write access. Be careful when modifying files.

**Q: Can I mount multiple VHDX files at once?**
A: Yes, you can mount up to 16 VHDX files simultaneously (limited by NBD devices).

**Q: Is passwordless mounting safe?**
A: Yes! The sudoers configuration only allows specific commands for mounting VHDX files to /media/$USER/vhdx/. It doesn't grant general sudo access. You can review the configuration in /etc/sudoers.d/vhdx-mount.

**Q: How do I disable passwordless mounting?**
A: Simply remove the sudoers file: `sudo rm /etc/sudoers.d/vhdx-mount`

**Q: Does this work with VHD (not VHDX) files?**
A: Yes! qemu-nbd supports VHD, VHDX, VMDK, VDI, and other virtual disk formats.

**Q: Can I mount a VHDX from a Windows machine?**
A: If you can access the file (via network share, USB, etc.), yes you can mount it on Linux.

**Q: Will this work on WSL (Windows Subsystem for Linux)?**
A: NBD kernel module support in WSL is limited. It may work on WSL2 but is not officially supported.

**Q: Can I mount encrypted VHDX files?**
A: Not directly. You'll need to decrypt the VHDX first using appropriate tools.

## Support

For issues, questions, or suggestions:
1. Check the Troubleshooting section above
2. Open an issue on GitHub
3. Check qemu-nbd documentation: `man qemu-nbd`

---

**Happy VHDX Mounting! 🚀**
