#include 4.zzfunc.ah2
class zz_gen {

    static hasAny(arr, options*) {
        return zz_gen.has(options, arr, False)
    }

    static has(arr, item, caseMode := False) {
        for x in arr {
            if item == x {
                return True
            } else if not caseMode and item = x {
                return True
            }
        }
        return False
    }


}