# Native install of ROS2 Jazzy on Apple Silicon Macbooks

## One-liner installation code

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/install.sh)"
```

## Introduction
This is a source code behind oneline installation code to install ROS2 Jazzy on Apple Silicon Macbooks.

Tested and desgined on macOS Sonomar 14.5 with Apple M3 chip (36 GB)

The reasons we are installing ROS2 Jazzy on Apple Silicon Macbooks natively are:
- Faster performance
  - To avoid using Rosetta 2 to emulate x86_64 architecture
- Better compatibility
  - USB and other hardware drivers are not fully supported with Docker Desktop for Mac with HyperKit (for now)
  - To avoid any potential issues that may arise from using Rosetta 2

## References: (None of below worked for me, so I made this script)
- https://github.com/pfavr2/install_ros2_rolling_on_mac_m1
- https://chenbrian.ca/posts/ros2_m1/
- https://github.com/TakanoTaiga/ros2_m1_native
- https://docs.ros.org/en/jazzy/Installation/Alternatives/macOS-Development-Setup.html
