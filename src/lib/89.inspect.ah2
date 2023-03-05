#include ./4.assert/0.index.ah2
#include ./1.util/0.index.ah2
class zz_PropDescEnumerable {
    __New(target, depth := 0) {
        this.Target := target
        this.Depth := depth

    }
    __Enum(numParams) {
        if numParams != 2 {
            throw zInvalidCallError(this.__Enum, "you can only enumerate this with 2 params, but was " numParams)
        }
        target := this.Target
        state := target.OwnProps().__Enum(1)
        maxDepth := this.Depth
        curDepth := 1
        iterate(&key, desc?) {
            if state(&key) {
                desc := target.GetOwnPropDesc(key)
                desc.DefineProp("owner", target)
                desc.DefineProp("depth", curDepth)
                return True
            }
            if depth = 1 {
                return False
            }
            if not state(&key) {
                if depth = 1 {
                    return False
                }
                depth--
                target := target.Base
                if not target {
                    return False
                }
                state := target.OwnProps().__Enum(1)
                return iterate(&key, desc)
            }

        }
        return iterate
    }
}

zGetPropDescs(self, depth := 1) {
    zExpectArg(depth, "depth").toBeAtLeast(0).toBeIntLike()
    zExpectArg(self, "self").toBeObjectLike()
    return zz_PropDescEnumerable(self)
}