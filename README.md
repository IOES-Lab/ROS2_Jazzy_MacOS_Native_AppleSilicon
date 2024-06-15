# Native install of ROS2 Jazzy on Apple Silicon Macbooks

## One-liner installation code
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/IOES/ros2-jazzy-macos-native-applesilicon/HEAD/install.sh)"
```

https://raw.githubusercontent.com/IOES/ros2-jazzy-macos-native-applesilicon/HEAD/install.sh

## Introduction
This is a source code behind oneline installation code to install ROS2 Jazzy on Apple Silicon Macbooks.

Tested and desgined on macOS Sonomar 14.5 with Apple M3 chip (36 GB)

The reasons we are installing ROS2 Jazzy on Apple Silicon Macbooks natively are:
- Faster performance
  - To avoid using Rosetta 2 to emulate x86_64 architecture
- Better compatibility
  - USB and other hardware drivers are not fully supported with Docker Desktop for Mac with HyperKit (for now)
  - To avoid any potential issues that may arise from using Rosetta 2



