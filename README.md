# ibus-quick-classic-suggestion

Enhanced **聯想字 (Association/Suggestion)** feature for **IBus Quick Classic (速成古典版)** input method.

Adds word suggestions after committing a character, similar to MS Quick Input. For example, after typing 我, a popup shows 們, 國, 家, 方... Press a number key to select, or ESC to dismiss.

## Features

- **359,000+ suggestion entries** built from CC-CEDICT + jieba frequency data
- **Traditional Chinese first** — simplified entries ranked lowest
- **Frequency-ranked** — most commonly used words appear first
- **Display-only suffix** — shows only the next character(s), not the full phrase (like MS Quick)
- **ESC to dismiss** — press ESC to close suggestion popup without selecting
- **Chain suggestions** — selecting a suggestion triggers the next level

## Suggestion Examples

| Input | Suggestions (most common first) |
|-------|-------------------------------|
| 我 | 們, 國, 軍, 會, 家, 校 |
| 中 | 國, 心, 央, 學, 間, 部 |
| 電 | 話, 子, 影, 視, 腦, 力 |
| 大 | 學, 家, 量, 會, 道, 型 |
| 不 | 是, 能, 同, 會, 過, 斷 |
| 好 | 像, 好, 處, 生, 事, 看 |

## Prerequisites

- Linux with IBus
- `ibus-table` and `ibus-table-quick-classic` installed
- Python 3 with `opencc-python-reimplemented` (`pip install opencc-python-reimplemented`)
- `sudo` access (to patch the system ibus launcher)

## Quick Install

```bash
git clone https://github.com/YOUR_USERNAME/ibus-quick-classic-suggestion.git
cd ibus-quick-classic-suggestion
chmod +x install.sh uninstall.sh
./install.sh
```

The installer will:
1. Install Python dependencies
2. Download word data from CC-CEDICT + jieba and build the suggestion database
3. Install the patched engine files
4. Patch the system IBus launcher (requires sudo)
5. Restart IBus

## Uninstall

```bash
./uninstall.sh
```

Restores the original ibus-table-quick-classic to its unmodified state.

## How It Works

The project patches two files from the [ibus-table](https://github.com/acevery/ibus-table) engine:

### Engine Patches (`engine/table.py`)

1. **Auto-enable suggestion mode** — `_sg_mode` is initialized from the database setting instead of hardcoded `False`

2. **Show suggestions after commit** — After `commit_string()`, activate suggestion mode and display candidates

3. **Display suffix only** — Suggestions show only the characters after what was already typed (e.g., shows 們 not 我們)

4. **ESC dismisses suggestions** — Pressing ESC closes the popup without selecting anything

### Database Patches (`engine/tabsqlitedb.py`)

5. **Frequency-first sorting** — Suggestions sorted by usage frequency (most common first), not by phrase length

### Suggestion Database

6. **`build_suggestions.py`** — Downloads jieba word frequency dictionary and CC-CEDICT, converts all entries to Traditional Chinese using OpenCC, and builds a suggestion table with 359,000+ frequency-ranked entries

## File Structure

```
├── LICENSE                    # MIT License
├── README.md                  # This file
├── install.sh                 # Installer script
├── uninstall.sh               # Uninstaller script
├── build_suggestions.py       # Build suggestion database from online sources
├── bin/
│   └── ibus-engine-table      # Custom launcher (sets IBUS_TABLE_LOCATION)
└── engine/
    ├── table.py               # Patched ibus-table engine
    └── tabsqlitedb.py         # Patched database layer
```

## Rebuilding the Suggestion Database

To rebuild with latest word data:

```bash
python3 build_suggestions.py
```

Then restart IBus:

```bash
ibus restart
```

## Adding Custom Suggestions

You can manually add entries to the suggestion database:

```python
import sqlite3
DB = os.path.expanduser('~/.local/share/ibus-table-local/tables/quick-classic.db')
conn = sqlite3.connect(DB)
conn.execute("INSERT INTO suggestion (phrase, freq) VALUES ('我特別詞', 999)")
conn.commit()
conn.close()
```

Higher `freq` values appear first in the suggestion list.

## Technical Details

The suggestion feature already existed in ibus-table but was disabled for Quick Classic because:
- The `suggestion_mode` IME property was `false`
- No `suggestion` table existed in the database
- The `_sg_mode` runtime flag was hardcoded to `False`
- Suggestions were sorted by phrase length (longest first) instead of frequency

This project enables and enhances the feature with proper Traditional Chinese frequency data.

## License

MIT License. See [LICENSE](LICENSE).

The patched engine files are derived from ibus-table (LGPL-2.1+).
Suggestion data is derived from CC-CEDICT (CC BY-SA 4.0) and jieba (MIT).
