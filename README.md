# sush
A convenience tool that allows for passwordless root access on any account.

[![Version](https://img.shields.io/badge/version-1.3-ff8000)](https://github.com/Low-Battery-Health/sush/blob/main/install_sush.sh)
[![License](https://img.shields.io/badge/license-GPLv3.0-0080ff)](LICENSE)

### Features
- Auto updating
- A quick ```--exec``` option to run commands without launching a shell
- Integrity checks to detect corruption

# How to install
sush requires Linux or MacOS to run.
```bash
curl -sL "https://raw.githubusercontent.com/Low-Battery-Health/sush/refs/heads/main/install_sush.sh" | sh
```
Or manually download the ```install_sush.sh``` file and run
```bash
./install_sush.sh
```

> **Note:** The installer will automatically upgrade itself to root if not already

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

# Licence
This project is licensed under the GNU Public License v3.0 License. [See more](LICENSE).
