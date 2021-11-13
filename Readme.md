# SupTronics/Geekworm X750 UPS HAT shutdown scripts

Shutdown scripts for SupTronics/Geekworm X750 UPS HAT for Rasperry Pi, based on the [original scripts from Geekworm](https://github.com/geekworm-com/x750). It also reads the status of address 0x14 which can be used to determine the charging status. Kudos goes to [_Anonymous user #19_ in the comments section of hardware the overview](https://wiki.geekworm.com/X750#end) for this hint.

## Why
I'm using these scripts in my [Portable Musicbox](http://showcase.visualgaze.de/portable-musicbox).

## Install scripts and services

```bash
> git clone https://github.com/one-step-behind/suptronics-x750-scripts.git
> cd suptronics-x750-scripts
> chmod +x install.sh
> ./install.sh
```

## What is it doing

`ups-x750-check` is **watching the batteries health** (voltage, capacity and charging state). If batteries were not charging and voltage and capacity reaching a _low limit_ it will shutdown the Pi safely and the power for the Pi is cut completely by the X750.

`ups-x750-shutdown` is **polling the momentary switch** connected to the X750 board. If switch will be pressed for more than _4 seceonds_ the Pi shuts down safely and the power is cut completely by the X750.

`ups-x750-test.py` can be run from console and display some values of the batteries and charging state, e.g.:

```bash
******************
Voltage raw: 4.12125
Voltage: 4.12V
Battery:   87%
Status:    198
USB Power Connected 2A Charging
******************
```

## More info about the X750

[X750 Wiki](https://wiki.geekworm.com/X750)