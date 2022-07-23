#SingleInstance Force
#Warn All, Off
#include goops.ah2
gOops_Setup()

B() {
    A.X()
}

A() {
    B()
}

A()
MsgBox "hi!"
