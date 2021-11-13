#!/bin/bash
## UPS X750 plugin installation script
echo "=== Installing UPS X750 plugin and it's dependencies ==="
SCRIPT_DIR=~/ups-x750
LOG_DIR=~/log
PLUGIN_NAME="ups-x750"
INSTALLING="./${PLUGIN_NAME}-plugin.installing"

if [ -f $INSTALLING ]; then
	echo "=== Plugin is already installing! Abort this installation attempt. ==="
else
	touch $INSTALLING
	
	if [ ! -d "$SCRIPT_DIR" ]; then
    mkdir $SCRIPT_DIR
    sudo chmod 755 $SCRIPT_DIR
  fi
  
	if [ ! -d "$LOG_DIR" ]; then
    mkdir $LOG_DIR
    sudo chmod 755 $LOG_DIR
  fi
  
	# Copy and reload scripts and restart service
	sudo systemctl stop ups-x750-check
	sudo systemctl disable ups-x750-check
	sudo systemctl stop ups-x750-shutdown
	sudo systemctl disable ups-x750-shutdown

	sudo cp -f ups-x750-check.service /etc/systemd/system/ups-x750-check.service
	sudo chmod 644 /etc/systemd/system/ups-x750-check.service

	sudo cp -f ups-x750-shutdown.service /etc/systemd/system/ups-x750-shutdown.service
	sudo chmod 644 /etc/systemd/system/ups-x750-shutdown.service

	cp -f ups-x750-check.py $SCRIPT_DIR/ups-x750-check.py
	cp -f ups-x750-shutdown.sh $SCRIPT_DIR/ups-x750-shutdown.sh
	chmod +x $SCRIPT_DIR/ups-x750-shutdown.sh

  sudo systemctl daemon-reload
  sudo systemctl enable ups-x750-check
  sudo systemctl enable ups-x750-shutdown
  sudo systemctl start ups-x750-check
  sudo systemctl status ups-x750-check
  sudo systemctl start ups-x750-shutdown
  sudo systemctl status ups-x750-shutdown

	rm $INSTALLING

	echo "=== DONE. Scripts for ${PLUGIN_NAME} successfully installed. ==="
	echo "=== You can now safely delete this folder."
fi