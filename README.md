# mac-keybindings-for-windows

An AutoHotkey script that brings macOS keyboard shortcuts to your Windows system.

## Overview

This script emulates macOS keyboard behavior on Windows, making it easier for Mac users to transition between systems. It implements familiar shortcuts like Command+Q to quit applications, Command+Tab for application switching, and Emacs-style text editing shortcuts.

## Requirements

- [AutoHotkey v2.0](https://www.autohotkey.com/) or later
- Physical keyboard with remapped keys (see Setup section)

## Features

- **Emacs-style text editing shortcuts**: Navigation and editing with Ctrl+A, Ctrl+E, Ctrl+F, etc.
- **macOS window management**: Command+W to close windows, Command+M to minimize, etc.
- **Browser navigation**: Command+[ and Command+] for back/forward, Command+T for new tab
- **Application switching**: Command+Tab for Alt+Tab functionality
- **Screen capture**: Command+Shift+3 and Command+Shift+4 for screenshots
- **System operations**: Command+Control+Q to lock the screen, Command+Option+Shift+Q to log out

## Setup

### Keyboard Remapping

This script assumes you've already remapped some keys on your keyboard:

- **Left Ctrl** (physical key to the left of A) → Used as **Control** (like on Mac)
- **Left Alt** → Remapped to **Right Ctrl** → Functions as **Command**
- **Left Windows** → Remapped to **Left Alt** → Functions as **Option**

This can be achieved using:
- Hardware remapping on programmable keyboards like HHKB or Realforce
- Keyboard management software
- Registry edits (not recommended unless you know what you're doing)

### Installing and Running the Script

1. Install [AutoHotkey v2.0](https://www.autohotkey.com/)
2. Download `macos-keybindings.ahk` from this repository
3. Double-click the script to run it
4. To run automatically at startup, place the script (or a shortcut to it) in your Windows Startup folder:
   - Press `Win+R`, type `shell:startup`, and press Enter
   - Copy the script or create a shortcut to it in this folder

## Customization

You can modify the script to suit your needs:
- Add or remove applications from the exclusion groups
- Change key combinations
- Add additional shortcuts

Just open the `.ahk` file in any text editor and make your changes.

## Excluded Applications

Some applications already have their own Emacs-like bindings or would conflict with the script:
- Windows Terminal
- Visual Studio Code

You can modify these exclusions in the group definitions at the top of the script.

## Troubleshooting

- **Shortcuts not working**: Make sure the script is running (check for the AutoHotkey icon in the system tray)
- **Conflicts with specific applications**: Add them to the appropriate exclusion group
- **Issues after system updates**: Reinstall AutoHotkey or restart the script

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- The AutoHotkey community for documentation and examples
- Mac users who struggle with the Windows keyboard layout

## Contributing

Contributions are welcome! Feel free to submit pull requests or open issues for bug fixes, improvements, or feature requests.
