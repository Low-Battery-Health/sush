# sush
A fast and secure convenience tool that allows for passwordless root access on any account.

Get easy access to root privileges without having to type your password or write configuration files (other than at installation in which the installer script does automatically). Once installed, running sush automatically elevates to a root shell, while ```sush --exec <command>``` can be used to execute a specific command as root without the overhead of a full shell.

[![Version](https://img.shields.io/badge/version-1.3-ff8000)](https://github.com/Low-Battery-Health/sush/blob/main/install_sush.sh)
[![Version](https://img.shields.io/badge/speed-fast-0080ff)](https://www.youtube.com/watch?v=dQw4w9WgXcQ)
[![License](https://img.shields.io/badge/license-GPLv3.0-8000ff)](LICENSE)

## Why sush
- Extremely fast and lightweight
- Auto updating
- A quick ```--exec``` option to run commands without launching a shell
- Automatic integrity checks to detect corruption
- Instant install
- Extremely easy uninstallation (```sush --uninstall```)

# How to install
sush requires Linux or MacOS to run.
```bash
curl -sL "https://raw.githubusercontent.com/Low-Battery-Health/sush/refs/heads/main/install_sush.sh" | sh
```
Or manually download the ```install_sush.sh``` file and run
```bash
./install_sush.sh
```

> **Note:** The installer will automatically upgrade itself to root if not already via sudo. You may be prompted to type in your password.

### How to install on another partition/volume or directory
```bash
./install_sush.sh --chroot "/path/to/other/directory"
```

### Verify installation
```bash
sush --version
```
This should display the version and build number (eg. ```sush version 1.3 (Build number 202603a00p6)```)

If it says ```zsh: command not found: sush``` or that sush is corrupted, you may need to retry the installation.

# Usage
To get started, simply type ```sush``` in the terminal for a root shell.
```bash
sush
```
Expected output:
```bash
Low-Battery-Health@LBH-Debian:~$ sush
root@LBH-Debian:~# whoami
root
root@LBH-Debian:~#
```
To return to user privileges, exit the shell.
```
exit
```

To execute a singular command without spawning a shell, type ```sush --exec <command>```.

Example:
```bash
sush --exec whoami
```

For more usage information, show the help menu.
```bash
sush --help
```

# Licence
This project is licensed under the GNU Public License v3.0 Licence. [See more](LICENSE).
