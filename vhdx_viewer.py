#!/usr/bin/env python3
"""
VHDX Viewer - A GUI application to mount and visualize VHDX files on Linux
"""

import tkinter as tk
from tkinter import ttk, filedialog, messagebox, scrolledtext
import subprocess
import os
import sys
import json
from pathlib import Path
import threading
import time

class VHDXViewer:
    def __init__(self, root):
        self.root = root
        self.root.title("VHDX Viewer - Linux")
        self.root.geometry("800x600")
        self.root.resizable(True, True)

        # State variables
        self.vhdx_path = tk.StringVar()
        self.mount_point = tk.StringVar()
        self.nbd_device = None
        self.mounted_partitions = []
        self.config_file = Path.home() / ".vhdx_viewer_config.json"

        # Load previous state
        self.load_config()

        # Setup UI
        self.setup_ui()

        # Check dependencies
        self.root.after(100, self.check_dependencies)

    def setup_ui(self):
        """Setup the user interface"""
        # Main container
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        main_frame.columnconfigure(0, weight=1)
        main_frame.rowconfigure(4, weight=1)

        # Title
        title_label = ttk.Label(main_frame, text="VHDX Viewer for Linux",
                               font=('Arial', 16, 'bold'))
        title_label.grid(row=0, column=0, columnspan=3, pady=(0, 20))

        # File selection
        file_frame = ttk.LabelFrame(main_frame, text="Select VHDX File", padding="10")
        file_frame.grid(row=1, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=(0, 10))
        file_frame.columnconfigure(1, weight=1)

        ttk.Label(file_frame, text="File:").grid(row=0, column=0, sticky=tk.W, padx=(0, 5))
        ttk.Entry(file_frame, textvariable=self.vhdx_path, width=50).grid(row=0, column=1,
                                                                           sticky=(tk.W, tk.E), padx=5)
        ttk.Button(file_frame, text="Browse", command=self.browse_file).grid(row=0, column=2)

        # Mount point
        mount_frame = ttk.LabelFrame(main_frame, text="Mount Configuration", padding="10")
        mount_frame.grid(row=2, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=(0, 10))
        mount_frame.columnconfigure(1, weight=1)

        ttk.Label(mount_frame, text="Mount Point:").grid(row=0, column=0, sticky=tk.W, padx=(0, 5))
        ttk.Entry(mount_frame, textvariable=self.mount_point, width=50).grid(row=0, column=1,
                                                                               sticky=(tk.W, tk.E), padx=5)
        ttk.Button(mount_frame, text="Select", command=self.browse_mount_point).grid(row=0, column=2)

        # Action buttons
        button_frame = ttk.Frame(main_frame)
        button_frame.grid(row=3, column=0, columnspan=3, pady=(0, 10))

        self.mount_btn = ttk.Button(button_frame, text="Mount VHDX",
                                     command=self.mount_vhdx, width=15)
        self.mount_btn.grid(row=0, column=0, padx=5)

        self.unmount_btn = ttk.Button(button_frame, text="Unmount VHDX",
                                       command=self.unmount_vhdx, state='disabled', width=15)
        self.unmount_btn.grid(row=0, column=1, padx=5)

        self.open_btn = ttk.Button(button_frame, text="Open in File Manager",
                                    command=self.open_file_manager, state='disabled', width=20)
        self.open_btn.grid(row=0, column=2, padx=5)

        self.refresh_btn = ttk.Button(button_frame, text="Refresh Info",
                                       command=self.refresh_info, width=15)
        self.refresh_btn.grid(row=0, column=3, padx=5)

        # Log/Info area
        log_frame = ttk.LabelFrame(main_frame, text="Status & Information", padding="10")
        log_frame.grid(row=4, column=0, columnspan=3, sticky=(tk.W, tk.E, tk.N, tk.S))
        log_frame.columnconfigure(0, weight=1)
        log_frame.rowconfigure(0, weight=1)

        self.log_text = scrolledtext.ScrolledText(log_frame, height=15, width=70)
        self.log_text.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

        # Status bar
        self.status_var = tk.StringVar(value="Ready")
        status_bar = ttk.Label(main_frame, textvariable=self.status_var,
                              relief=tk.SUNKEN, anchor=tk.W)
        status_bar.grid(row=5, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=(5, 0))

        self.log("VHDX Viewer initialized. Please select a VHDX file to mount.")

    def log(self, message):
        """Add message to log area"""
        timestamp = time.strftime("%H:%M:%S")
        self.log_text.insert(tk.END, f"[{timestamp}] {message}\n")
        self.log_text.see(tk.END)
        self.log_text.update()

    def check_dependencies(self):
        """Check if required tools are installed"""
        self.log("Checking dependencies...")

        dependencies = {
            'qemu-nbd': 'QEMU NBD tools',
            'modprobe': 'Kernel module management',
            'mount': 'Mount utilities',
            'lsblk': 'Block device listing'
        }

        missing = []
        for cmd, desc in dependencies.items():
            try:
                result = subprocess.run(['which', cmd], capture_output=True, text=True)
                if result.returncode == 0:
                    self.log(f"✓ {desc} ({cmd}) found")
                else:
                    missing.append(cmd)
                    self.log(f"✗ {desc} ({cmd}) NOT found")
            except Exception as e:
                missing.append(cmd)
                self.log(f"✗ Error checking {cmd}: {str(e)}")

        if missing:
            self.log("\nWARNING: Missing dependencies. Install with:")
            self.log("  sudo apt install qemu-utils  # For Debian/Ubuntu")
            self.log("  sudo dnf install qemu-img    # For Fedora")
            self.log("  sudo pacman -S qemu          # For Arch")
            messagebox.showwarning("Missing Dependencies",
                                  f"Missing tools: {', '.join(missing)}\n\n"
                                  "Please install them to use this application.")
        else:
            self.log("\n✓ All dependencies satisfied!")

    def browse_file(self):
        """Browse for VHDX file"""
        filename = filedialog.askopenfilename(
            title="Select VHDX File",
            filetypes=[("VHDX files", "*.vhdx"), ("All files", "*.*")]
        )
        if filename:
            self.vhdx_path.set(filename)
            self.log(f"Selected file: {filename}")

            # Auto-suggest mount point
            if not self.mount_point.get():
                suggested = f"/tmp/vhdx_mount_{Path(filename).stem}"
                self.mount_point.set(suggested)

    def browse_mount_point(self):
        """Browse for mount point directory"""
        directory = filedialog.askdirectory(title="Select Mount Point")
        if directory:
            self.mount_point.set(directory)
            self.log(f"Mount point set to: {directory}")

    def mount_vhdx(self):
        """Mount the VHDX file"""
        vhdx_file = self.vhdx_path.get()
        mount_point = self.mount_point.get()

        if not vhdx_file or not os.path.exists(vhdx_file):
            messagebox.showerror("Error", "Please select a valid VHDX file")
            return

        if not mount_point:
            messagebox.showerror("Error", "Please specify a mount point")
            return

        # Create mount point if it doesn't exist
        try:
            os.makedirs(mount_point, exist_ok=True)
        except Exception as e:
            messagebox.showerror("Error", f"Failed to create mount point: {str(e)}")
            return

        self.status_var.set("Mounting...")
        self.mount_btn.config(state='disabled')
        self.log("\n" + "="*50)
        self.log("Starting mount process...")

        # Run mount in thread to avoid blocking UI
        thread = threading.Thread(target=self._mount_thread, args=(vhdx_file, mount_point))
        thread.daemon = True
        thread.start()

    def _mount_thread(self, vhdx_file, mount_point):
        """Thread worker for mounting"""
        try:
            # Step 1: Load NBD kernel module
            self.log("Loading NBD kernel module...")
            result = subprocess.run(['sudo', 'modprobe', 'nbd', 'max_part=8'],
                                  capture_output=True, text=True)
            if result.returncode != 0:
                raise Exception(f"Failed to load NBD module: {result.stderr}")

            # Step 2: Find available NBD device
            self.log("Finding available NBD device...")
            for i in range(16):
                nbd = f"/dev/nbd{i}"
                result = subprocess.run(['sudo', 'qemu-nbd', '--connect', nbd, vhdx_file],
                                      capture_output=True, text=True)
                if result.returncode == 0:
                    self.nbd_device = nbd
                    self.log(f"Connected VHDX to {nbd}")
                    break

            if not self.nbd_device:
                raise Exception("No available NBD device found")

            # Wait for device to be ready
            time.sleep(2)

            # Step 3: List partitions
            self.log("Scanning for partitions...")
            result = subprocess.run(['sudo', 'partprobe', self.nbd_device],
                                  capture_output=True, text=True)

            time.sleep(1)

            result = subprocess.run(['lsblk', '-J', self.nbd_device],
                                  capture_output=True, text=True)

            if result.returncode == 0:
                try:
                    lsblk_data = json.loads(result.stdout)
                    devices = lsblk_data.get('blockdevices', [])

                    if devices and 'children' in devices[0]:
                        partitions = devices[0]['children']
                        self.log(f"Found {len(partitions)} partition(s)")

                        # Mount first partition (or all)
                        for idx, part in enumerate(partitions):
                            part_name = part['name']
                            part_path = f"/dev/{part_name}"
                            part_mount = mount_point if len(partitions) == 1 else f"{mount_point}/part{idx+1}"

                            os.makedirs(part_mount, exist_ok=True)

                            self.log(f"Mounting {part_path} to {part_mount}...")
                            result = subprocess.run(['sudo', 'mount', '-o', 'rw', part_path, part_mount],
                                                  capture_output=True, text=True)

                            if result.returncode == 0:
                                self.mounted_partitions.append({'device': part_path, 'mount': part_mount})
                                self.log(f"✓ Successfully mounted {part_path}")
                            else:
                                self.log(f"✗ Failed to mount {part_path}: {result.stderr}")
                    else:
                        # No partitions, try mounting the device directly
                        self.log("No partitions found, mounting device directly...")
                        result = subprocess.run(['sudo', 'mount', '-o', 'rw', self.nbd_device, mount_point],
                                              capture_output=True, text=True)
                        if result.returncode == 0:
                            self.mounted_partitions.append({'device': self.nbd_device, 'mount': mount_point})
                            self.log(f"✓ Successfully mounted {self.nbd_device}")
                        else:
                            raise Exception(f"Failed to mount: {result.stderr}")

                except json.JSONDecodeError:
                    self.log("Warning: Could not parse lsblk output, attempting direct mount...")
                    result = subprocess.run(['sudo', 'mount', '-o', 'rw', self.nbd_device, mount_point],
                                          capture_output=True, text=True)
                    if result.returncode == 0:
                        self.mounted_partitions.append({'device': self.nbd_device, 'mount': mount_point})
                        self.log(f"✓ Successfully mounted {self.nbd_device}")

            if self.mounted_partitions:
                self.log("\n✓ VHDX mounted successfully!")
                self.log(f"Access your files at: {mount_point}")
                self.root.after(0, lambda: self.status_var.set("Mounted"))
                self.root.after(0, lambda: self.unmount_btn.config(state='normal'))
                self.root.after(0, lambda: self.open_btn.config(state='normal'))
                self.save_config()
            else:
                raise Exception("No partitions were successfully mounted")

        except Exception as e:
            self.log(f"\n✗ Error: {str(e)}")
            self.root.after(0, lambda: messagebox.showerror("Mount Failed", str(e)))
            self.root.after(0, lambda: self.status_var.set("Mount failed"))
            # Cleanup on failure
            if self.nbd_device:
                subprocess.run(['sudo', 'qemu-nbd', '--disconnect', self.nbd_device],
                             capture_output=True)
                self.nbd_device = None
        finally:
            self.root.after(0, lambda: self.mount_btn.config(state='normal'))

    def unmount_vhdx(self):
        """Unmount the VHDX file"""
        self.status_var.set("Unmounting...")
        self.unmount_btn.config(state='disabled')
        self.log("\n" + "="*50)
        self.log("Starting unmount process...")

        thread = threading.Thread(target=self._unmount_thread)
        thread.daemon = True
        thread.start()

    def _unmount_thread(self):
        """Thread worker for unmounting"""
        try:
            # Unmount all partitions
            for part_info in self.mounted_partitions:
                mount_point = part_info['mount']
                self.log(f"Unmounting {mount_point}...")
                result = subprocess.run(['sudo', 'umount', mount_point],
                                      capture_output=True, text=True)
                if result.returncode == 0:
                    self.log(f"✓ Unmounted {mount_point}")
                else:
                    self.log(f"Warning: Failed to unmount {mount_point}: {result.stderr}")

            self.mounted_partitions = []

            # Disconnect NBD device
            if self.nbd_device:
                self.log(f"Disconnecting {self.nbd_device}...")
                result = subprocess.run(['sudo', 'qemu-nbd', '--disconnect', self.nbd_device],
                                      capture_output=True, text=True)
                if result.returncode == 0:
                    self.log(f"✓ Disconnected {self.nbd_device}")
                else:
                    self.log(f"Warning: Failed to disconnect: {result.stderr}")

                self.nbd_device = None

            self.log("\n✓ VHDX unmounted successfully!")
            self.root.after(0, lambda: self.status_var.set("Unmounted"))
            self.root.after(0, lambda: self.open_btn.config(state='disabled'))

        except Exception as e:
            self.log(f"\n✗ Error during unmount: {str(e)}")
            self.root.after(0, lambda: messagebox.showerror("Unmount Failed", str(e)))
        finally:
            self.root.after(0, lambda: self.unmount_btn.config(state='disabled'))
            self.root.after(0, lambda: self.mount_btn.config(state='normal'))

    def open_file_manager(self):
        """Open the mount point in file manager"""
        mount_point = self.mount_point.get()
        if mount_point and os.path.exists(mount_point):
            try:
                # Try common file managers
                for fm in ['xdg-open', 'nautilus', 'dolphin', 'thunar', 'pcmanfm']:
                    try:
                        subprocess.Popen([fm, mount_point])
                        self.log(f"Opened {mount_point} in file manager")
                        return
                    except FileNotFoundError:
                        continue

                messagebox.showinfo("Info", f"Please open: {mount_point}")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to open file manager: {str(e)}")

    def refresh_info(self):
        """Refresh information about current mounts"""
        self.log("\n" + "="*50)
        self.log("Refreshing mount information...")

        if self.mounted_partitions:
            for part_info in self.mounted_partitions:
                mount_point = part_info['mount']
                device = part_info['device']

                # Check if still mounted
                result = subprocess.run(['mountpoint', '-q', mount_point])
                if result.returncode == 0:
                    self.log(f"✓ {device} is mounted at {mount_point}")

                    # Get disk usage
                    result = subprocess.run(['df', '-h', mount_point],
                                          capture_output=True, text=True)
                    if result.returncode == 0:
                        lines = result.stdout.strip().split('\n')
                        if len(lines) > 1:
                            self.log(f"  {lines[1]}")
                else:
                    self.log(f"✗ {mount_point} is no longer mounted")
        else:
            self.log("No VHDX currently mounted")

    def save_config(self):
        """Save configuration"""
        config = {
            'last_vhdx': self.vhdx_path.get(),
            'last_mount': self.mount_point.get()
        }
        try:
            with open(self.config_file, 'w') as f:
                json.dump(config, f)
        except Exception:
            pass

    def load_config(self):
        """Load configuration"""
        try:
            if self.config_file.exists():
                with open(self.config_file, 'r') as f:
                    config = json.load(f)
                    if 'last_vhdx' in config and os.path.exists(config['last_vhdx']):
                        self.vhdx_path.set(config['last_vhdx'])
                    if 'last_mount' in config:
                        self.mount_point.set(config['last_mount'])
        except Exception:
            pass

    def on_closing(self):
        """Handle window closing"""
        if self.mounted_partitions:
            if messagebox.askyesno("Confirm Exit",
                                   "VHDX is still mounted. Unmount before exit?"):
                self._unmount_thread()
                time.sleep(1)

        self.root.destroy()


def main():
    """Main entry point"""
    # Check if running as root for certain operations
    if os.geteuid() != 0:
        print("Note: Some operations require sudo privileges.")
        print("You may be prompted for your password.\n")

    root = tk.Tk()
    app = VHDXViewer(root)
    root.protocol("WM_DELETE_WINDOW", app.on_closing)
    root.mainloop()


if __name__ == "__main__":
    main()
