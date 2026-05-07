#!/usr/bin/env python3
import sqlite3
import urllib.request
import gzip
import re
import os
from collections import defaultdict
from opencc import OpenCC

cc = OpenCC('s2t')

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
LOCAL_DIR = os.environ.get(
    'IBUS_TABLE_LOCAL',
    os.path.expanduser('~/.local/share/ibus-table-local'))
DB = os.path.join(LOCAL_DIR, 'tables', 'quick-classic.db')

print("Downloading jieba word frequency dictionary...")
url = 'https://raw.githubusercontent.com/fxsjy/jieba/refs/heads/master/jieba/dict.txt'
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
data = urllib.request.urlopen(req, timeout=60).read().decode('utf-8')
lines = data.strip().split('\n')
print(f"  jieba: {len(lines)} entries")

print("Downloading CC-CEDICT...")
url2 = "https://www.mdbg.net/chinese/export/cedict/cedict_1_0_ts_utf-8_mdbg.txt.gz"
req2 = urllib.request.Request(url2, headers={'User-Agent': 'Mozilla/5.0'})
data2 = urllib.request.urlopen(req2, timeout=60).read()
text2 = gzip.decompress(data2).decode('utf-8')
print(f"  CC-CEDICT: parsed")

# Parse jieba - format: word freq pos
# Convert simplified to traditional and use the freq
jieba_freq = defaultdict(int)
for line in lines:
    parts = line.strip().split()
    if len(parts) < 2:
        continue
    word = parts[0]
    try:
        freq = int(parts[1])
    except ValueError:
        continue
    if not (2 <= len(word) <= 4):
        continue
    if not all('\u4e00' <= ch <= '\u9fff' for ch in word):
        continue
    # Convert to traditional
    trad = cc.convert(word)
    jieba_freq[trad] = max(jieba_freq[trad], freq)

print(f"  jieba Traditional: {len(jieba_freq)}")

# Parse CC-CEDICT for additional traditional words
pattern = re.compile(r'^(\S+)\s+(\S+)\s+\[.*?\]\s+/(.*)/')
cedict_words = set()
for line in text2.strip().split('\n'):
    if line.startswith('#'):
        continue
    m = pattern.match(line)
    if not m:
        continue
    trad = m.group(1)
    if 2 <= len(trad) <= 4:
        if all('\u4e00' <= ch <= '\u9fff' for ch in trad):
            cedict_words.add(trad)

print(f"  CC-CEDICT Traditional: {len(cedict_words)}")

# Merge: jieba provides frequency, CC-CEDICT provides extra traditional words
suggestions = dict(jieba_freq)

for word in cedict_words:
    if word not in suggestions:
        suggestions[word] = 50  # low default freq for rare traditional-only words

print(f"  Total merged: {len(suggestions)}")

# Update database
conn = sqlite3.connect(DB)
c = conn.cursor()

c.execute('DELETE FROM main.suggestion')
conn.commit()

entries = list(suggestions.items())
batch_size = 10000
for i in range(0, len(entries), batch_size):
    batch = entries[i:i+batch_size]
    c.executemany('INSERT INTO suggestion (phrase, freq) VALUES (?, ?)', batch)
    conn.commit()

c.execute('DROP INDEX IF EXISTS suggestion_phrase_idx')
conn.commit()
c.execute('CREATE INDEX suggestion_phrase_idx ON suggestion (phrase)')
conn.commit()

count = c.execute('SELECT COUNT(*) FROM suggestion').fetchone()[0]
print(f"\nDatabase: {count} entries (all Traditional Chinese)")

print("\nFrequency-sorted lookups:")
for char in ['我', '中', '電', '大', '學', '不', '好', '人', '國', '愛',
             '開', '時', '食', '走', '天', '心', '花', '水', '風', '山']:
    c.execute(
        "SELECT phrase, freq FROM suggestion WHERE phrase LIKE ? "
        "ORDER BY freq DESC, length(phrase) ASC LIMIT 10",
        (char + '%',))
    results = c.fetchall()
    if results:
        display = ', '.join(f'{r[0]}({r[1]})' for r in results[:6])
        print(f"  {char}: {display}")

conn.close()
print("\nDone!")
