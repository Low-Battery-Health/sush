#!/bin/zsh --no-rcs
SUSH_HASH="7b64c797eb547a41019f6185ddd7d0377dbb1a96125533f90eb3af28365dd249"
SUDOERS_HASH="4037056279c20a24c14fffab8b832b816e4600417c61a6bce19832416f303a1b"
SUSH_FILE="/usr/local/bin/sush"
SUDOERS_FILE="/etc/sudoers.d/sush_config"
main() {
if [[ -f "$SUSH_FILE" && $(sed '2d' "$SUSH_FILE" | shasum -a 256 | awk '{print $1}') == "$SUSH_HASH" && -O "$SUSH_FILE" && -f "$SUDOERS_FILE" && $(shasum -a 256 "$SUDOERS_FILE" | awk '{print $1}') == "$SUDOERS_HASH" && -O "$SUDOERS_FILE" ]]; then
echo "sush is already installed. Replace files? (y/N) "
read -u 0 -k 1 repl

if [[ "$repl" != $'\n' ]]; then
echo ""
fi

if [[ "${repl:l}" != "y" ]]; then
echo "Exiting..."
exit 1
fi
fi

rm -f "$SUSH_FILE" "$SUDOERS_FILE"

mkdir -p /usr/local/bin
chmod 755 /usr/local/bin

cat << 'EOF' > "$SUSH_FILE"
#!/bin/zsh --no-rcs
SELF_HASH="7b64c797eb547a41019f6185ddd7d0377dbb1a96125533f90eb3af28365dd249"
SUDOERS_HASH="4037056279c20a24c14fffab8b832b816e4600417c61a6bce19832416f303a1b"
SUDOERS_FILE="/etc/sudoers.d/sush_config"
corruption() {
echo "sush is corrupted. Please reinstall sush via http://placeholder.link.com/install."
exit 1
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
# if [[ $(curl placeholder.link.com | sh) -ne 0 ]]; then
# echo "Update failed!"
# else
# echo "Successfully updated to version $VERSION"
# fi
;;
"--version") echo "sush version 1.2 (Build number 202602a01v2)";;
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
read -u 0 -k 1 elev

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

