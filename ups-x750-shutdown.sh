#!/bin/bash
# x750 Powering on /reboot /full shutdown through HARDWARE

SHUTDOWN=4 # GPIO 4
BOOT=17 # GPIO 17
REBOOTPULSEMINIMUM=200 # 2sec
REBOOTPULSEMAXIMUM=400 # 4sec

DO_SHUTDOWN=true
DO_REBOOT_DISPLAY=false

trap ctrl_c INT

function ctrl_c() {
  echo "** Trapped CTRL-C"
  exit
}

echo "========= X750 UPS ========="

if [ "$DO_SHUTDOWN" != true ] && [ "$DO_REBOOT_DISPLAY" != true ]; then
  echo 'Wheather SHUTDOWN nor REBOOT is configured. Exiting...'
  echo "============================"
  exit
fi

if [ "$DO_SHUTDOWN" = true ] || [ "$DO_REBOOT_DISPLAY" = true ]; then
  # Exports pin to userspace
  if [ ! -d /sys/class/gpio/gpio$SHUTDOWN ]; then
    echo "$SHUTDOWN" > /sys/class/gpio/export
    sleep 1; # Short delay while GPIO permissions are set up
  fi
  # Sets pin $SHUTDOWN as an input
  echo "in" > /sys/class/gpio/gpio$SHUTDOWN/direction

  # Exports pin to userspace
  if [ ! -d /sys/class/gpio/gpio$BOOT ]; then
    echo "$BOOT" > /sys/class/gpio/export
    sleep 1; # Short delay while GPIO permissions are set up
  fi
  # Sets pin $BOOT as an output
  echo "out" > /sys/class/gpio/gpio$BOOT/direction
  # Sets pin $BOOT to high
  echo "1" > /sys/class/gpio/gpio$BOOT/value

  echo "...initialized GPIOs: $SHUTDOWN, $BOOT"
  if [ "$DO_REBOOT_DISPLAY" = true ]; then
    echo "Hold button for at least $((REBOOTPULSEMINIMUM/100))s to REBOOT DISPLAY."
  fi
  if [ "$DO_SHUTDOWN" = true ]; then
    echo "Hold button for at least $((REBOOTPULSEMAXIMUM/100))s to SHUTDOWN."
  fi
fi

echo "============================"

while [ 1 ]; do
  shutdownSignal=$(cat /sys/class/gpio/gpio$SHUTDOWN/value)

  if [ $shutdownSignal = 0 ]; then
    /bin/sleep 0.2
  else
    # Shutdown
    if [ "$DO_SHUTDOWN" = true ]; then
      echo 'waiting for shutdown'
      pulseStart=$(date +%s%N | cut -b1-13)

      while [ $shutdownSignal = 1 ]; do
        /bin/sleep 0.02

        echo 'hold to shutdown...'

        if [ $(($(date +%s%N | cut -b1-13)-$pulseStart)) -gt $REBOOTPULSEMAXIMUM ]; then
          echo "X750 Shutting down", $SHUTDOWN, ", halting Rpi ..."
          sudo poweroff # alias for: sudo shutdown -h now
          exit
        fi

        shutdownSignal=$(cat /sys/class/gpio/gpio$SHUTDOWN/value)
      done
    fi

    # Reboot
    if [ "$DO_REBOOT_DISPLAY" = true ]; then
      if [ $(($(date +%s%N | cut -b1-13)-$pulseStart)) -gt $REBOOTPULSEMINIMUM ]; then
        echo "Display reboot..."
        #sudo reboot # alias for: sudo shutdown -r now
        systemctl restart volumio-display
        exit
      fi
    fi
  fi
done