#!/usr/bin/env python3
import struct
import sys
from pathlib import Path

def inspect_fnt(fnt_path):
    data = fnt_path.read_bytes()
    off = 4  # skip BMF + version
    common_pages = None
    pages_names = []
    chars_records = 0
    sample_pages = []

    while off + 5 <= len(data):
        bid = data[off]
        size = struct.unpack('<I', data[off+1:off+5])[0]
        payload = data[off+5:off+5+size]

        if bid == 2:
            # common block
            vals = struct.unpack('<HHHHHBBBB', payload[:struct.calcsize('<HHHHHBBBB')])
            common_pages = vals[4]
        elif bid == 3:
            # pages block
            parts = payload.split(b'\0')[:-1]
            pages_names = [p.decode('utf-8', errors='ignore') for p in parts]
        elif bid == 4:
            # chars block
            rec_size = 20
            chars_records = size // rec_size
            # sample first/last 5 page indices
            for i in range(min(5, chars_records)):
                rec = payload[i*rec_size:(i+1)*rec_size]
                page = rec[18]
                sample_pages.append(page)
            for i in range(max(0, chars_records-5), chars_records):
                rec = payload[i*rec_size:(i+1)*rec_size]
                page = rec[18]
                sample_pages.append(page)
        off += 5 + size

    print(f"common.pages         = {common_pages}")
    print(f"pages block count    = {len(pages_names)}")
    print(f"pages names          = {pages_names}")
    print(f"chars record count   = {chars_records}")
    print(f"sample page indices  = {sample_pages}")

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python inspect_fnt.py path/to/file.fnt")
        sys.exit(1)
    inspect_fnt(Path(sys.argv[1]))
