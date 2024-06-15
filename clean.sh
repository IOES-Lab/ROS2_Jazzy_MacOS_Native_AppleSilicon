#!/bin/bash
# From https://github.com/pfavr2/install_ros2_rolling_on_mac_m1

if typeset -f deactivate_ros > /dev/null; then
  deactivate_ros
fi

sudo rm -Rf /opt/ros/

