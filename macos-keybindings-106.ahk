#Requires AutoHotkey v2.0

/*
 * macOS風キーバインド for Windows (106キーボード版)
 * 
 * キーマッピング:
 * このスクリプトは以下のキー配置でmacOS風操作を実現します
 *   - LCtrl                         → macOSでのControlキー相当
 *   - LWin                          → macOSでのCommandキー相当
 *   - LAlt                          → macOSでのOptionキー相当
 * ※ 物理的なキーの入れ替えは不要です（AutoHotkeyで実現）
 */

; ====================================================================
; グローバル変数とグループ定義
; ====================================================================

; Alt+Tab 管理用グローバル変数
global isAltTabMenuActive := false

; 入力ソース切替用のグローバル変数
global isLangSwitcherActive := false

; ウィンドウ切替用グローバル変数
global isWindowSwitcherActive := false
global windowSwitcherDirection := false  ; false=順方向、true=逆方向
global switcherWindowList := []          ; ウィンドウリストを保存
global switcherCurrentIndex := 0         ; 現在のウィンドウインデックス
global switcherOriginalHwnd := 0         ; 元のウィンドウID

; 選択状態管理用グローバル変数
global lastSelectionDirection := ""      ; "left", "right", ""
global lastSelectionTime := 0

; Emacsキーバインド除外グループ
GroupAdd "EmacsExcludeBasic", "ahk_exe WindowsTerminal.exe"
GroupAdd "EmacsExcludeAdvanced", "ahk_exe WindowsTerminal.exe"
GroupAdd "EmacsExcludeAdvanced", "ahk_exe Code.exe"

; ブラウザグループ
GroupAdd "Browser", "ahk_exe chrome.exe"
GroupAdd "Browser", "ahk_exe msedge.exe"
; GroupAdd "Browser", "ahk_exe firefox.exe"
; GroupAdd "Browser", "ahk_exe brave.exe"
; GroupAdd "Browser", "ahk_exe opera.exe"

; ファイラーグループ
GroupAdd "Filer", "ahk_exe explorer.exe"

; ====================================================================
; Emacsキーバインド
; ====================================================================

; 基本カーソル操作 (ほとんどのアプリケーションで有効)
#HotIf ! WinActive("ahk_group EmacsExcludeBasic")
    ; 文字削除
    LCtrl & h::SendInput "{BS}"       ; Ctrl+H: バックスペース
    LCtrl & d::SendInput "{Del}"      ; Ctrl+D: 削除
    
    ; カーソル移動
    LCtrl & a::SendInput "{HOME}"     ; Ctrl+A: 行頭へ
    LCtrl & e::SendInput "{END}"      ; Ctrl+E: 行末へ
    LCtrl & f::SendInput "{Right}"    ; Ctrl+F: 右へ
    LCtrl & b::SendInput "{Left}"     ; Ctrl+B: 左へ
    LCtrl & p::SendInput "{Up}"       ; Ctrl+P: 上へ
    LCtrl & n::SendInput "{Down}"     ; Ctrl+N: 下へ
#HotIf

; 拡張テキスト編集 (コード編集アプリケーションは除外)
#HotIf ! WinActive("ahk_group EmacsExcludeAdvanced")
    LCtrl & k::SendInput "{Shift down}{End}{Shift up}{Del}"  ; Ctrl+K: カーソル位置から行末まで削除
    LCtrl & w::SendInput "{Ctrl down}{Shift down}{Left}{Shift up}{Ctrl Up}{Del}"  ; Ctrl+W: 前の単語を削除
#HotIf

; ====================================================================
; カーソル移動 (macOS風)
; ====================================================================

; Shift+Option の組み合わせ
LAlt & Left:: {
    if GetKeyState("Shift", "P") {
        SendInput "^+{Left}"    ; Shift+Option+左: 単語左を選択
    } else {
        SendInput "^{Left}"     ; Option+左: 単語左へ
    }
}

LAlt & Right:: {
    if GetKeyState("Shift", "P") {
        SendInput "^+{Right}"   ; Shift+Option+右: 単語右を選択
    } else {
        SendInput "^{Right}"    ; Option+右: 単語右へ
    }
}

LAlt & Up::SendInput "{PgUp}"         ; Option+Up: ページアップ
LAlt & Down::SendInput "{PgDn}"       ; Option+Down: ページダウン

; Option+Backspace: 前の単語を削除
LAlt & BS::SendInput "^+{Left}{BS}"

; macOS特有の削除操作
LWin & BS::SendInput "+{Home}{BS}"    ; Command+Backspace: カーソル位置から行頭まで削除

; 行頭・行末移動と選択 (Command+矢印キー)
; ※ アプリケーション別に定義（重複を避けるため）

; ====================================================================
; ブラウザとファイラーの操作
; ====================================================================

; ブラウザ専用のキーバインド
#HotIf WinActive("ahk_group Browser")
    ; Command+矢印キー
    LWin & Up::SendInput "{HOME}"       ; Command+上: ページ先頭へ
    LWin & Down::SendInput "{END}"      ; Command+下: ページ末尾へ
    LWin & Left::SendInput "!{Left}"    ; Command+左: ブラウザバック
    LWin & Right::SendInput "!{Right}"  ; Command+右: ブラウザフォワード
#HotIf

; ファイラー専用のキーバインド
#HotIf WinActive("ahk_group Filer")
    ; Command+矢印キー
    LWin & Up::SendInput "^{Home}"      ; Command+上: 文書の先頭へ
    LWin & Down::SendInput "^{End}"     ; Command+下: 文書の末尾へ
    LWin & Left::SendInput "{Home}"     ; Command+左: 行頭へ移動
    LWin & Right::SendInput "{End}"     ; Command+右: 行末へ移動
    
    ; ファイル操作
    LWin & Delete::SendInput "{Delete}" ; Command+Delete: ゴミ箱に移動
    LWin & r::SendInput "{F5}"          ; Command+R: 更新
#HotIf

; ブラウザ、ファイラー以外のアプリケーション用キーバインド
#HotIf !WinActive("ahk_group Browser") && !WinActive("ahk_group Filer")
    ; Command+矢印キー
    LWin & Up::SendInput "^{Home}"      ; Command+上: 文書の先頭へ
    LWin & Down::SendInput "^{End}"     ; Command+下: 文書の末尾へ
    LWin & Left::SendInput "{Home}"     ; Command+左: 行頭へ移動
    LWin & Right::SendInput "{End}"     ; Command+右: 行末へ移動
#HotIf

; Command+Shift+矢印キー (行頭・行末選択) - 全アプリケーション共通
LWin & Left:: {
    if GetKeyState("Shift", "P") {
        ; Shift+Command+Left: 行頭まで選択
        global lastSelectionTime, lastSelectionDirection
        if (lastSelectionDirection = "right" && A_TickCount - lastSelectionTime < 2000) {
            SendInput "{Home}+{End}"  ; 1行全選択
        } else {
            SendInput "+{Home}"       ; 行頭まで選択
        }
        lastSelectionDirection := "left"
        lastSelectionTime := A_TickCount
    } else {
        ; Command+Left: 通常の行頭移動
        if WinActive("ahk_group Browser") {
            SendInput "!{Left}"       ; ブラウザバック
        } else {
            SendInput "{Home}"        ; 行頭へ移動
        }
    }
}

LWin & Right:: {
    if GetKeyState("Shift", "P") {
        ; Shift+Command+Right: 行末まで選択
        global lastSelectionTime, lastSelectionDirection
        if (lastSelectionDirection = "left" && A_TickCount - lastSelectionTime < 2000) {
            SendInput "{Home}+{End}"  ; 1行全選択
        } else {
            SendInput "+{End}"        ; 行末まで選択
        }
        lastSelectionDirection := "right"
        lastSelectionTime := A_TickCount
    } else {
        ; Command+Right: 通常の行末移動
        if WinActive("ahk_group Browser") {
            SendInput "!{Right}"      ; ブラウザフォワード
        } else {
            SendInput "{End}"         ; 行末へ移動
        }
    }
}

; 他のキーが押された時に選択状態をリセット
~*::{
    global lastSelectionDirection := ""
}

; ====================================================================
; タブ操作とアプリケーション切替
; ====================================================================

; タブ操作 (アプリケーション共通)
LWin & [::SendInput "^+{Tab}"       ; Command+[: 前のタブ
LWin & ]::SendInput "^{Tab}"        ; Command+]: 次のタブ

; Alt+Tab機能をLWin+Tabに割り当て
LWin & Tab:: {
    static init := false
    if (!init) {
        global isAltTabMenuActive
        init := true
    }

    ; すでにAlt+Tabメニューがアクティブな場合は、追加のTabのみ送信
    if (isAltTabMenuActive) {
        if GetKeyState("Shift", "P")
            Send "{Shift Down}{Tab}{Shift Up}"
        else
            Send "{Tab}"
        return
    }

    ; 新しいAlt+Tabセッションの開始
    isAltTabMenuActive := true
    if GetKeyState("Shift", "P")
        Send "{Alt Down}{Shift Down}{Tab}"
    else
        Send "{Alt Down}{Tab}"

    ; LWinのリリースを監視するタイマーを開始
    SetTimer(WatchLWin, 50)  ; 50ミリ秒間隔でチェック
}

; LWinキーのリリースを監視する関数
WatchLWin() {
    static init := false
    if (!init) {
        global isAltTabMenuActive
        init := true
    }

    if !GetKeyState("LWin", "P") && isAltTabMenuActive {
        ; LWinが離された時の処理
        Send "{Shift Up}{Alt Up}"
        isAltTabMenuActive := false
        SetTimer(WatchLWin, 0)  ; タイマーを停止
    }
}

; 元のAlt+Tabの動作を無効化して普通のTabキーとして機能させる
LAlt & Tab::SendInput "{Tab}"

; ====================================================================
; ウィンドウ操作関数
; ====================================================================

; ウィンドウを最大化
MaximizeWindow() {
    active_hwnd := WinGetID("A")
    DllCall("ShowWindow", "Ptr", active_hwnd, "Int", 3)  ; SW_MAXIMIZE = 3
}

; ウィンドウを元のサイズに戻す
RestoreWindow() {
    active_hwnd := WinGetID("A")
    DllCall("ShowWindow", "Ptr", active_hwnd, "Int", 9)  ; SW_RESTORE = 9
}

; ウィンドウの最大化状態をトグル
ToggleMaximize() {
    If WinGetMinMax("A") = 1  ; 最大化状態なら
        RestoreWindow()        ; 元に戻す
    else
        MaximizeWindow()       ; 最大化する
}

; ウィンドウを最小化
MinimizeWindow() {
    active_hwnd := WinGetID("A")
    DllCall("ShowWindow", "Ptr", active_hwnd, "Int", 6)  ; SW_MINIMIZE = 6
}

; 同じアプリの全ウィンドウを最小化
MinimizeAllWindows() {
    active_exe := WinGetProcessPath("A")       ; アクティブウィンドウのプロセスパスを取得
    windows := WinGetList()                    ; 全ウィンドウのリストを取得
    for window in windows {
        try {
            window_exe := WinGetProcessPath(window)
            ; 同じプロセスのウィンドウを最小化
            if (window_exe && window_exe = active_exe)
                DllCall("ShowWindow", "Ptr", window, "Int", 6)  ; SW_MINIMIZE = 6
        } catch Error {
            continue  ; アクセスできないウィンドウは無視
        }
    }
}

; アクティブなアプリ以外の全ウィンドウを最小化
MinimizeOtherWindows() {
    active_exe := WinGetProcessPath("A")      ; アクティブウィンドウのプロセスパスを取得
    windows := WinGetList()                   ; 全ウィンドウのリストを取得
    for window in windows {
        try {
            window_exe := WinGetProcessPath(window)
            ; アクティブなプロセスと異なるプロセスのウィンドウのみを最小化
            if (window_exe && window_exe != active_exe)
                DllCall("ShowWindow", "Ptr", window, "Int", 6)  ; SW_MINIMIZE = 6
        } catch Error {
            continue  ; アクセスできないウィンドウは無視
        }
    }
}

; ====================================================================
; アプリケーション操作ホットキー
; ====================================================================

; アプリケーション終了と閉じる
LWin & q:: {
    if GetKeyState("Shift", "P") {
        ; Shift+Command+Q: 確認付きログアウト
        result := MsgBox("ログアウトしますか？", "確認", "OKCancel Default2")
        if (result = "OK")
            DllCall("ExitWindowsEx", "UInt", 0, "UInt", 0)
    } else {
        ; Command+Q: アプリケーションを終了
        SendInput "!{F4}"
    }
}

LWin & w::SendInput "^{F4}"          ; Command+W: ウィンドウ/タブを閉じる

; Command+` ウィンドウ切替（Shiftで方向制御）
LWin & vkC0:: {
    static init := false
    if (!init) {
        global isWindowSwitcherActive, windowSwitcherDirection
        global switcherWindowList, switcherCurrentIndex, switcherOriginalHwnd
        init := true
    }
    
    ; Shiftキーで方向を決定
    shift_pressed := GetKeyState("Shift", "P")
    
    ; すでにウィンドウ切替がアクティブなら次/前に移動
    if (isWindowSwitcherActive) {
        if (shift_pressed)
            WindowSwitcherPrev()
        else
            WindowSwitcherNext()
        return
    }
    
    ; 新しいウィンドウ切替セッションの開始
    isWindowSwitcherActive := true
    windowSwitcherDirection := shift_pressed
    
    ; 同一アプリのウィンドウリストを取得して保存
    InitWindowSwitcher()
    
    ; 最初の切り替え実行
    if (shift_pressed)
        WindowSwitcherPrev()
    else
        WindowSwitcherNext()
    
    ; LWinキーのリリースを監視するタイマーを開始
    SetTimer(WatchLWinForWindowSwitcher, 50)
}

; LWinキーのリリースを監視する関数（ウィンドウ切替用）
WatchLWinForWindowSwitcher() {
    static init := false
    if (!init) {
        global isWindowSwitcherActive
        init := true
    }

    if !GetKeyState("LWin", "P") && isWindowSwitcherActive {
        ; LWinが離された時の処理
        isWindowSwitcherActive := false
        SetTimer(WatchLWinForWindowSwitcher, 0)  ; タイマーを停止
        
        ; セッションリセット
        ResetWindowSwitcher()
    }
}

; ウィンドウ切替を初期化
InitWindowSwitcher() {
    global switcherWindowList := []
    global switcherCurrentIndex := 0
    global switcherOriginalHwnd := WinGetID("A")
    
    ; アクティブなウィンドウの情報を取得
    active_exe := WinGetProcessName("A")
    
    if (!active_exe)
        return
    
    ; 同一アプリのウィンドウをリストアップ
    app_windows := WinGetList("ahk_exe " . active_exe)
    
    ; 有効なウィンドウを追加
    for window in app_windows {
        try {
            ; ウィンドウが可視かつ最小化されていないことを確認
            if (WinGetStyle(window) & 0x10000000) && !(WinGetMinMax(window) = -1) {
                title := WinGetTitle(window)
                class := WinGetClass(window)
                
                ; Explorer特殊ウィンドウをスキップ
                if (active_exe = "explorer.exe") {
                    if (class = "Shell_TrayWnd" || class = "Shell_SecondaryTrayWnd" || 
                        class = "Progman" || class = "WorkerW" || title = "Program Manager" ||
                        title = "")
                        continue
                }

                ; 特殊なIME関連ウィンドウをスキップ
                if (InStr(title, "Default IME") || InStr(title, "MSCTFIME") || 
                    title = "Start" || InStr(title, "Windows.UI.Core"))
                    continue

                ; 特殊なウィンドウを除外
                if (title != "") {
                    switcherWindowList.Push(window)
                    
                    ; 現在のウィンドウのインデックスを記録
                    if (window = switcherOriginalHwnd)
                        switcherCurrentIndex := switcherWindowList.Length
                }
            }
        } catch Error {
            continue
        }
    }
}

; ウィンドウ切替をリセット
ResetWindowSwitcher() {
    global switcherWindowList := []
    global switcherCurrentIndex := 0
    global switcherOriginalHwnd := 0
}

; 次のウィンドウに切り替え
WindowSwitcherNext() {
    global switcherWindowList, switcherCurrentIndex
    
    ; ウィンドウが1つしかない場合は何もしない
    if (switcherWindowList.Length <= 1)
        return
    
    ; 次のウィンドウのインデックスを計算
    switcherCurrentIndex := switcherCurrentIndex + 1
    if (switcherCurrentIndex > switcherWindowList.Length)
        switcherCurrentIndex := 1
    
    ; 切替先のウィンドウ
    target_hwnd := switcherWindowList[switcherCurrentIndex]
    
    ; ウィンドウをアクティブにする
    if WinExist("ahk_id " . target_hwnd)
        WinActivate("ahk_id " . target_hwnd)
}

; 前のウィンドウに切り替え
WindowSwitcherPrev() {
    global switcherWindowList, switcherCurrentIndex
    
    ; ウィンドウが1つしかない場合は何もしない
    if (switcherWindowList.Length <= 1)
        return
    
    ; 前のウィンドウのインデックスを計算
    switcherCurrentIndex := switcherCurrentIndex - 1
    if (switcherCurrentIndex < 1)
        switcherCurrentIndex := switcherWindowList.Length
    
    ; 切替先のウィンドウ
    target_hwnd := switcherWindowList[switcherCurrentIndex]
    
    ; ウィンドウをアクティブにする
    if WinExist("ahk_id " . target_hwnd)
        WinActivate("ahk_id " . target_hwnd)
}

; ウィンドウ操作のホットキー - Control+Command組み合わせ
LCtrl & f:: {
    if GetKeyState("LWin", "P") {
        ; Control+Command+F: フルスクリーンをトグル
        ToggleMaximize()
    }
    ; 通常のCtrl+FはEmacsキーバインドで処理済み
}

LWin & m:: {
    if GetKeyState("LAlt", "P") {
        ; Command+Option+M: すべてのウィンドウを最小化
        MinimizeAllWindows()
    } else {
        ; Command+M: ウィンドウを最小化
        MinimizeWindow()
    }
}

LWin & h:: {
    if GetKeyState("LAlt", "P") {
        ; Command+Option+H: 他のウィンドウを隠す（最小化）
        MinimizeOtherWindows()
    } else {
        ; Command+H: ウィンドウを隠す（最小化）
        MinimizeWindow()
    }
}

; ====================================================================
; システム操作ホットキー
; ====================================================================

; ロック - Control+Command+Q
LCtrl & q:: {
    if GetKeyState("LWin", "P") {
        ; Control+Command+Q: 画面ロック
        DllCall("LockWorkStation")
    }
    ; 通常のCtrl+Qは何もしない（アプリ終了と混同を避ける）
}

; ====================================================================
; スクリーンショットと入力切替
; ====================================================================

; スクリーンショット
LWin & 3:: {
    if GetKeyState("Shift", "P") {
        ; Shift+Command+3: 画面全体のスクリーンショット
        SendInput "#{PrintScreen}"
    }
}

LWin & 4:: {
    if GetKeyState("Shift", "P") {
        ; Shift+Command+4: 範囲選択スクリーンショット
        SendInput "#+s"
    }
}

; 入力ソースの切替
LCtrl & Space:: {
    static init := false
    if (!init) {
        global isLangSwitcherActive
        init := true
    }

    ; すでに入力切替メニューがアクティブな場合は、追加のSpaceのみ送信
    if (isLangSwitcherActive) {
        Send "{Space}"
        return
    }

    ; 新しい入力切替セッションの開始
    isLangSwitcherActive := true
    Send "{LWin down}{Space}"

    ; LCtrlのリリースを監視するタイマーを開始
    SetTimer(WatchLCtrlForLangSwitcher, 50)  ; 50ミリ秒間隔でチェック
}

; 左Ctrlキーのリリースを監視する関数（入力ソース切替用）
WatchLCtrlForLangSwitcher() {
    static init := false
    if (!init) {
        global isLangSwitcherActive
        init := true
    }

    if !GetKeyState("LControl", "P") && isLangSwitcherActive {
        ; 左Ctrlが離された時の処理
        Send "{LWin up}"
        isLangSwitcherActive := false
        SetTimer(WatchLCtrlForLangSwitcher, 0)  ; タイマーを停止
    }
}
