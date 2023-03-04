#include ..\1.util\0.index.ah2
class zz_Assert2 {
    class Operator {
        __New(operator, text, ctx) {
            this._operator := operator
            this.Text := text
            this.Context := ctx
        }

        Call(REAL) {
            if not (this._operator)(REAL) {
                return 
            }
        }
    }

    class Message {
        __New(text, ctx) {
            this.Text := text
            this.Ctx := ctx
        }
    }

    
}
