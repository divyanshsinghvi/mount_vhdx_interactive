# Testing Guide - VHDX Mount Tool

Complete testing checklist before publishing to app stores.

## 🧪 Local Testing (Before Snap)

### Step 1: Test Basic Installation

```bash
cd mount_vhdx_interactive

# Run the installer
./install.sh

# Choose "No" for passwordless mounting (test with password first)
```

**Expected Result:**
- ✅ All dependencies installed
- ✅ Scripts copied to /usr/local/bin/
- ✅ Desktop files installed
- ✅ MIME type registered

---

### Step 2: Create Test VHDX File

You need a test VHDX file. Here are your options:

#### Option A: Download Test VHDX
```bash
# Small test VHDX (if you have one)
# Or create one on Windows and transfer it
```

#### Option B: Create VHDX on Linux (requires qemu)
```bash
# Create a 100MB test VHDX
qemu-img create -f vhdx test.vhdx 100M

# Format it (if you want to test mounting)
# This creates a raw disk, you may need to partition and format
```

#### Option C: Use Existing VHDX
If you already have a .vhdx file from Windows/Hyper-V, use that!

---

### Step 3: Test Command Line Mounting

```bash
# Test mount with password prompt
mount-vhdx.sh /path/to/test.vhdx

# Check if mounted
list-vhdx-mounts.sh

# Check in file manager
ls /media/$USER/vhdx/

# Test unmount
unmount-vhdx.sh
```

**Expected Results:**
- ✅ Zenity dialog appears (or kdialog)
- ✅ Password prompt appears
- ✅ Success notification shown
- ✅ File manager opens automatically
- ✅ VHDX visible in /media/$USER/vhdx/
- ✅ Unmount works cleanly

---

### Step 4: Test File Manager Integration

#### Test Double-Click
1. Open your file manager (Nautilus, Dolphin, etc.)
2. Navigate to your .vhdx file
3. Double-click the file

**Expected:**
- ✅ mount-vhdx.sh launches
- ✅ Password prompt appears (or auto-mounts if passwordless)
- ✅ File manager opens mounted location

#### Test Right-Click Context Menu

**For Nautilus (GNOME):**
```bash
# Check if scripts installed
ls ~/.local/share/nautilus/scripts/

# Should see:
# - Mount VHDX
# - Unmount VHDX
```

1. Right-click .vhdx file
2. Look for "Scripts" → "Mount VHDX"
3. Click it

**For Dolphin (KDE):**
1. Right-click .vhdx file
2. Look for "Mount VHDX" in context menu
3. Click it

**Expected:**
- ✅ Context menu shows mount/unmount options
- ✅ Clicking triggers mount operation

---

### Step 5: Test Python GUI Application

```bash
# Launch GUI
python3 vhdx_viewer.py
```

**Test Checklist:**
- ✅ Window opens without errors
- ✅ Can browse and select .vhdx file
- ✅ Mount button works
- ✅ Status log shows progress
- ✅ "Open in File Manager" button works
- ✅ Unmount button works
- ✅ Window closes cleanly

---

### Step 6: Test Icon Integration

```bash
# Update desktop database
sudo update-desktop-database /usr/share/applications/
sudo update-mime-database /usr/share/mime/

# Check if icon is recognized
gio mime application/x-vhdx
gio mime application/vnd.ms-vhdx

# Should show: vhdx-mount.desktop
```

**Visual Test:**
1. Open file manager
2. Find a .vhdx file
3. Check if custom icon appears (may need to log out/in)

---

### Step 7: Test Passwordless Mounting

```bash
# Run passwordless setup
./setup-passwordless.sh

# Choose "Yes" to continue
# Enter your password once
```

**Test:**
```bash
# Now try mounting again
mount-vhdx.sh /path/to/test.vhdx
```

**Expected:**
- ✅ NO password prompt
- ✅ Mounts automatically
- ✅ File manager opens immediately

---

## 📦 Testing Snap Package Locally

### Step 1: Install Snapcraft

```bash
sudo snap install snapcraft --classic
```

---

### Step 2: Build Snap Locally

```bash
cd mount_vhdx_interactive

# Clean build (first time)
snapcraft clean
snapcraft

# This will take 5-10 minutes
# Creates: vhdx-mount_1.0.0_amd64.snap
```

**Troubleshooting Build Issues:**
```bash
# If build fails, try:
snapcraft clean
snapcraft --debug

# Or build in container:
snapcraft --use-lxd
```

---

### Step 3: Install Snap Locally

```bash
# Install your locally built snap
sudo snap install --dangerous --classic vhdx-mount_1.0.0_amd64.snap

# --dangerous: allows installing unsigned local snaps
# --classic: required for sudo access
```

**Expected:**
```
vhdx-mount 1.0.0 installed
```

---

### Step 4: Test Snap Commands

```bash
# Test mount command
vhdx-mount.mount /path/to/test.vhdx

# Test unmount
vhdx-mount.unmount

# Test list
vhdx-mount.list

# Test GUI viewer
vhdx-mount.viewer
```

---

### Step 5: Test Snap Desktop Integration

```bash
# Snap desktop files are at:
ls /var/lib/snapd/desktop/applications/

# Should see:
# - vhdx-mount_vhdx-mount.desktop
```

**Visual Test:**
1. Open application menu
2. Search for "VHDX"
3. Should see "VHDX Mount" and "VHDX Viewer" apps
4. Launch them

**File Association Test:**
1. Double-click .vhdx file
2. Should mount via snap

---

### Step 6: Test Snap Icon

```bash
# Icon should be at:
ls /snap/vhdx-mount/current/meta/gui/

# Check if icon displays in app launcher
```

---

### Step 7: Uninstall and Reinstall Snap

```bash
# Uninstall
sudo snap remove vhdx-mount

# Verify cleanup
list-vhdx-mounts.sh  # Should show nothing or error

# Reinstall
sudo snap install --dangerous --classic vhdx-mount_1.0.0_amd64.snap

# Test again
vhdx-mount.mount /path/to/test.vhdx
```

---

## ✅ Pre-Publish Checklist

Before uploading to Snap Store:

### Functionality
- [ ] Command-line mounting works
- [ ] Command-line unmounting works
- [ ] GUI application launches and works
- [ ] Double-click .vhdx files works
- [ ] Right-click context menu appears
- [ ] Passwordless mounting works (optional)
- [ ] NTFS filesystems mount correctly
- [ ] Multiple partitions detected
- [ ] File manager opens mounted location

### Integration
- [ ] Desktop files valid (`desktop-file-validate *.desktop`)
- [ ] Icon displays correctly
- [ ] MIME type registered
- [ ] File associations work
- [ ] Notifications appear

### Snap Package
- [ ] Snap builds without errors
- [ ] Snap installs locally
- [ ] All snap commands work
- [ ] Desktop integration works in snap
- [ ] Icon displays in snap
- [ ] No permission errors
- [ ] Snap uninstalls cleanly

### Documentation
- [ ] README.md is accurate
- [ ] QUICKSTART.md tested
- [ ] All commands in docs work
- [ ] Screenshots taken (5 minimum)
- [ ] Icon generated in all sizes

### Quality
- [ ] No errors in logs
- [ ] Cleanup works properly
- [ ] No leftover files after unmount
- [ ] Safe handling of multiple mounts
- [ ] Works on clean system

---

## 🐛 Common Issues & Solutions

### Issue: "qemu-nbd not found"
```bash
sudo apt install qemu-utils
```

### Issue: "NBD module not loaded"
```bash
sudo modprobe nbd max_part=8
```

### Issue: "No available NBD device"
```bash
# Unmount existing VHDX files
list-vhdx-mounts.sh
unmount-vhdx.sh
```

### Issue: Icon not showing
```bash
# Update databases
sudo update-desktop-database
sudo update-mime-database /usr/share/mime
# Log out and log back in
```

### Issue: Snap build fails
```bash
# Clean everything
snapcraft clean
rm -rf parts/ prime/ stage/

# Try again
snapcraft --debug
```

### Issue: Snap doesn't have sudo access
```bash
# Make sure you used --classic during install
sudo snap install --classic vhdx-mount_1.0.0_amd64.snap
```

---

## 🔍 Detailed Testing Steps

### Test Mount with Different Filesystems

1. **NTFS (Windows)** - Most common
2. **ext4 (Linux)**
3. **FAT32**
4. **Multiple partitions**

### Test Error Handling

```bash
# Test with non-existent file
mount-vhdx.sh /nonexistent.vhdx

# Test with corrupted VHDX
mount-vhdx.sh /corrupted.vhdx

# Test mounting already mounted file
mount-vhdx.sh /same/file.vhdx  # twice
```

**Expected:**
- ✅ Clear error messages
- ✅ No crashes
- ✅ Proper cleanup

---

## 📊 Performance Testing

```bash
# Test mounting speed
time mount-vhdx.sh test.vhdx

# Should be under 5 seconds for small VHDX

# Test with large VHDX (1GB+)
time mount-vhdx.sh large.vhdx
```

---

## 🎬 Record a Demo

Once everything works:

```bash
# Install screen recorder
sudo apt install peek

# Record:
# 1. Double-click .vhdx
# 2. Auto-mount
# 3. File manager opens
# 4. Browse files
# 5. Right-click unmount

# Save as demo.gif for README
```

---

## 🚀 Ready to Publish?

If all tests pass, you're ready to publish to Snap Store!

```bash
# Login to Snap Store
snapcraft login

# Register your snap name (one time)
snapcraft register vhdx-mount

# Upload
snapcraft upload vhdx-mount_1.0.0_amd64.snap --release=stable

# Monitor status
snapcraft status vhdx-mount
```

---

## 📝 Test Results Template

Document your testing:

```markdown
# Test Results - VHDX Mount Tool

**Date:** [Today's date]
**Version:** 1.0.0
**System:** Ubuntu 24.04 / [Your distro]

## Local Installation
- [ ] Installed successfully
- [ ] All commands work
- [ ] File manager integration works
- [ ] Icon displays correctly

## Snap Package
- [ ] Builds successfully
- [ ] Installs locally
- [ ] All features work
- [ ] Desktop integration works

## Issues Found
- None / [List any issues]

## Screenshots
- [ ] 5 screenshots taken
- [ ] Saved to assets/screenshots/

## Ready for Publication
- [x] All tests passed
- [x] Documentation complete
```

---

**Good luck with testing!** 🧪

If you find any issues, fix them before publishing. Better to catch bugs now than get bad reviews later!
