#SingleInstance Force
#Warn All, Off
#include library/01.bootstrap.ah2

#include library/06.zoops.ah2
zOops()
#include library/13.zchecks.ah2
#Include library/30.zarr.ah2

stuff() {
    x := Map()
    x.Set("a", "b")
    return x.HasOwnProp("a")
}

OutputDebug(stuff())

