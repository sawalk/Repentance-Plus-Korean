#!/usr/bin/env python3
import struct
import argparse
from pathlib import Path

# 한글 음절 및 자모 범위
HANGUL_SYLLABLE_START = 0xAC00
HANGUL_SYLLABLE_END   = 0xD7A3
HANGUL_JAMO_START     = 0x3130
HANGUL_JAMO_END       = 0x3163

# 포맷 정의
COMMON_FMT = '<HHHHHBBBB'
COMMON_SIZE = struct.calcsize(COMMON_FMT)
CHAR_FMT   = '<IHHHHhhHBb'
CHAR_SIZE  = struct.calcsize(CHAR_FMT)


def parse_blocks(data: bytes):
    """Parse blocks into list of (id, payload)."""
    blocks = []
    off = 4  # 헤더 'BMF'+version
    while off + 5 <= len(data):
        bid = data[off]
        size = struct.unpack('<I', data[off+1:off+5])[0]
        payload = data[off+5:off+5+size]
        blocks.append((bid, payload))
        off += 5 + size
    return blocks


def build_fnt(blocks):
    """Rebuild full fnt bytes from blocks list."""
    out = bytearray(b'BMF' + b'\x03')  # BMF + version 3
    for bid, payload in blocks:
        out += bytes([bid]) + struct.pack('<I', len(payload)) + payload
    return out


def update_fnt_with_hangul(target_fnt, source_fnt, new_atlas, output_fnt):
    tgt_data = target_fnt.read_bytes()
    src_data = source_fnt.read_bytes()

    tgt_blocks = parse_blocks(tgt_data)
    src_blocks = parse_blocks(src_data)

    new_blocks = []

    # 1) common block: increment pages
    for bid, payload in tgt_blocks:
        if bid == 2:
            vals = list(struct.unpack(COMMON_FMT, payload[:COMMON_SIZE]))
            vals[4] += 1
            new_payload = struct.pack(COMMON_FMT, *vals)
            new_blocks.append((2, new_payload))
        else:
            new_blocks.append((bid, payload))

    # 2) pages block: append new atlas
    tmp = []
    for bid, payload in new_blocks:
        if bid == 3:
            names = payload.split(b'\0')[:-1]
            names.append(new_atlas.encode('utf-8'))
            new_payload = b'\0'.join(names) + b'\0'
            tmp.append((3, new_payload))
        else:
            tmp.append((bid, payload))
    new_blocks = tmp

    # 3) Prepare source glyphs for Hangul syllables and jamo
    src_map = {}
    for bid, payload in src_blocks:
        if bid == 4:
            for i in range(len(payload) // CHAR_SIZE):
                rec = payload[i*CHAR_SIZE:(i+1)*CHAR_SIZE]
                cid = struct.unpack('<I', rec[:4])[0]
                # include syllables and jamo ranges
                if ((HANGUL_SYLLABLE_START <= cid <= HANGUL_SYLLABLE_END)
                        or (HANGUL_JAMO_START <= cid <= HANGUL_JAMO_END)):
                    src_map[cid] = rec
            break

    # Determine new page index
    page_count = 0
    for bid, payload in new_blocks:
        if bid == 3:
            page_count = len(payload.split(b'\0')) - 1
            break
    new_page_index = page_count - 1

    # 4) Replace Hangul glyphs
    tmp = []
    for bid, payload in new_blocks:
        if bid == 4:
            new_payload = bytearray()
            for i in range(len(payload) // CHAR_SIZE):
                rec = bytearray(payload[i*CHAR_SIZE:(i+1)*CHAR_SIZE])
                cid = struct.unpack('<I', rec[:4])[0]
                if cid in src_map:
                    rec = bytearray(src_map[cid])
                    rec[18] = new_page_index
                new_payload += rec
            tmp.append((4, bytes(new_payload)))
        else:
            tmp.append((bid, payload))
    new_blocks = tmp

    # 5) Build and write
    out_bytes = build_fnt(new_blocks)
    output_fnt.write_bytes(out_bytes)
    print(f"Updated .fnt saved to: {output_fnt}")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Append a new atlas and replace Hangul glyphs (syllables & jamo) in target .fnt from source .fnt')
    parser.add_argument('target', help='Target .fnt')
    parser.add_argument('source', help='Source .fnt with Hangul')
    parser.add_argument('atlas', help='New atlas PNG name')
    parser.add_argument('output', help='Output .fnt')
    args = parser.parse_args()

    update_fnt_with_hangul(Path(args.target), Path(args.source), args.atlas, Path(args.output))
