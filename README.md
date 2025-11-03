# mac-keybindings-for-windows

An AutoHotkey script that brings macOS keyboard shortcuts to your Windows system.

## Overview

This script emulates macOS keyboard behavior on Windows, making it easier for Mac users to transition between systems. It implements familiar shortcuts like Command+Q to quit applications, Command+Tab for application switching, and Emacs-style text editing shortcuts.

## Versions

This project provides two versions for different keyboard layouts:

### HHKB/Realforce Version (`macos-keybindings.ahk`)
For programmable keyboards with hardware key remapping:
- Requires physical key remapping on the keyboard
- Left Ctrl → Control, Left Alt → Right Ctrl (Command), Left Win → Left Alt (Option)
- Optimal for users with programmable keyboards

### Standard 106-key Version (`macos-keybindings-106.ahk`) 
For standard Windows keyboards:
- **No physical key remapping required**
- Left Ctrl → Control, Left Win → Command, Left Alt → Option
- Works with any standard Windows keyboard

## Known Limitations

### Windows Key Combinations
Some keyboard shortcuts using the Windows key may not work properly due to Windows system limitations:

- **Windows Snap Feature Conflicts**: `Win+Shift+Arrow` combinations may conflict with Windows' built-in window snapping
- **System Reserved Shortcuts**: Some `Win+key` combinations are reserved by Windows and cannot be overridden
- **UAC and Elevated Applications**: Windows key shortcuts may not function in applications running with administrator privileges

**Workarounds:**
- Some shortcuts use alternative key combinations (e.g., `Ctrl+Alt+F` instead of `Ctrl+Win+F`)
- Consider disabling Windows Snap feature if line selection shortcuts are essential
- Use UIA version of AutoHotkey for better compatibility with elevated applications

## Requirements

- [AutoHotkey v2.0](https://www.autohotkey.com/) or later
- Choose the appropriate version for your keyboard layout

## Features

- **Emacs-style text editing shortcuts**: Navigation and editing with Left Ctrl+A, Left Ctrl+E, Left Ctrl+F, etc.
- **macOS window management**: Command+W to close windows, Command+M to minimize, etc.
- **Browser navigation**: Command+[ and Command+] for back/forward, Command+T for new tab
- **Application switching**: Command+Tab for Alt+Tab functionality
- **macOS-style line selection**: Shift+Command+← and Shift+Command+→ with continuous selection support
- **Screen capture**: Command+Shift+3 and Command+Shift+4 for screenshots
- **System operations**: Command+Control+Q to lock the screen, Command+Option+Shift+Q to log out
- **Explorer behaviors**: **Cmd+Up** → parent folder (`Alt+Up`), **Cmd+Down** → open selection (stabilized to avoid rare `Ctrl+Enter` misdetection; changes are scoped to the handler).

## Setup

### Choose Your Version

#### For HHKB/Realforce Users
If you have a programmable keyboard (HHKB, Realforce, etc.):

1. Configure your keyboard's hardware remapping:
   - **Left Ctrl** (physical key to the left of A) → Used as **Control** (like on Mac)
   - **Left Alt** → Remapped to **Right Ctrl** → Functions as **Command**
   - **Left Windows** → Remapped to **Left Alt** → Functions as **Option**

2. Use `macos-keybindings.ahk`

#### For Standard Keyboard Users
If you have a standard 106-key Windows keyboard:

1. Use `macos-keybindings-106.ahk` 
2. **No keyboard configuration needed** - the script handles everything
3. Key mapping:
   - **Left Ctrl** → Functions as **Control** (Emacs shortcuts)
   - **Left Windows** → Functions as **Command** (macOS shortcuts)
   - **Left Alt** → Functions as **Option** (macOS shortcuts)

### Keyboard Remapping (HHKB/Realforce Only)

This can be achieved using:
- Hardware remapping on programmable keyboards like HHKB or Realforce
- Keyboard management software
- Registry edits (not recommended unless you know what you're doing)

### Installing and Running the Script

1. Install [AutoHotkey v2.0](https://www.autohotkey.com/)
2. Download the appropriate script:
   - `macos-keybindings.ahk` for HHKB/Realforce
   - `macos-keybindings-106.ahk` for standard keyboards
3. Run the script:

#### Basic Execution
```bash
AutoHotkey64.exe macos-keybindings.ahk
```

#### UIA Version (Recommended)
For better compatibility with elevated applications and system windows, use the UIA version:

```bash
"C:\Program Files\AutoHotkey\v2\AutoHotkey64_UIA.exe" "C:\path\to\macos-keybindings.ahk" /uiAccess
```

**Benefits of UIA version:**
- Works with Windows Settings, UAC dialogs, and administrator applications
- Functions in security software management interfaces
- Provides more consistent system-wide behavior

### Startup Configuration

To run automatically at startup:

1. Press `Win+R`, type `shell:startup`, and press Enter
2. Create a batch file or shortcut in the startup folder

**Example batch file (startup.bat):**
```batch
@echo off
"C:\Program Files\AutoHotkey\v2\AutoHotkey64_UIA.exe" "C:\Users\%USERNAME%\path\to\macos-keybindings-106.ahk" /uiAccess
```

*Note: Replace `macos-keybindings-106.ahk` with `macos-keybindings.ahk` if using the HHKB version.*

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
- **Windows key combinations not responding**: Some `Win+key` shortcuts may conflict with Windows system functions (see Known Limitations above)
- **Line selection not working**: Windows Snap feature may interfere with `Win+Shift+Arrow` combinations
- **Conflicts with specific applications**: Add them to the appropriate exclusion group
- **Issues after system updates**: Reinstall AutoHotkey or restart the script
- **UIA version security warnings**: Initial execution may show security prompts - this is normal
- Explorer: If **Cmd+Down** is occasionally interpreted as `Ctrl+Enter`, the latest script scopes Event mode with a short key press to stabilize this. If needed, tweak the small `Sleep` window (e.g., 20–50 ms).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- The AutoHotkey community for documentation and examples
- Mac users who struggle with the Windows keyboard layout

## Contributing

Contributions are welcome! Feel free to submit pull requests or open issues for bug fixes, improvements, or feature requests.
