#!/bin/zsh --no-rcs
main() {
ROOT_DIR=""
if [[ "$1" == "--chroot" && -d "$2" ]]; then
ROOT_DIR="${2%/}"
fi
SUSH_HASH="26b74a21d055106817a013e66d91f2e1895de26df16a0140c2f495f6456e2b06"
SUDOERS_HASH="4037056279c20a24c14fffab8b832b816e4600417c61a6bce19832416f303a1b"
SUSH_FILE="$ROOT_DIR/usr/local/bin/sush"
SUDOERS_FILE="$ROOT_DIR/etc/sudoers.d/sush_config"
if [[ -f "$SUSH_FILE" && $(sed '2d' "$SUSH_FILE" | shasum -a 256 | awk '{print $1}') == "$SUSH_HASH" && -O "$SUSH_FILE" && -f "$SUDOERS_FILE" && $(shasum -a 256 "$SUDOERS_FILE" | awk '{print $1}') == "$SUDOERS_HASH" && -O "$SUDOERS_FILE" ]]; then
echo "sush is already installed. Replace files? (y/N) "
read -k 1 repl

if [[ "$repl" != $'\n' ]]; then
echo ""
fi

if [[ "${repl:l}" != "y" ]]; then
echo "Exiting..."
exit 1
fi
fi

rm -f "$SUSH_FILE" "$SUDOERS_FILE"

mkdir -p "$ROOT_DIR/usr/local/bin" "$ROOT_DIR/etc/sudoers.d"
chmod 755 "$ROOT_DIR/usr/local/bin" "$ROOT_DIR/etc/sudoers.d"

cat << 'EOF' > "$SUSH_FILE"
#!/bin/zsh --no-rcs
SELF_HASH="26b74a21d055106817a013e66d91f2e1895de26df16a0140c2f495f6456e2b06"
SUDOERS_HASH="4037056279c20a24c14fffab8b832b816e4600417c61a6bce19832416f303a1b"
SUDOERS_FILE="/etc/sudoers.d/sush_config"

BUILD_NUM="202603a00p6"

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

if [[ $EUID -ne 0 ]]; then
exec sudo "$0" "$@"
else

if [[ ! -f "$SUDOERS_FILE" || $(shasum -a 256 "$SUDOERS_FILE" | awk '{print $1}') != "$SUDOERS_HASH" || ! -O "$SUDOERS_FILE" ]]; then
corruption
fi

if [[ $(sed '2d' "$0" | shasum -a 256 | awk '{print $1}') != "$SELF_HASH" || ! -O "$0" ]]; then
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
*) echo -e "sush - spawn a root shell\n\nusage: sush, sush [options...], sush --exec [command...]\n\nOptions:\n    --uninstall  uninstall sush\n    --update     update sush to the latest version\n    --version    display version information\n    --exec       execute a command\n    --help       display this menu";;
esac

fi

EOF

echo -e "ALL ALL=(ALL:ALL) NOPASSWD: /usr/local/bin/sush\n" > "$SUDOERS_FILE"
if [[ "$(uname)" == "Darwin" || "$(uname)" == *BSD* ]]; then
chown root:wheel "$SUSH_FILE" "$SUDOERS_FILE"
else
chown root:root "$SUSH_FILE" "$SUDOERS_FILE"
fi

chmod 755 "$SUSH_FILE"
chmod 0440 "$SUDOERS_FILE"

echo "Installation successful!"
}

if [[ 1 ]]; then
if [[ $EUID -ne 0 ]]; then
echo "You must be root to install sush. Elevate privileges? (y/N) "
read -k 1 elev

if [[ "$elev" != $'\n' ]]; then
echo ""
fi

if [[ "${elev:l}" == "y" ]]; then
echo "Elevating privileges..."
exec sudo "$0" "$@"
else
echo "Exiting..."
exit 1
fi
fi
main
fi
