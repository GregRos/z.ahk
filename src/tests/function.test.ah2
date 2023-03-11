#include ../lib/0.index.ah2

class Function_tests extends zTestSuite {
    zConst() {
        c := zConst(5)
        zExpect(c()).toBe(5)
        zExpect(c(1, 2, 3)).toBe(5)
    }
}