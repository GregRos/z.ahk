#include ../library/40.zarr.ah2
#include ../library/23.ztest.api.ah2

my_empty := []
my_arr := [1, 2, 3]

class Array_operations extends zTestSuite {
    main() {
        super.isEqual(zArr(my_arr), my_arr)
        super.isEqual(zArr(), [])
    }

    range() {
        super.isEqual(zArr_Range(0, 3), [0, 1, 2])
        super.isEqual(zArr_Range(0, -2), [0, -1, -2])
    }
}
