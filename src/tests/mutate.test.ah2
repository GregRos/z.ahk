#include ../lib/0.index.ah2

class Mutate_tests extends zTestSuite {

    zRemove_array() {
        arr := [1, 2, 3, 4]
        zRemove(arr, (ix, v) => v <= 4 and ix == 2)
        zExpect(arr).toEqual([1, 3, 4])
        zRemove(arr, x => x <= 3)
        zExpect(arr).toEqual([4])
        zRemove(arr, x => x == 4)
        zExpect(arr).toEqual([])
        zRemove(arr, x => True)
        zExpect(arr).toEqual([])
    }

    zRemove_map() {
        myMap := Map("a", 1, "b", 2, "c", 3, "d", 4)
        zRemove(myMap, x => x == 2)
        zExpect(myMap).toEqual(Map("a", 1, "c", 3, "d", 4))
        zRemove(myMap, x => x <= 3)
        zExpect(myMap).toEqual(Map("d", 4))
        zRemove(myMap, x => x == 4)
        zExpect(myMap).toEqual(Map())
        zRemove(myMap, x => True)
        zExpect(myMap).toEqual(Map())
    }

    zPull_array() {
        arr := [1, 1, 2,  3]
        zPull(arr, 1)
        zExpect(arr).toEqual([2, 3])
        zPull(arr, 2, 3)
        zExpect(arr).toEqual([])
        zPull(arr, 1)
        zExpect(arr).toEqual([])
    }

    zPull_map() {
        myMap := Map("a", 1, "b", 2, "c", 3, "d", 1)
        zPull(myMap, 1)
        zExpect(myMap).toEqual(Map("b", 2, "c", 3))
        zPull(myMap, 2, 3)
        zExpect(myMap).toEqual(Map())
        zPull(myMap, 1)
        zExpect(myMap).toEqual(Map())
    }




}