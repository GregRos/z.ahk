class zz_assert {

    class Assertion {
        __New(isInverted, real) {
            this.Real := real
            this.IsInverted := isInverted
        }

    }

    class UnaryAssertion extends zz_assert.Assertion {
        kind := "unary"
        __New(isInverted, real, operator) {
            super.__New(isInverted, real)
            this.Operator := Format("{1}to {2}", this.IsInverted ? " not" : "", operator)
        }

        Text {
            get {
                return this.Operator
            }
        }

        ToString() {
            static relTemplate := zTemplate("Expected REAL {1}to {2.Type}, but was {2.Real}")
            return relTemplate(
                this.IsInverted ? "not " : "",
                this
            )
        }
    }

    class RelativeAssertion extends zz_assert.UnaryAssertion {
        kind := "relative"
        __New(isInverted, real, operator, value) {
            super.__New(isInverted, real, operator)
            this.Value := value
        }

        ToString() {
            return Format("Expected REAL {1} {2}, but it was {3} ", this.Text, zz_obj.toShortStr(this.Value), zz_obj.toShortStr(this.REAL))
        }
    }

}