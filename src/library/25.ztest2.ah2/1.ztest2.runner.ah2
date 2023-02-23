#include ..
#include 01.zinit.ah2
#include 08.zassert.ah2
#include 03.zstack.ah2

class zz_Test2 {
    Title := ""
    __New(title, testThis, testFunction) {
        this.%"testThis"% := testThis
        this.%""% := testFunction
    }
}
