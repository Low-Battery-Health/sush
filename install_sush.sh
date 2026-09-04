#!/bin/sh

#   ========================================================================
#
#   install_sush.sh - Official sush installer script
#
#   Copyright (C) 2026  Low Battery Health
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published
#   by the Free Software Foundation, version 3 only.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
#   ========================================================================

check_hash() {
if command -v sha256sum > /dev/null 2>/dev/null; then
[ "$(sha256sum "$1" | awk '{print $1}')" = "$2" ]
elif command -v shasum > /dev/null 2>/dev/null; then
[ "$(shasum -a 256 "$1" | awk '{print $1}')" = "$2" ]
else
printf "Warning: neither shasum nor sha256sum found. Skip integrity check? (y/N): "
read skip
if [ "$skip" != "y" ] && [ "$skip" != "Y" ]; then
return 1
else
return 0
fi
fi
}

main() {
ROOT_DIR=""
ETC_DIR="/etc"
if [ "$1" = "--chroot" ] && [ -d "$2" ]; then
ROOT_DIR="${2%/}"
fi
if [ "$(uname)" = "Darwin" ]; then
ETC_DIR="/private/etc"
fi
SUSH_HASH="03be2776390800ea4144dcd8bf0d94a98c411c68eb5550529bf7bed5c6ce978a"
SUDOERS_HASH="61137b81f7f535880d5a3e917e8d1f530fc5165ac36f439a849c9b28ac35ec08"
SUSH_FILE="$ROOT_DIR/usr/local/bin/sush"
SUDOERS_FILE="$ROOT_DIR$ETC_DIR/sudoers.d/sush_config"
if ! ( [ "$(uname)" = "Darwin" ] && launchctl list | grep -q "com.apple.recoveryosd" > /dev/null ) && [ -f "$SUSH_FILE" ] && sed '/^SELF_HASH=/d' "$SUSH_FILE" | check_hash "-" "$SUSH_HASH" && [ -O "$SUSH_FILE" ] && [ -f "$SUDOERS_FILE" ] && check_hash "$SUDOERS_FILE" "$SUDOERS_HASH" && [ -O "$SUDOERS_FILE" ]; then
printf "sush is already installed. Replace files? (y/N): "
read repl

if [ "$repl" != "y" ] && [ "$repl" != "Y" ]; then
echo "Exiting..."
exit 1
fi
fi

rm -f "$SUSH_FILE" "$SUDOERS_FILE"

mkdir -p "$ROOT_DIR/usr/local/bin" "$ROOT_DIR$ETC_DIR/sudoers.d"
chmod 755 "$ROOT_DIR/usr/local/bin" "$ROOT_DIR$ETC_DIR/sudoers.d"

cat << 'EOF' > "$SUSH_FILE"
#!/bin/zsh --no-rcs

#   ========================================================================
#
#   sush - secure zsh wrapper for privilege elevation
#
#   Copyright (C) 2026  Low Battery Health
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published
#   by the Free Software Foundation, version 3 only.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
#   ========================================================================

SELF_HASH="03be2776390800ea4144dcd8bf0d94a98c411c68eb5550529bf7bed5c6ce978a"
SUDOERS_HASH="61137b81f7f535880d5a3e917e8d1f530fc5165ac36f439a849c9b28ac35ec08"
SUDOERS_FILE="/etc/sudoers.d/sush_config"

BUILD_NUM="202603a01p3"

check_hash() {
if command -v sha256sum > /dev/null 2>/dev/null; then
[ "$(sha256sum "$1" | awk '{print $1}')" = "$2" ]
elif command -v shasum > /dev/null 2>/dev/null; then
[ "$(shasum -a 256 "$1" | awk '{print $1}')" = "$2" ]
else
printf "Warning: neither shasum nor sha256sum found. Skip integrity check? (y/N): "
read skip
if [ "$skip" != "y" ] && [ "$skip" != "Y" ]; then
return 1
else
return 0
fi
fi
}

corruption() {
echo "sush is corrupted. Please reinstall sush via https://raw.githubusercontent.com/Low-Battery-Health/sush/refs/heads/main/install_sush.sh."
exit 1
}

update_sush() {
if ! LATEST_DATA="$(curl -sSf "https://raw.githubusercontent.com/Low-Battery-Health/sush/refs/heads/main/LATEST" 2>/dev/null)"; then
echo "Could not check for updates. (Server unreachable)"
return 1
fi
read -r LATEST_VERS LATEST_NUM HASH <<< "$LATEST_DATA"
if [[ "$LATEST_NUM" == "$BUILD_NUM" ]]; then
echo "Already latest version."
return 0
fi
TMP_DIR="/tmp/sush"
mkdir -p "$TMP_DIR"
if ! curl -sSf "https://raw.githubusercontent.com/Low-Battery-Health/sush/refs/heads/main/install_sush.sh" -o "$TMP_DIR/install.sh" 2>/dev/null || [[ "$(shasum -a 256 "$TMP_DIR/install.sh" | awk '{print $1}')" != "$HASH" ]]; then
echo "There was an error installing the updates."
rm -rf "$TMP_DIR"
return 1
fi
chmod +x "$TMP_DIR/install.sh"
if ! "$TMP_DIR/install.sh" > /dev/null; then
echo "The updater ran into a problem."
rm -rf "$TMP_DIR"
return 1
fi
echo "Successfully updated to version $LATEST_VERS."
rm -rf "$TMP_DIR"
}

if [ "$(id -u)" -ne 0 ]; then
exec sudo "$0" "$@"
else

if [ ! -f "$SUDOERS_FILE" ] || ! check_hash "$SUDOERS_FILE" "$SUDOERS_HASH" || [ ! -O "$SUDOERS_FILE" ]; then
corruption
fi

if ! sed '/^SELF_HASH=/d' "$0" | check_hash "-" "$SELF_HASH" || [ ! -O "$0" ]; then
corruption
fi

update_sush > /dev/null

case $1 in
"") exec zsh;;
"--exec")
shift
exec "$@"
;;
 "--uninstall")
echo "Uninstalling sush..."
rm -f /etc/sudoers.d/sush_config /usr/local/bin/sush
echo "Uninstallation successful!"
;;
"--update")
update_sush
;;
"--version") echo "sush version 1.3 (Build number $BUILD_NUM)";;
*) printf "sush - spawn a root shell\n\nusage: sush, sush [options...], sush --exec [command...]\n\nOptions:\n    --uninstall  uninstall sush\n    --update     update sush to the latest version\n    --version    display version information\n    --exec       execute a command\n    --help       display this menu\n";;
esac

fi

EOF

printf "ALL ALL=(ALL:ALL) NOPASSWD: /usr/local/bin/sush\n" > "$SUDOERS_FILE"
case "$(uname)" in
Darwin|*BSD*) chown root:wheel "$SUSH_FILE" "$SUDOERS_FILE" ;;
*) chown root:root "$SUSH_FILE" "$SUDOERS_FILE" ;;
esac

chmod 755 "$SUSH_FILE"
chmod 0440 "$SUDOERS_FILE"

echo "Installation successful!"
}

if [ 1 ]; then

if [ -n "$1" ]; then
if [ "$1" = "--chroot" ]; then
if [ ! -d "$2" ]; then
echo "$0: no such directory: $2"
exit 1
fi
else
echo "$0: invalid option: $1"
exit 1
fi
fi

if [ "$(id -u)" -ne 0 ]; then
printf "You must be root to install sush. Elevate privileges? (y/N): "
read elev

if [ "$elev" = "y" ] || [ "$elev" = "Y" ]; then
echo "Elevating privileges..."
exec sudo "$0" "$@"
else
echo "Exiting..."
exit 1
fi
fi
main "$@"
fi
