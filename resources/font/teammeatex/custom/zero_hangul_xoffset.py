import struct
import argparse
from pathlib import Path

# 한글 음절 범위
HANGUL_START = 0xAC00
HANGUL_END   = 0xD7A3


def modify_hangul_metrics(input_fnt: Path, output_fnt: Path, xoffset_val: int = None, xadvance_val: int = None):
    data = input_fnt.read_bytes()
    new_data = bytearray()

    # 헤더 ("BMF" + version)
    new_data += data[:4]
    offset = 4

    # 블록 순회
    while offset < len(data):
        block_id = data[offset]
        block_size = struct.unpack("<I", data[offset+1:offset+5])[0]
        block_data = data[offset+5:offset+5+block_size]

        if block_id == 4:  # chars 블록
            record_size = 20
            count = block_size // record_size
            modified = bytearray()
            for i in range(count):
                rec = block_data[i*record_size:(i+1)*record_size]
                fields = list(struct.unpack("<IHHHHhhHBb", rec))
                char_id = fields[0]
                # 한글이면 지정된 값으로 설정
                if HANGUL_START <= char_id <= HANGUL_END:
                    fields[6] = 3
                    if xoffset_val is not None:
                        fields[5] = xoffset_val  # xoffset index
                    if xadvance_val is not None:
                        fields[7] = xadvance_val  # xadvance index
                modified += struct.pack("<IHHHHhhHBb", *fields)
            # 새로운 블록 헤더 + 데이터
            new_data += bytes([block_id]) + struct.pack("<I", len(modified)) + modified
        else:
            # 다른 블록은 그대로 복사
            new_data += data[offset:offset+5+block_size]
        offset += 5 + block_size

    output_fnt.write_bytes(new_data)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="한글 음절 범위의 xoffset, xadvance 값을 설정하는 스크립트"
    )
    parser.add_argument("input", help="원본 .fnt 파일 경로")
    parser.add_argument("output", help="변경된 .fnt 파일 저장 경로")
    parser.add_argument("--xoffset", type=int, help="설정할 xoffset 값 (예: 0)")
    parser.add_argument("--xadvance", type=int, help="설정할 xadvance 값 (예: 0)")
    args = parser.parse_args()

    inp = Path(args.input)
    out = Path(args.output)
    modify_hangul_metrics(inp, out, xoffset_val=args.xoffset, xadvance_val=args.xadvance)
    print(f"완료: {out}")