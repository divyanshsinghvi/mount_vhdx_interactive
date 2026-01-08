# 📦 Distribution Guide - Publishing VHDX Mount Tool

This guide explains how to package and distribute the VHDX Mount Tool to various Linux app stores and repositories.

## 🎯 Distribution Options

### 1. **Snap Store** (Recommended - Cross-distro)

**Pros:**
- Works on Ubuntu, Debian, Fedora, Arch, and more
- Automatic updates
- Easy submission process

**Cons:**
- Requires classic confinement (due to sudo requirements)
- Needs manual approval from Snapcraft team

#### Build & Publish Snap

```bash
# Install snapcraft
sudo snap install snapcraft --classic

# Build the snap
cd mount_vhdx_interactive
snapcraft

# Test locally
sudo snap install --dangerous --classic vhdx-mount_1.0.0_amd64.snap

# Login to Snap Store
snapcraft login

# Upload to Snap Store
snapcraft upload vhdx-mount_1.0.0_amd64.snap --release=stable
```

#### Register your snap
```bash
snapcraft register vhdx-mount
```

Then visit: https://snapcraft.io/register-snap

---

### 2. **Flathub** (Cross-distro, Sandboxed)

**Pros:**
- Very popular on GNOME desktops
- Good sandboxing
- Cross-distribution

**Cons:**
- Sandboxing conflicts with sudo requirements
- More complex to configure for system-level access

#### Build & Publish Flatpak

```bash
# Install flatpak-builder
sudo apt install flatpak-builder

# Build the flatpak
flatpak-builder build-dir com.github.divyanshsinghvi.VHDXMount.yml --force-clean

# Test locally
flatpak-builder --run build-dir com.github.divyanshsinghvi.VHDXMount.yml vhdx_viewer.py

# Create bundle
flatpak build-export export build-dir
flatpak build-bundle export vhdx-mount.flatpak com.github.divyanshsinghvi.VHDXMount
```

**To publish on Flathub:**
1. Fork: https://github.com/flathub/flathub
2. Add your manifest file
3. Submit pull request
4. Wait for review

**Note:** Flathub may reject apps requiring sudo access. The Python GUI viewer would work, but shell scripts may have issues.

---

### 3. **Debian/Ubuntu (.deb package)**

**Best for:** Debian, Ubuntu, Linux Mint, Pop!_OS, elementary OS

#### Build .deb Package

```bash
# Install build tools
sudo apt install debhelper devscripts

# Build the package
cd mount_vhdx_interactive
debuild -us -uc

# Test install
sudo dpkg -i ../vhdx-mount_1.0.0-1_all.deb
```

#### Publish to PPA (Ubuntu)

1. Create Launchpad account: https://launchpad.net/
2. Create PPA: https://launchpad.net/~/+activate-ppa
3. Sign and upload:

```bash
# Build source package
debuild -S

# Upload to PPA
dput ppa:yourusername/vhdx-mount ../vhdx-mount_1.0.0-1_source.changes
```

---

### 4. **AUR** (Arch User Repository)

**Best for:** Arch Linux, Manjaro, EndeavourOS

#### Publish to AUR

```bash
# Install needed tools
sudo pacman -S base-devel git

# Create AUR package
cd mount_vhdx_interactive

# Test build
makepkg -si

# Submit to AUR
# 1. Create AUR account: https://aur.archlinux.org/register
# 2. Add SSH key to AUR account
# 3. Clone AUR repo
git clone ssh://aur@aur.archlinux.org/vhdx-mount.git aur-vhdx-mount
cd aur-vhdx-mount

# 4. Copy PKGBUILD and .SRCINFO
cp ../PKGBUILD .
makepkg --printsrcinfo > .SRCINFO

# 5. Commit and push
git add PKGBUILD .SRCINFO
git commit -m "Initial commit: vhdx-mount 1.0.0"
git push
```

---

### 5. **RPM Package** (Fedora, RHEL, CentOS)

#### Build RPM Package

```bash
# Install tools
sudo dnf install rpm-build rpmdevtools

# Setup build environment
rpmdev-setuptree

# Create spec file
cat > ~/rpmbuild/SPECS/vhdx-mount.spec <<'EOF'
Name:           vhdx-mount
Version:        1.0.0
Release:        1%{?dist}
Summary:        Mount VHDX virtual disk files with one click

License:        MIT
URL:            https://github.com/divyanshsinghvi/mount_vhdx_interactive
Source0:        %{name}-%{version}.tar.gz

Requires:       qemu-img ntfs-3g zenity python3 python3-tkinter
BuildArch:      noarch

%description
VHDX Mount Tool makes it easy to mount and access VHDX files on Linux.

%prep
%setup -q

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/usr/local/bin
mkdir -p $RPM_BUILD_ROOT/usr/share/applications
mkdir -p $RPM_BUILD_ROOT/usr/share/mime/packages

install -m 755 mount-vhdx.sh $RPM_BUILD_ROOT/usr/local/bin/
install -m 755 unmount-vhdx.sh $RPM_BUILD_ROOT/usr/local/bin/
install -m 755 list-vhdx-mounts.sh $RPM_BUILD_ROOT/usr/local/bin/
install -m 755 setup-passwordless.sh $RPM_BUILD_ROOT/usr/local/bin/
install -m 755 vhdx_viewer.py $RPM_BUILD_ROOT/usr/local/bin/
install -m 644 vhdx-mount.desktop $RPM_BUILD_ROOT/usr/share/applications/
install -m 644 vhdx-unmount.desktop $RPM_BUILD_ROOT/usr/share/applications/
install -m 644 vhdx.xml $RPM_BUILD_ROOT/usr/share/mime/packages/

%files
/usr/local/bin/*
/usr/share/applications/*
/usr/share/mime/packages/*

%changelog
* Wed Jan 08 2026 Divyansh Singhvi <divyanshsinghvi@gmail.com> - 1.0.0-1
- Initial package
EOF

# Build RPM
rpmbuild -ba ~/rpmbuild/SPECS/vhdx-mount.spec
```

---

## 📋 Comparison & Recommendations

| Distribution Method | Ease of Use | Reach | Sudo Support | Updates |
|---------------------|-------------|-------|--------------|---------|
| **Snap Store** ⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ✅ Classic | Auto |
| **AUR (Arch)** ⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ✅ | Manual |
| **PPA (Ubuntu)** | ⭐⭐⭐ | ⭐⭐⭐⭐ | ✅ | Auto |
| **Flathub** | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⚠️ Limited | Auto |
| **RPM (Fedora)** | ⭐⭐⭐ | ⭐⭐⭐ | ✅ | Manual |
| **.deb (Direct)** | ⭐⭐ | ⭐⭐ | ✅ | Manual |

### 🎯 Recommended Strategy

**Phase 1: Quick Start**
1. **AUR** - Easiest to publish, Arch users love it
2. **GitHub Releases** - Direct .deb and .rpm downloads

**Phase 2: Wide Distribution**
3. **Snap Store** - Best cross-distro support
4. **Ubuntu PPA** - Large Ubuntu user base

**Phase 3: Maximum Reach**
5. **Flathub** - For GUI app only (without sudo features)

---

## 🚀 Quick Publish Commands

### Publish to GitHub Releases
```bash
# Tag the release
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# Build packages
cd mount_vhdx_interactive
debuild -us -uc
rpmbuild -ba SPECS/vhdx-mount.spec
makepkg

# Upload to GitHub Releases page
# .deb, .rpm, and .tar.gz files
```

### Update Repository URLs

After publishing, update these URLs in your files:
- `snap/snapcraft.yaml` - Set proper GitHub URL
- `debian/control` - Update homepage
- `PKGBUILD` - Update source URL
- `README.md` - Add installation badges

---

## 📝 Pre-Submission Checklist

- [ ] All scripts have proper shebangs and are executable
- [ ] Desktop files validated: `desktop-file-validate *.desktop`
- [ ] MIME types work correctly
- [ ] Tested on fresh VM installation
- [ ] README has installation instructions for each platform
- [ ] LICENSE file included
- [ ] Version numbers consistent across all files
- [ ] Screenshots/demo GIF for app store listings
- [ ] Privacy policy (if collecting any data)
- [ ] Support/contact information

---

## 📸 Assets for App Stores

You'll need:
1. **Icon** (128x128, 256x256, 512x512 PNG)
2. **Screenshots** (at least 3, showing the app in use)
3. **Banner/Hero Image** (for some stores)
4. **Short description** (max 80 chars)
5. **Long description** (your README content)

Create these and add to repository:
```
assets/
  ├── icons/
  │   ├── icon-128.png
  │   ├── icon-256.png
  │   └── icon-512.png
  ├── screenshots/
  │   ├── screenshot1.png
  │   ├── screenshot2.png
  │   └── screenshot3.png
  └── banner.png
```

---

## 🔗 Useful Links

- **Snap Store**: https://snapcraft.io/
- **Flathub**: https://flathub.org/
- **AUR**: https://aur.archlinux.org/
- **Ubuntu PPA**: https://launchpad.net/
- **openSUSE Build Service**: https://build.opensuse.org/

---

## 🎉 After Publishing

1. Add badges to README:
```markdown
[![Get it from the Snap Store](https://snapcraft.io/static/images/badges/en/snap-store-black.svg)](https://snapcraft.io/vhdx-mount)
```

2. Announce on:
   - Reddit: r/linux, r/linuxquestions, r/Ubuntu, etc.
   - Linux forums
   - Your social media

3. Submit to:
   - AlternativeTo.net
   - Linux app review sites
   - OMG! Ubuntu, It's FOSS, etc.

Good luck with your distribution! 🚀
