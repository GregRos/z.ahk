#include ./4.assert/0.index.ah2
#include ./1.util/0.index.ah2
class zz_PropDescEnumerable {
    __New(target, depth := 0) {
        this.Target := target
        this.Depth := depth

    }
    __Enum(numParams) {
        zExpectArg(numParams, "numParams").toBeAtMost(2).toBeAtLeast(1)

        target := this.Target
        state := target.OwnProps().__Enum(1)
        maxDepth := this.Depth == 0
        curDepth := 1
        iterate(&key, desc?) {
            if state(&key) {
                if not IsSet(desc) {
                    return True
                }
                %desc% := target.GetOwnPropDesc(key)
                %desc%.DefineProp("owner", target)
                %desc%.DefineProp("depth", curDepth)
                return True
            }
            if curDepth = maxDepth and this.Depth != 0 {
                return False
            }
            curDepth++
            target := target.Base
            if not target {
                return False
            }
            state := target.OwnProps().__Enum(1)
            return iterate(&key, desc)

        }
        return iterate
    }
}

class zz_ProtoEnumerable {
    __New(target) {
        this.target := target
    }

    __Enum(numParams) {
        zExpectArg(numParams, "numParams").toBe(numParams)
        target := this.Target
        n := 1
        iterate(&key, val?) {
            key := 1
            if IsSet(val) {
                %val% := this.Target
            }
        }
    }
}

zGetPropDescs(self, depth := 0) {
    zExpectArg(depth, "depth").toBeAtLeast(0).toBeIntLike()
    zExpectArg(self, "self").toBeObjectLike()
    return zz_PropDescEnumerable(self)
}

