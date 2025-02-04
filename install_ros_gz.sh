#!/bin/bash
# ROS_GZ installation script

# -------- Source ROS Installation
# shellcheck disable=SC1091
source "$HOME/.ros2_jazzy_install_config"
# shellcheck disable=SC1090
source "$HOME/$ROS_INSTALL_ROOT/activate_ros"
export GZ_VERSION=harmonic

# -------- Clone ROS_GZ source
cd "$ROS_INSTALL_ROOT/src" || exit
git clone --branch 1.0.8 https://github.com/gazebosim/ros_gz.git

# -------- Clone other dependency packages
git clone https://github.com/swri-robotics/gps_umd.git
git clone https://github.com/ros-perception/vision_msgs.git
git clone https://github.com/rudislabs/actuator_msgs.git

# -------- Patch ROS_GZ source (remove vendor package)
cd ros_gz || exit
curl -sSL \
  https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/ros_gz/patches/0001-patch-for-ros-jazzy.patch \
  -o 0001-patch-for-ros-jazzy.patch
git apply 0001-patch-for-ros-jazzy.patch

# -------- Build ROS_GZ
cd "$ROS_INSTALL_ROOT" || exit
# shellcheck disable=SC2086
colcon build --symlink-install --packages-select ros_gz \
    --packages-skip-by-dep python_qt_binding \
    --cmake-args \
    --no-warn-unused-cli \
    -DBUILD_TESTING=OFF \
    -DINSTALL_EXAMPLES=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DPython3_EXECUTABLE=$HOME/$VIRTUAL_ENV_ROOT/bin/python3 \
    -Wno-dev --event-handlers console_cohesion+










