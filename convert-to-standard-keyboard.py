#!/usr/bin/env python3
"""
Convert HHKB/Realforce version of macos-keybindings.ahk to standard 106 keyboard version
"""

import re
import sys

def convert_ahk_to_standard_keyboard(content):
    """Convert HHKB/Realforce keybindings to standard 106 keyboard layout"""
    
    # Track if we need to add CapsLock initialization
    needs_capslock_init = False
    
    lines = content.split('\n')
    converted_lines = []
    
    for line in lines:
        original_line = line
        
        # Skip comments and empty lines
        if line.strip().startswith(';') or line.strip() == '':
            converted_lines.append(line)
            continue
            
        # Convert Emacs keybindings (Left Control to CapsLock)
        if re.search(r'<\^[a-z]', line):
            needs_capslock_init = True
            # <^h → CapsLock & h
            line = re.sub(r'<\^([a-z])', r'CapsLock & \1', line)
            
        # Convert Command keybindings (Right Control to LWin)
        # Handle complex patterns first
        if '>::' in line:
            # >^+Left → LWin & +Left (needs special handling)
            if re.search(r'>\^\+', line):
                # Extract the key part
                match = re.search(r'>\^\+(\w+)::', line)
                if match:
                    key = match.group(1)
                    line = re.sub(r'>\^\+' + key + '::', f'+LWin & {key}::', line)
            # >^vkC0 → LWin & vkC0 (backtick key)
            elif re.search(r'>\^vk', line):
                line = re.sub(r'>\^(vk\w+)', r'LWin & \1', line)
            # >^<^ → LWin & LCtrl (for Control+Command combinations)
            elif re.search(r'>\^<\^', line):
                line = re.sub(r'>\^<\^', 'LWin & LCtrl & ', line)
            # >^word → LWin & word
            elif re.search(r'>\^(\w+)::', line):
                line = re.sub(r'>\^(\w+)::', r'LWin & \1::', line)
                
        # Convert Option keybindings (Alt remains Alt, but update comments)
        # !Left → LAlt & Left (for clarity, though ! still works)
        if re.search(r'^[^;]*![A-Z]', line) and '::' in line:
            line = re.sub(r'!([A-Z]\w*)::', r'LAlt & \1::', line)
            
        # Handle SendInput commands - no conversion needed, just update comments
        
        # Update comments to reflect new keyboard layout
        if 'HHKB/Realforce' in line:
            line = line.replace('HHKB/Realforce', 'Standard 106-key keyboard')
        
        # Update the prerequisite section completely
        if 'HHKB/Realforce側で以下のキーマップを入れ替え済みであること' in line:
            line = line.replace(
                'HHKB/Realforce側で以下のキーマップを入れ替え済みであること',
                '標準106キーボードで以下のキーマッピングを使用'
            )
        
        if 'LCtrl (キー A の左の位置へ)    → macOSでのControlキー相当' in line:
            line = line.replace(
                'LCtrl (キー A の左の位置へ)    → macOSでのControlキー相当',
                'CapsLock                      → macOSでのControlキー相当'
            )
        
        if 'LAlt → RCtrl                  → macOSでのCommandキー相当' in line:
            line = line.replace(
                'LAlt → RCtrl                  → macOSでのCommandキー相当',
                'LWin                          → macOSでのCommandキー相当'
            )
        
        if 'LWin → LAlt                   → macOSでのOptionキー相当' in line:
            line = line.replace(
                'LWin → LAlt                   → macOSでのOptionキー相当',
                'LAlt                          → macOSでのOptionキー相当'
            )
        
        # Add note about no physical key remapping needed
        if line.strip() == '*/' and converted_lines and 'macOSでのOptionキー相当' in converted_lines[-1]:
            converted_lines.append(' * ※ 物理的なキーの入れ替えは不要です（AutoHotkeyで実現）')
            converted_lines.append(line)
            continue
            
        converted_lines.append(line)
    
    result = '\n'.join(converted_lines)
    
    # Add CapsLock initialization if needed
    if needs_capslock_init:
        capslock_init = '''
; ====================================================================
; CapsLock キーを修飾キーとして使用するための初期化
; ====================================================================

; CapsLock単体での動作を無効化（修飾キーとしてのみ使用）
CapsLock::return

'''
        # Insert after the initial comment block
        result = result.replace(
            '; ====================================================================\n; グローバル変数とグループ定義',
            capslock_init + '; ====================================================================\n; グローバル変数とグループ定義'
        )
    
    return result

def main():
    if len(sys.argv) != 3:
        print("Usage: python convert-to-standard-keyboard.py input.ahk output.ahk")
        sys.exit(1)
        
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            content = f.read()
            
        converted_content = convert_ahk_to_standard_keyboard(content)
        
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(converted_content)
            
        print(f"✅ Conversion completed!")
        print(f"📁 Input:  {input_file}")
        print(f"📁 Output: {output_file}")
        print()
        print("⚠️  Manual review recommended:")
        print("   - Check complex key combinations")
        print("   - Test Shift+LWin combinations")
        print("   - Verify HotIf conditions")
        
    except FileNotFoundError:
        print(f"❌ Error: File '{input_file}' not found")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
