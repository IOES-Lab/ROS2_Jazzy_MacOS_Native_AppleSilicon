# Install ROS-Gazebo(Jazzy-Harmonic) Framework natively on Apple Silicon Macbooks

  [![Build on macOS](https://github.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/actions/workflows/build.yml/badge.svg)](https://github.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/actions/workflows/build.yml)

## Tested environment
- MacOS Sequoia 14.5

## Requirements
- > `CURRENTLY ONLY XCODE VERSION 16.2 WORKS!` (16.3 is default bundle with macOS 14.5). You need to downgrade to 16.2. To do so, follow instruction at https://www.antonseagull.com/post/how-to-downgrade-xcode

## One-liner installation code (🍎 (Apple Silicon) + 🤖 = 🚀❤️🤩🎉🥳)
- Copy and paste it on terminal

### For full installation (ROS2 Jazzy and Gazebo Harmonic, in order)
- May take upto 45 minutes depending on your system. (took about 30 minutes with M3 Max MBP)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/install.sh)"
```

## Introduction
This is the source code behind the one-line installation command to install ROS2 Jazzy and Gazebo Harmonic on Apple Silicon Macbooks.

Tested on an Apple M3 chip (36 GB), it took about 15 minutes each to install ROS2 Jazzy and Gazebo Harmonic.

The reasons for installing ROS2 Jazzy natively on Apple Silicon Macbooks are:
- Faster performance
  - To avoid using Rosetta 2 to emulate x86_64 architecture
- Better compatibility
  - USB and other hardware drivers are not fully supported with Docker Desktop for Mac with HyperKit (for now)
  - To avoid any potential issues that may arise from using Rosetta 2

## What it Does
### ROS2 Jazzy Installation (`install.sh`)
  1. Checking System Requirements
    - Check XCode Installation
    - Check Brew Installation
    - Generate workspace for ROS2 Jazzy (default: `~/ros2_jazzy`)
  2. Install Dependencies
    - Install dependencies with Brew
    - Set environment variables for Brew packages
    - Create a Python 3.11 virtual environment (default `~/.ros2_venv`)
    - Install Python dependencies
  3. Download ROS2 Jazzy Source Code
    - Clone the ROS2 Jazzy source code
      - It's using release tag (default: `release-jazzy-20240523`)
    - Partial compile to generate structure
  4. Patch for macOS X Installation
    - Patch for cyclondds, orocos-kdl, rviz_ogre_vendor, rosbag2_transport
    - Ensure link with qt5
    - Revert python_orocos_kdl_vendor back to 0.4.1
    - Remove eclipse-cyclonedds
  5. Compile ROS2 Jazzy
  6. Post Installation
    - Generate a config file in the workspace
    - Make source script

### Gazebo Harmonic Installation (`gz_install.sh`)
  1. Checking System Requirements
    - Create a workspace for Gazebo Harmonic (default: `~/gz_harmonic`)
    - Check the Python virtual environment
  2. Install Dependencies
    - Install Brew dependencies
    - Install Python dependencies
    - Set environmetnal variables for brew packages
    - Install xquartz
  3. Download Gazebo Harmonic Source Code
    - Clone Gazebo Harmonic Source Code
  4. Compile Gazebo Harmonic
  5. Post Installation
    - Read/append to the config file in the workspace
    - Regenerate source script

## Notes
- `eclipse-cyclonedds` is excluded from the installation process
  - It is not supported on Apple Silicon Macbooks (compile errors)
  - Ref : https://ros.org/reps/rep-2000.html

## For ROS_GZ
- I need help... Some progress (but not done) at https://github.com/IOES-Lab/ros_gz_for_mac

## For MAVROS
- Visit https://github.com/IOES-Lab/ROS2_MAVROS_AppleSilicon

## For Docker + Remote Desktop approach
- The native install may give you chance to exploit maximum performance of the apple hardware but the ROS-Gazebo framework and related dependencies may cause issues constantly.
- It's often very useful to use Docker-powered methods.
- Visit [ROS2 Jazzy - Gazebo Humble Docker Installation Tutorial](https://dave-ros2.notion.site/Docker-Installation-Manual-efbf75623fc743e9b0e55c94c211a1dd#b581997fcbc0475697d6d021e7d26fb1)

## References: (None of below worked for me, so I made this script)
- https://github.com/pfavr2/install_ros2_rolling_on_mac_m1
  - Much of the code design structure is referenced from this
- https://chenbrian.ca/posts/ros2_m1/
- https://github.com/TakanoTaiga/ros2_m1_native
- https://docs.ros.org/en/jazzy/Installation/Alternatives/macOS-Development-Setup.html
