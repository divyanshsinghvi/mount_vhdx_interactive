# 🎯 Quick Guide - Mounting Modes

## Default Behavior (After Installation)

### ✅ Double-Click = Automatic Read-Write Mount
- **Just double-click any .vhdx file**
- **Instantly mounts with write access**
- **No dialogs, no questions**
- **Files open immediately in file manager**

This is the **fastest, easiest way** - designed for daily use!

---

## All Available Options

### 1️⃣ **Double-Click** (Automatic Read-Write) ✍️
```
Click .vhdx file → Mounts immediately → Opens file manager
```
- Default mode after installation
- Read-write access (can modify files)
- No prompts or dialogs
- **Best for:** Daily use, editing files

### 2️⃣ **Right-Click → Mount VHDX (Read-Write)** ✍️
```
Right-click .vhdx → Mount VHDX (Read-Write)
```
- Same as double-click
- Explicit read-write choice
- No dialogs
- **Best for:** When you want to be explicit

### 3️⃣ **Right-Click → Mount VHDX (Read-Only)** 👁️
```
Right-click .vhdx → Mount VHDX (Read-Only)
```
- Safe mode
- Cannot modify files
- No dialogs
- **Best for:** Browsing backups safely

### 4️⃣ **Command Line**
```bash
# Automatic read-write (default)
mount-vhdx-rw.sh disk.vhdx

# Read-only (safe)
mount-vhdx-ro.sh disk.vhdx

# Generic (asks for mode)
mount-vhdx.sh disk.vhdx
```

---

## What Each Mode Does

| Mode | Can Edit? | Can Create? | Can Delete? | Use Case |
|------|-----------|-------------|-------------|----------|
| **Read-Write** ✍️ | ✅ Yes | ✅ Yes | ✅ Yes | Daily editing |
| **Read-Only** 👁️ | ❌ No | ❌ No | ❌ No | Safe browsing |

---

## Examples

### Edit Windows Files from Linux
```bash
# Just double-click windows.vhdx
# Or:
mount-vhdx-rw.sh windows.vhdx

# Files appear at:
cd /media/$USER/vhdx/windows/

# Edit directly:
nano Users/Documents/file.txt
echo "test" > newfile.txt

# Changes saved immediately!
```

### Browse Backup Safely
```bash
# Right-click → Mount VHDX (Read-Only)
# Or:
mount-vhdx-ro.sh backup.vhdx

# Browse without risk:
cd /media/$USER/vhdx/backup/
ls -la
# Cannot accidentally modify anything!
```

---

## Changing Default Behavior

### Want Read-Only by Default?
Edit `/usr/share/applications/vhdx-mount.desktop`:
```
Change: Exec=/usr/local/bin/mount-vhdx-rw.sh %f
To:     Exec=/usr/local/bin/mount-vhdx-ro.sh %f
```

### Want to Be Asked Every Time?
Edit `/usr/share/applications/vhdx-mount.desktop`:
```
Change: Exec=/usr/local/bin/mount-vhdx-rw.sh %f
To:     Exec=/usr/local/bin/mount-vhdx.sh %f
```

Then double-clicking will ask: "Mount with write access?"

---

## Quick Reference

| What You Want | How to Do It |
|---------------|--------------|
| **Mount now, edit files** | Double-click .vhdx file |
| **Mount read-only (safe)** | Right-click → Read-Only |
| **See what's mounted** | `list-vhdx-mounts.sh` |
| **Unmount** | Right-click → Unmount VHDX |

---

## Safety Tips

✅ **DO:**
- Double-click for quick read-write access
- Use read-only when browsing backups
- Unmount properly before moving VHDX files

❌ **DON'T:**
- Force shutdown while mounted
- Delete VHDX file while mounted
- Edit system files unless you know what you're doing

---

**TL;DR:** Just double-click any .vhdx file and it works! 🎉
