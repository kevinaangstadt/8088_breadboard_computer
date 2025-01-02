# simulate calucate crc value from input data

import sys

def crc16(data, num_bytes):
    crc = 0x0000
    for i in range(num_bytes):
      crc ^= data[i]
      for j in range(8):
        if crc & 1:
          crc = (crc >> 1) ^ 0xA001
        else:
          crc >>= 1
    return crc

def main():
    # read data from file in first argument
    data = []
    with open(sys.argv[1], 'rb') as f:
        data = f.read()

    # read number of bytes in second argument
    # if second argument does not exist, use all data
    if len(sys.argv) < 3:
        # last 2 bytes are crc value
        num_bytes = len(data) - 2
    else:
      num_bytes = int(sys.argv[2])

    crc = crc16(data, num_bytes)
    
    # print as hex
    print(hex(crc))

if __name__ == '__main__':
    main()