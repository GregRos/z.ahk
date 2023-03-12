class zz_sys {
    static getCurrentPid() {
        DetectHiddenWindows True
        pid := WinGetPID("ahk_id " A_ScriptHwnd)
        DetectHiddenWindows False
        return pid
    }
}