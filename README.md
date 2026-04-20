# Corne (nice!nano v2) ZMK Firmware

ZMK firmware configuration for a Corne split keyboard with nice!nano v2 controllers. Firmware is built automatically via GitHub Actions on every push.

## Keymap Overview

The keymap has four layers, accessed through layer switching keys.

### Layer 0: Default

The base QWERTY typing layer.

```
 TAB |  Q  |  W  |  E  |  R  |  T  |   |  Y  |  U  |  I  |  O  |  P  |  \
 ESC |  A  |  S  |  D  |  F  |  G  |   |  H  |  J  |  K  |  L  |  ;  |  '
LCTRL|  Z  |  X  |  C  |  V  |  B  |   |  N  |  M  |  ,  |  .  |  /  |  =
                  |LALT |mo(1)|LSHFT|   | ENT | SPC |BSPC |
```

- **mo(1)** on the left thumb momentarily activates layer 1 while held.

### Layer 1: Numbers, Symbols, and Function Keys

Accessed by holding mo(1) on the default layer.

```
  `  |  1  |  2  |  3  |  4  |  5  |   |  6  |  7  |  8  |  9  |  0  |  -
sl(3)|LGUI |     |     |     |     |   | LFT | DWN |  UP | RGT |  [  |  ]
 F1  | F2  | F3  | F4  | F5  | F6  |   | F7  | F8  | F9  | F10 | F11 | F12
                  |     |     |     |   |PSCRN|tog(2)|    |
```

- **sl(3)** is a sticky-layer tap that activates layer 3 (bluetooth/firmware) for one keypress.
- **tog(2)** toggles the mouse layer on/off.
- **PSCRN** sends the Print Screen key.

### Layer 2: Mouse

A toggled layer for mouse emulation. Toggle it on/off via tog(2) on layer 1.

```
     |     |     |M_UP |     |     |   |     |     |     |     |     |
to(0)|     |M_LFT|M_DWN|M_RGT|     |   |SC_DN|LCLK |RCLK |MCLK |SC_UP|
     |     |     |     |     |     |   |     |     |     |     |     |
                  |     |     |     |   |     |     |     |
```

- WASD-style mouse movement on the left hand (E/S/D/F positions to stay on homerow).
- Right hand has scroll wheel (SC_DN/SC_UP) and mouse buttons (LCLK, RCLK, MCLK).
- **to(0)** returns to the default layer.

### Layer 3: Bluetooth and Firmware

Accessed via sl(3) on layer 1. Used for Bluetooth profile management and firmware operations.

```
     | BT0 | BT1 | BT2 | BT3 | BT4 |   |BTCLR|     |     |     |     |BTCLRA
to(0)|     |     |     |     |     |   |     |BTNXT|BTPRV|     |     |
     |     |     |     |     |     |   |     |     |     |     |     |
                  |BOOT |     | RST |   | RST |     |BOOT |
```

- **BT0-BT4** select a Bluetooth profile.
- **BTCLR** clears the current profile, **BTCLRA** clears all profiles.
- **BTNXT/BTPRV** cycle through Bluetooth profiles.
- **BOOT** enters the bootloader, **RST** performs a system reset.
- Bootloader and reset are mirrored on both halves so either side can be flashed.

## Development Environment

This repo includes a Nix flake that provides all the tools needed for ZMK development.

### Prerequisites

- [Nix with flakes enabled](https://nixos.org/download.html)
- [direnv](https://direnv.net/docs/installation.html) (recommended)

### Entering the Dev Shell

```bash
# With direnv (recommended — activates automatically when you cd in):
direnv allow

# Or manually:
nix develop
```

The dev shell provides git, GitHub CLI (gh), Python 3, UV, curl, wget, and jq. On entry it automatically installs the ZMK CLI via UV if not already present.

### Using the ZMK CLI

Once inside the dev shell, the `zmk` command is available:

```bash
zmk init          # Initialize a ZMK config repo
zmk keyboard add  # Add a keyboard to your config
```

## Building Firmware

Firmware is built by GitHub Actions on every push, pull request, or manual workflow dispatch. The workflow (`.github/workflows/build.yml`) calls the upstream `zmkfirmware/zmk` reusable build workflow.

Each build produces two artifacts — one for each half of the keyboard:

- `corne_left-nice_nano_v2-zmk`
- `corne_right-nice_nano_v2-zmk`

Each artifact contains a `.uf2` firmware file.

## Flashing Firmware

1. Go to the **Actions** tab in your GitHub repository.
2. Select the latest successful **Build ZMK firmware** run.
3. Download the firmware artifacts (`corne_left-nice_nano_v2-zmk` and `corne_right-nice_nano_v2-zmk`).
4. Unzip each artifact to get the `.uf2` files.
5. For each half of the keyboard:
   - Connect the half via USB.
   - Double-press the reset button on the nice!nano to enter the bootloader. The board will appear as a USB mass storage device (named `NICENANO`).
   - Copy the corresponding `.uf2` file to the `NICENANO` drive.
   - The board will automatically flash and reboot.
6. Repeat for the other half.

> **Tip:** You can also enter the bootloader from layer 3 by pressing the **BOOT** key (bottom-left on the left half, bottom-right on the right half) instead of using the physical reset button.

## Cleanup

1. Delete this directory to remove all project files.
2. Optionally remove the ZMK CLI: `rm ~/.local/bin/zmk`
3. Run `nix-collect-garbage` to clean up Nix store dependencies.
