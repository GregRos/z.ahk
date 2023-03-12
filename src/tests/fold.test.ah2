#include ../lib/0.index.ah2
class Fold_tests extends zTestSuite {
    Every_array() {
        zExpect(zEvery([1, 2, 3], x => x <= 3)).toBe(true)
        zExpect(zEvery([], x => False)).toBe(true)
        zExpect(zEvery([1, 2, 3], x => x <= 2)).toBe(false)
    }

    Every_map() {
        zExpect(zEvery(Map("a", 1, "b", 2, "c", 3), x => x <= 3)).toBe(true)
        zExpect(zEvery(Map(), x => False)).toBe(true)
        zExpect(zEvery(Map("a", 1, "b", 2, "c", 3), (k, v) => StrLen(k) = 2)).toBe(false)
    }

    Reduce_array() {
        zExpect(zReduce([1, 2, 3], (a, b) => a + b)).toBe(6)
        zExpect(zReduce([1, 2, 3], (a, b) => a + b, 10)).toBe(16)
        zExpect(zReduce([], (a, b) => a + b, 10)).toBe(10)
    }

    Reduce_map() {
        zExpect(zReduce(Map("a", 1, "b", 2, "c", 3), (k, a, b) => k = "b" ? a : a + b)).toBe(4)
        zExpect(zReduce(Map("a", 1, "b", 2, "c", 3), (k, a, b) => a + b, 10)).toBe(16)
        zExpect(zReduce(Map(), (a, b) => a + b, 10)).toBe(10)
    }

    Sum() {
        zExpect(zSum(1, 2)).toBe(3)
        zExpect(zSum([1, 2, 3])).toBe(6)
        zExpect(zSum([1], 2, [3], 10)).toBe(16)
        zExpect(zSum()).toBe(0)
        zExpect(zSum([])).toBe(0)
        zExpect(zSum(Map("a", 2, "b", 3))).toBe(5)
        zExpect(() => zSum("aaa")).toThrow()
        zExpect(() => zSum(["a"])).toThrow()
    }

    Product() {
        zExpect(zProduct(1, 2)).toBe(2)
        zExpect(zProduct([3, 1, 3])).toBe(9)
        zExpect(zProduct([3], 1, [3], 10)).toBe(90)
        zExpect(zProduct()).toBe(1)
        zExpect(zProduct([])).toBe(1)
        zExpect(zProduct(Map("a", 1, "b", 3))).toBe(3)
        zExpect(() => zProduct("aaa")).toThrow()
        zExpect(() => zProduct(["a"])).toThrow()
    }

    Min() {
        zExpect(zMin(1, 5, 0)).toBe(0)
        zExpect(zMin([3, 1, 3])).toBe(1)
        zExpect(zMin([1], 4, [3], 10)).toBe(1)
        zExpect(zMin(Map("a", 5, "b", 3))).toBe(3)
        zExpect(() => zMin("aaa")).toThrow()
        zExpect(() => zMin(["a"])).toThrow()
        zExpect(() => zMin([])).toThrow()
    }

    Max() {
        zExpect(zMax([3, 1, 3])).toBe(3)
        zExpect(zMax([1], 4, [3], 10)).toBe(10)
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