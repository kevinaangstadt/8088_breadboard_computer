# simulate calucate crc value from input data

def little_endian(crc):
    return f"0x{crc & 0xFF:02X}{crc >> 8:02X}"

def big_endian(crc):
    return f"0x{crc:04X}"

def crc16(data, num_bytes, all=False, little_endian=False):
    crc = 0x0000
    for i in range(num_bytes):
      crc ^= data[i]
      for j in range(8):
        if crc & 1:
          crc = (crc >> 1) ^ 0xA001
        else:
          crc >>= 1
      if all:
        if little_endian:
          print(little_endian(crc))
        else:
          print(big_endian(crc))
    return crc

def main():
    import argparse
    import sys

    parser = argparse.ArgumentParser(description='Calculate CRC16 of input data')
    parser.add_argument('file', help='File to read data from')
    parser.add_argument('num_bytes', nargs='?', type=int, help='Number of bytes to read from file')
    parser.add_argument('--all', '-a', action='store_true', help='Print all CRC values up to the last byte')
    parser.add_argument('--little-endian', '-l', action='store_true', help='Print CRC value in little endian')
    parser.add_argument('--no-newline', '-n', action='store_true', help='Do not print newline at the end of the output')

    args = parser.parse_args()


    # read data from file in first argument
    data = []
    with open(args.file, 'rb') as f:
        data = f.read()

    # read number of bytes in second argument
    # if second argument does not exist, use all data
    if args.num_bytes is None:
        num_bytes = len(data)
    else:
      num_bytes = args.num_bytes

    crc = crc16(data, num_bytes, all=args.all, little_endian=args.little_endian)
    
    if not args.all:
      if args.little_endian:
        # print as little endian
        print(little_endian(crc), end='')
      else:
        # print as hex
        print(big_endian(crc), end='')
      
      if not args.no_newline:
        print()

if __name__ == '__main__':
    main()