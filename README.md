# Install ROS-Gazebo(Jazzy-Harmonic) Framework natively on Apple Silicon Macbooks

## One-liner installation code (🍎 (Apple Silicon) + 🤖 = 🚀❤️🤩🎉🥳)
- Copy and paste it on terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/install.sh)"
```

## Introduction
This is the source code behind the one-line installation command to install ROS2 Jazzy and Gazebo Harmonic on Apple Silicon Macbooks.

Tested and designed on macOS Sonoma 14.5 with an Apple M3 chip (36 GB), it took about 15 minutes each to install ROS2 Jazzy and Gazebo Harmonic.

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

## References: (None of below worked for me, so I made this script)
- https://github.com/pfavr2/install_ros2_rolling_on_mac_m1
  - Much of the code design structure is referenced from this
- https://chenbrian.ca/posts/ros2_m1/
- https://github.com/TakanoTaiga/ros2_m1_native
- https://docs.ros.org/en/jazzy/Installation/Alternatives/macOS-Development-Setup.html
