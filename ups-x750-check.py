#!/usr/bin/python
# coding: utf-8

import struct
import smbus
import sys
import time
import os
#import subprocess

# initially wait some seconds until time is correctly set from RTC hardware clock or internet
time.sleep(30)

# Pfad zum Log-File
logfile = '/home/volumio/log/Raspi_UPS_X750_HAT.log'

# Device addresses
device_address = 0x36
i2c_port = 1  # 0 = /dev/i2c-0 (port I2C0), 1 = /dev/i2c-1 (port I2C1)

voltageMin = 3.3
capacityMin = 0

# Global vars
voltageBefore = None
trendVoltage = 0
capacityBefore = None
trendCapacity = 0

bus = smbus.SMBus(i2c_port)

# Read UPS Voltage
def readVoltage(bus):
    read = bus.read_word_data(device_address, 2)
    swapped = struct.unpack("<H", struct.pack(">H", read))[0]
    voltage = swapped * 1.25 /1000/16 # X750 UPS HAT
    return voltage

# Read UPS capacity
def readCapacity(bus):
    read = bus.read_word_data(device_address, 4)
    swapped = struct.unpack("<H", struct.pack(">H", read))[0]
    capacity = (swapped / 256)
    return capacity

# Read UPS status
def readStatus(bus):
    read = bus.read_word_data(device_address, 0x14)
    return struct.unpack("<H", struct.pack(">H", read))[0]

# Aufzeichnen von Ereignissen
def log(msg):
    file = open(logfile, "a")
    file.write("%s: %s\n" % (time.strftime("%d.%m.%Y %H:%M:%S"), msg))
    file.close

# Wake up UPS
#subprocess.call('i2cset -y ' + str(i2c_port) + ' ' + str(device_address) + ' 0x0A 0x00')
#bus.write_byte_data(device_address, 0x0A, 0x00)

while 0 < 1:
    capacity = readCapacity(bus)
    voltage = readVoltage(bus)
    status = readStatus(bus)
    sleepTime = 900 # 15min
    batteryStatusString = ''

    if voltageBefore == None:
        voltageBefore = voltage

    if capacityBefore == None:
        capacityBefore = capacity

    trendVoltage = float(voltage) - float(voltageBefore)
    trendCapacity = float(capacity) - float(capacityBefore)
    voltageString = "VOLTAGE: %4.2fV" % voltage
    voltageBeforeString = "%4.2fV" % voltageBefore
    voltageTrendString = "%2.5fV" % trendVoltage
    capacityString = "CAPACITY: %3i%%" % capacity
    capacityBeforeString = "%3i%%" % capacityBefore
    capacityTrendString = "%2.5f%%" % trendCapacity

    if voltage == 0 and capacity == 0:
        log("Cannot read battery stats. There's something wrong...")
        sleepTime = 60 # 60sec
    elif status > 1024 and (voltage < voltageMin or capacity <= capacityMin):
        # system is running on battery and voltage and capacity of batteries are low
        log("Battery capacity has just " + voltageString + " | " + capacityString + ". Shutting down the system...!")
        os.system('sudo poweroff')  # alias for: sudo shutdown -h now
    else:
        # trendCapacity and trendVoltage is a positive value => battery is charging
        if status < 1024:
            batteryStatusString = "AC Power connected (Charging)"
            sleepTime = 600 # 10min
        # trendCapacity is a negative value => battery is discharging
        else:
            batteryStatusString = "Battery operation"
            if capacity <= 50:
                sleepTime = 180 # 3min
            else:
                sleepTime = 300 # 5min

        voltageFullString = voltageString + " | before: " + voltageBeforeString + " | trend: " + voltageTrendString
        capacityFullString = capacityString + " | before: " + capacityBeforeString + " | trend: " + capacityTrendString
        log(batteryStatusString + " || " + voltageFullString + " || " + capacityFullString)

        # play a tone if capacity is below 5%
        #if capacity <= 5:
        #    os.system("/usr/bin/python /usr/local/bin/playton2.py 1")

    voltageBefore = voltage
    capacityBefore = capacity
    time.sleep(sleepTime)
