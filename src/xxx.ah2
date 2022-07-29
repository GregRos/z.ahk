#SingleInstance Force
#Warn All, Off
#include library/01.bootstrap.ah2

b() {
    z := {}
    z.hello()
}

a() {
    b()
}

stuff() {
    a()
}

