import struct
import sys

def shift_glyphs_yoffset(input_path, output_path, shift_amount):
    with open(input_path, 'rb') as f:
        data = f.read()

    # BMFont 파일은 "BMF" + version (1바이트) 로 시작함
    if data[:3] != b'BMF':
        print("입력 파일이 BMFont 바이너리 fnt 파일이 아닙니다.")
        return

    header = data[:4]  # "BMF" + version
    new_data = header
    offset = 4

    # 파일 전체를 블록 단위로 순회
    while offset < len(data):
        if offset + 5 > len(data):
            print("파일 구조 오류")
            break

        block_id = data[offset]
        block_size = struct.unpack("<I", data[offset+1:offset+5])[0]
        block_data = data[offset+5:offset+5+block_size]

        if block_id == 4:
            # 블록 ID 4: 각 글리프 정보, 레코드당 20바이트
            record_size = 20
            count = block_size // record_size
            new_block_data = b""
            for i in range(count):
                rec = block_data[i*record_size:(i+1)*record_size]
                # 레코드 포맷: <IHHHHhhHBb
                fields = list(struct.unpack("<IHHHHhhHBb", rec))
                # fields: [id, x, y, width, height, xoffset, yoffset, xadvance, page, chnl]
                # yoffset는 인덱스 6 (signed short)
                fields[6] = fields[6] + shift_amount
                new_rec = struct.pack("<IHHHHhhHBb", *fields)
                new_block_data += new_rec
            # 블록 헤더 재작성 (ID + 새로운 block size, block_size는 그대로 record_size*count)
            new_block_header = bytes([block_id]) + struct.pack("<I", len(new_block_data))
            new_data += new_block_header + new_block_data
        else:
            # 다른 블록은 그대로 복사
            new_data += data[offset:offset+5+block_size]
        offset += 5 + block_size

    with open(output_path, 'wb') as f:
        f.write(new_data)
    print(f"모든 글리프의 yoffset이 {shift_amount} 픽셀 만큼 증가된 fnt 파일이 생성되었습니다: {output_path}")

if __name__ == '__main__':
    if len(sys.argv) != 3 and len(sys.argv) != 4:
        print("사용법: python shift_glyphs.py input.fnt output.fnt [shift_amount]")
        print("예: python shift_glyphs.py pftempestasevencondensed.fnt pftempestasevencondensed_shifted.fnt 1")
        sys.exit(1)
    input_fnt = sys.argv[1]
    output_fnt = sys.argv[2]
    shift = int(sys.argv[3]) if len(sys.argv) == 4 else 1  # 기본 shift 값은 1
    shift_glyphs_yoffset(input_fnt, output_fnt, shift)
