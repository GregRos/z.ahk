class zz_cim {
    static Query(query, projection) {
        static cimv2 := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
            query := cimv2.ExecQuery(query)
            newEnum(this, vars) {
            enum := query._NewEnum()
            next(out) {
                for comOut in enum {
                    %out% := projection(comOut)
                    return 1
                }
                return 0

            }
            return next
        }
        return {
            __Enum: newEnum
        }
    }
}


class zProcess {
    __New(comInput) {
        this.Name := comInput.Name
        this.Pid := comInput.ProcessId
        this.ParentPid := comInput.ParentProcessId
        this.Path := comInput.ExecutablePath
        this.CommandLine := comInput.CommandLine
    }

    Parent {
        get => zProcess.ByPid(this.ParentPid)
    }

    Close() {
        ProcessClose(this.Pid)
    }

    static Query(query) {
        return zz_cim.Query(query, com => zProcess(com))
    }

    static QueryOne(query) {
        for process in this.Query(query) {
            return process
        }
    }

    static ByExe(path) {
        static query := zTemplate('Select * From Win32_Process where ExecutablePath = "{1}"')
        return this.Query(query(path))
    }

    static ByPid(pid) {
        static query := zTemplate("Select * From Win32_Process where ProcessId = {1}")
        return this.QueryOne(query(pid))
    }

    static Current {
        get => this.ByPid(zz_sys.getCurrentPid())
    }
}


zSystemHighlander() {
    exe := A_AhkPath
    processes := zProcess.ByExe(exe)
    for proc in processes {
        if InStr(proc.CommandLine, A_ScriptFullPath) {
            proc.Close()
        }
    }
}