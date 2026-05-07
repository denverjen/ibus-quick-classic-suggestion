#!/bin/bash
set -e

echo "=== ibus-quick-classic-suggestion uninstaller ==="
echo ""

echo "[1/3] Restoring system launcher..."
sudo bash -c 'cat > /usr/libexec/ibus-engine-table << EOF
#!/bin/sh
prefix=/usr
exec_prefix=/usr
datarootdir=\${prefix}/share
datadir=\${datarootdir}
export IBUS_TABLE_LOCATION=\${prefix}/share/ibus-table
export IBUS_TABLE_LIB_LOCATION=\${exec_prefix}/libexec

for arg in \$@; do
	case \$arg in
	--xml | -x)
		exec /usr/bin/python3 \${prefix}/share/ibus-table/engine/main.py --xml;;
	--help | -h)
		exec /usr/bin/python3 \${prefix}/share/ibus-table/engine/main.py \$@;;
        *)
                if [ "x\${IBUS_TABLE_PROFILE}" != "x" ]; then
                    exec /usr/bin/python3 \${prefix}/share/ibus-table/engine/main.py --profile \$@
                else
                    exec /usr/bin/python3 \${prefix}/share/ibus-table/engine/main.py \$@
                fi
                exit 0
	esac
done
EOF
chmod +x /usr/libexec/ibus-engine-table'
echo ""

echo "[2/3] Removing local files..."
rm -rf "$HOME/.local/share/ibus-table-local"
rm -f "$HOME/.local/bin/ibus-engine-table"
echo ""

echo "[3/3] Restarting ibus..."
killall -9 ibus-daemon 2>/dev/null || true
sleep 2
ibus-daemon -drx
echo ""

echo "=== Uninstallation complete! ==="
echo "ibus-table-quick-classic has been restored to its original state."
