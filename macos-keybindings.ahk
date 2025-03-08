#Requires AutoHotkey v2.0

/*
 * macOS風キーバインド for Windows
 * 
 * 前提:
 * HHKB/Realforce側で以下のキーマップを入れ替え済みであること
 *   - LCtrl (キー A の左の位置へ)    → macOSでのControlキー相当
 *   - LAlt → RCtrl                  → macOSでのCommandキー相当
 *   - LWin → LAlt                   → macOSでのOptionキー相当
 */

; ====================================================================
; グローバル変数とグループ定義
; ====================================================================

; Alt+Tab 管理用グローバル変数
global isAltTabMenuActive := false

; 入力ソース切替用のグローバル変数
global isLangSwitcherActive := false

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

; ====================================================================
; Emacsキーバインド
; ====================================================================

; 基本カーソル操作 (ほとんどのアプリケーションで有効)
#HotIf ! WinActive("ahk_group EmacsExcludeBasic")
    ; 文字削除
    <^h::SendInput "{BS}"       ; Ctrl+H: バックスペース
    <^d::SendInput "{Del}"      ; Ctrl+D: 削除
    
    ; カーソル移動
    <^a::SendInput "{HOME}"     ; Ctrl+A: 行頭へ
    <^e::SendInput "{END}"      ; Ctrl+E: 行末へ
    <^f::SendInput "{Right}"    ; Ctrl+F: 右へ
    <^b::SendInput "{Left}"     ; Ctrl+B: 左へ
    <^p::SendInput "{Up}"       ; Ctrl+P: 上へ
    <^n::SendInput "{Down}"     ; Ctrl+N: 下へ
#HotIf

; 拡張テキスト編集 (コード編集アプリケーションは除外)
#HotIf ! WinActive("ahk_group EmacsExcludeAdvanced")
    <^k::SendInput "{Shift down}{End}{Shift up}{Del}"  ; Ctrl+K: カーソル位置から行末まで削除
    <^w::SendInput "{Ctrl down}{Shift down}{Left}{Shift up}{Ctrl Up}{Del}"  ; Ctrl+W: 前の単語を削除
#HotIf

; ====================================================================
; カーソル移動 (macOS風)
; ====================================================================

; 単語単位のカーソル操作 (Option+矢印キー)
!Left::SendInput "^{Left}"      ; Option+左: 単語左へ
!Right::SendInput "^{Right}"    ; Option+右: 単語右へ
+!Left::SendInput "^+{Left}"    ; Shift+Option+左: 単語左を選択
+!Right::SendInput "^+{Right}"  ; Shift+Option+右: 単語右を選択

; ページ移動
!Up::SendInput "{PgUp}"         ; Option+Up: ページアップ
!Down::SendInput "{PgDn}"       ; Option+Down: ページダウン

; ====================================================================
; ブラウザとファイラーの操作
; ====================================================================

; ブラウザ専用のキーバインド
#HotIf WinActive("ahk_group Browser")
    ; ページ操作
    >^Up::SendInput "{HOME}"       ; Command+上: ページ先頭へ
    >^Down::SendInput "{END}"      ; Command+下: ページ末尾へ
    
    ; ナビゲーション
    >^Left::SendInput "!{Left}"    ; Command+左: ブラウザバック
    >^Right::SendInput "!{Right}"  ; Command+右: ブラウザフォワード
    >^[::SendInput "!{Left}"       ; Command+[: ブラウザバック
    >^]::SendInput "!{Right}"      ; Command+]: ブラウザフォワード
#HotIf

; ブラウザ以外のアプリケーション用キーバインド
#HotIf !WinActive("ahk_group Browser")
    >^Up::SendInput "!{Up}"        ; Command+上: 上の階層へ
    >^Down::SendInput "!{Down}"    ; Command+下: フォルダを開く
    >^Left::SendInput "!{Left}"    ; Command+左: 戻る
    >^Right::SendInput "!{Right}"  ; Command+右: 進む
#HotIf

; タブ操作 (アプリケーション共通)
>^+[::SendInput "^+{Tab}"       ; Command+Shift+[: 前のタブ
>^+]::SendInput "^{Tab}"        ; Command+Shift+]: 次のタブ

; ====================================================================
; Windows RCtrl(Command)+Tab を Alt+Tab に入れ替え
; ====================================================================

; Alt+Tab機能をRCtrl(Command)+Tabに割り当て
>^Tab:: {
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

    ; 右Ctrlのリリースを監視するタイマーを開始
    SetTimer(WatchRCtrl, 50)  ; 50ミリ秒間隔でチェック
}

; RCtrl(Command)キーのリリースを監視する関数
WatchRCtrl() {
    static init := false
    if (!init) {
        global isAltTabMenuActive
        init := true
    }

    if !GetKeyState("RCtrl", "P") && isAltTabMenuActive {
        ; 右Ctrlが離された時の処理
        Send "{Shift Up}{Alt Up}"
        isAltTabMenuActive := false
        SetTimer(WatchRCtrl, 0)  ; タイマーを停止
    }
}

; 元のAlt+Tabの動作を無効化して普通のTabキーとして機能させる
!Tab::SendInput "{Tab}"
+!Tab::SendInput "+{Tab}"

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
>^q::SendInput "!{F4}"          ; Command+Q: アプリケーションを終了
>^w::SendInput "^{F4}"          ; Command+W: ウィンドウ/タブを閉じる

; ウィンドウ操作のホットキー
>^<^f::ToggleMaximize()          ; Command+Control+F: フルスクリーンをトグル
>^m::MinimizeWindow()            ; Command+M: ウィンドウを最小化
>^!m::MinimizeAllWindows()       ; Command+Option+M: すべてのウィンドウを最小化
>^h::MinimizeWindow()            ; Command+H: ウィンドウを隠す（最小化）
>^!h::MinimizeOtherWindows()     ; Command+Option+H: 他のウィンドウを隠す（最小化）

; ====================================================================
; システム操作ホットキー
; ====================================================================

; ログアウト確認ダイアログ表示
ConfirmAndLogout() {
    result := MsgBox("ログアウトしますか？", "確認", "OKCancel Default2")
    if (result = "OK")
        DllCall("ExitWindowsEx", "UInt", 0, "UInt", 0)
}

; ロックとログアウト
>^<^q::DllCall("LockWorkStation")  ; Control+Command+Q: 画面ロック
>^+!q::DllCall("ExitWindowsEx", "UInt", 0, "UInt", 0) ; Command+Option+Shift+Q: 即時ログアウト
>^+q::ConfirmAndLogout()           ; Command+Shift+Q: 確認付きログアウト

; ====================================================================
; スクリーンショットと入力切替
; ====================================================================

; スクリーンショット
>^+3::SendInput "#{PrintScreen}" ; Command+Shift+3: 画面全体のスクリーンショット
>^+4::SendInput "#+s"            ; Command+Shift+4: 範囲選択スクリーンショット

; 入力ソースの切替
<^Space:: {
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

    ; 左Ctrlのリリースを監視するタイマーを開始
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