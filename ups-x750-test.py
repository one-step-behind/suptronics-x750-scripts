#!/usr/bin/env python
import struct
import smbus
import sys
import time

def readVoltage(bus):
    address = 0x36
    read = bus.read_word_data(address, 2)
    swapped = struct.unpack("<H", struct.pack(">H", read))[0]
    voltage = swapped * 1.25 /1000/16
    return voltage

def readCapacity(bus):
    address = 0x36
    read = bus.read_word_data(address, 4)
    swapped = struct.unpack("<H", struct.pack(">H", read))[0]
    capacity = swapped/256
    return capacity

def readStatus(bus):
    address = 0x36
    read = bus.read_word_data(address, 0x14)
    return struct.unpack("<H", struct.pack(">H", read))[0]

bus = smbus.SMBus(1) # 0 = /dev/i2c-0 (port I2C0), 1 = /dev/i2c-1 (port I2C1)

while True:
    voltageRaw = readVoltage(bus)
    capacityRaw = readCapacity(bus)
    statusRaw = readStatus(bus)
    print("******************")
    print("Voltage raw: " + str(voltageRaw))
    print("Voltage:%5.2fV" % voltageRaw)

    print("Battery:%5i%%" % capacityRaw)
    if capacityRaw >= 100:
        print("Battery FULL")
    elif capacityRaw < 20:
        print("Battery LOW")

    print("Status:%7i" % statusRaw)
    if statusRaw < 512:
        print("USB Power Connected 2A Charging")
    elif statusRaw < 1024:
        print("AC Power Connected 3A Charging")
    else:
        print("No power connected")
    print("******************")
    time.sleep(2)