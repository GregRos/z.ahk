#include ../lib/0.index.ah2
class Fold_tests extends zTestSuite {
    Every() {
        zExpect(zEvery([1, 2, 3], x => x <= 3)).toBe(true)
        zExpect(zEvery([], x => False)).toBe(true)
        zExpect(zEvery([1, 2, 3], x => x <= 2)).toBe(false)
        zExpect(zEvery("aaaa", x => x == "a")).toBe(true)
    }

    Reduce() {
        zExpect(zReduce([1, 2, 3], (a, b) => a + b)).toBe(6)
        zExpect(zReduce([1, 2, 3], (a, b) => a + b, 10)).toBe(16)
        zExpect(zReduce([], (a, b) => a + b, 10)).toBe(10)
        zExpect(zReduce("aaaa", (a, b) => a "," b)).toBe("a,a,a,a")
    }

    Sum() {
        zExpect(zSum([1, 2, 3])).toBe(6)
        zExpect(zSum([])).toBe(0)
        zExpect(() => zSum("aaa")).toThrow()
        zExpect(() => zSum(["a"])).toThrow()
    }

    Product() {
        zExpect(zProduct([3, 1, 3])).toBe(9)
        zExpect(zProduct([])).toBe(1)
        zExpect(() => zProduct("aaa")).toThrow()
        zExpect(() => zProduct(["a"])).toThrow()
    }

    Min() {
        zExpect(zMin([3, 1, 3])).toBe(1)
        zExpect(() => zMin("aaa")).toThrow()
        zExpect(() => zMin(["a"])).toThrow()
        zExpect(() => zMin([])).toThrow()
    }
    
    Max() {
        zExpect(zMax([3, 1, 3])).toBe(3)
        zExpect(() => zMax("aaa")).toThrow()
        zExpect(() => zMax(["a"])).toThrow()
        zExpect(() => zMax([])).toThrow()
    }

    Length() {
        zExpect(zLength([3, 1, 3])).toBe(3)
        zExpect(zLength(Map("a", 1))).toBe(1)
        zExpect(zLength("aaa")).toBe(3)
        zExpect(zLength("")).toBe(0)
        zExpect(zLength([])).toBe(0)
    }

    Join() {
        zExpect(zJoin([1, 2, 3], ",")).toBe("1,2,3")
        zExpect(zJoin(["a", "b", "c"], ",")).toBe("a,b,c")
        zExpect(zJoin([], ",")).toBe("")
    }

}