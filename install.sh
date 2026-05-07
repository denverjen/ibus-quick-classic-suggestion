#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOCAL_DIR="$HOME/.local/share/ibus-table-local"

echo "=== ibus-quick-classic-suggestion installer ==="
echo ""

# Step 1: Install dependencies
echo "[1/6] Installing dependencies..."
pip install opencc-python-reimplemented 2>/dev/null || pip3 install opencc-python-reimplemented 2>/dev/null
echo ""

# Step 2: Build suggestion database
echo "[2/6] Building suggestion database from CC-CEDICT + jieba..."
mkdir -p "$LOCAL_DIR/tables" "$LOCAL_DIR/engine" "$LOCAL_DIR/icons"
cp /usr/share/ibus-table/tables/quick-classic.db "$LOCAL_DIR/tables/"
cp /usr/share/ibus-table/icons/quick-classic.png "$LOCAL_DIR/icons/" 2>/dev/null || true
python3 "$SCRIPT_DIR/build_suggestions.py"
echo ""

# Step 3: Install patched engine
echo "[3/6] Installing patched engine..."
cp "$SCRIPT_DIR/engine/table.py" "$LOCAL_DIR/engine/table.py"
cp "$SCRIPT_DIR/engine/tabsqlitedb.py" "$LOCAL_DIR/engine/tabsqlitedb.py"
cp /usr/share/ibus-table/engine/*.py "$LOCAL_DIR/engine/"
echo ""

# Step 4: Install launcher
echo "[4/6] Installing launcher..."
mkdir -p "$HOME/.local/bin"
cp "$SCRIPT_DIR/bin/ibus-engine-table" "$HOME/.local/bin/ibus-engine-table"
chmod +x "$HOME/.local/bin/ibus-engine-table"
echo ""

# Step 5: Patch system launcher (requires sudo)
echo "[5/6] Patching system launcher (requires sudo)..."
sudo cp "$SCRIPT_DIR/bin/ibus-engine-table" /usr/libexec/ibus-engine-table
sudo chmod +x /usr/libexec/ibus-engine-table
echo ""

# Step 6: Restart ibus
echo "[6/6] Restarting ibus..."
killall -9 ibus-daemon 2>/dev/null || true
sleep 2
ibus-daemon -drx
sleep 3
ibus engine table:quick-classic 2>/dev/null || true
echo ""

echo "=== Installation complete! ==="
echo ""
echo "Switch to Quick Classic (速成古典版) and type any Chinese character."
echo "You should see 聯想字 suggestions appear."
echo "Press ESC to dismiss suggestions."
echo ""
echo "To uninstall: bash $SCRIPT_DIR/uninstall.sh"
