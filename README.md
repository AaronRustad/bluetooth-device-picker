## Description

Bluetooth Device Picker is a macOS command-line tool that lists paired Bluetooth devices, shows their connection status, and lets you toggle connections from an interactive prompt. It shells out to `blueutil`, so that utility must be installed and available on your PATH.

## Installation

```bash
gem install bluetooth-device-picker
```

## Usage

Launch the interactive picker:

```bash
bluetooth-device-picker
```

Select a device to toggle its connection. Press `Ctrl+C` to exit.

Connect or disconnect directly:

```bash
# Connect a device
bluetooth-device-picker connect AA-BB-CC-DD-EE-FF

# Disconnect a device
bluetooth-device-picker disconnect AA-BB-CC-DD-EE-FF
```
