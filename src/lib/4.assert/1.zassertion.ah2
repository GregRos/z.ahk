class zz_assert {
    static strToPart(inverted) {
        
    }
    class Assertion {
        __New(isInverted, real) {
            this.Real := real
            this.IsInverted := isInverted
        }

        _txtToComponent {
            get {
                return Format("{1}to", this.IsInverted ? "not " : "")
            }
        }

    }

    class UnaryAssertion extends zz_assert.Assertion {
        kind := "unary"
        __New(isInverted, real, operator) {
            super.__New(isInverted, real)
            this.Operator := Format("{1}to {2}", this._txtToComponent, operator)
        }

        Text {
            get {
                return this.Operator
            }
        }

        ToString() {
            static relTemplate := zTemplate("Expected REAL {1}to {2.Type}, but was {2.Real}")
            return relTemplate(
                zz_assert.strToPart(this.IsInverted),
                this
            )
        }
    }

    class RelativeAssertion extends zz_assert.Assertion {
        kind := "relative"
        __New(isInverted, real, operator, value) {
            super.__New(isInverted, real)
            this.Operator := operator
            this.Value := value
        }

        ToString() {
            shortValue := zz_Inspect(this.Value).shortString
            shortReal := zz_Inspect(this.Real).shortString
            return Format(
                "Expected REAL {1} {2} {3}, but it was {3} ",
                this._txtToComponent, this.Operator,  shortValue, shortReal
            )
        }
    }

    class PropertyAssertion extends zz_assert.Assertion {
        kind := "property"
        __New(isInverted, property, real, assertion) {
            super.__New(isInverted, real)
            this.Property := property
            this.Inner := assertion
        }

        ToString() {
            ; Expected every item of REAL [to be an integer]
            ;         ^ property          ^assertion
            ; Expected every item of REAL [to equal]    [5]
            ;         ^ property          ^assertion  ^value
            static relativeTemplate := zTemplate(
                "Expected {.Property} of REAL {.Inner._txtToComponent} {.Inner.Operator} {.Inner.Value}"
            )
            static unaryTemplate := zTemplate(
                "Expected {.Property} of REAL {.Inner._txtToComponent} {.Inner.Operator}"
            )
            switch this.Inner.kind {
                case "relative":
                    return relativeTemplate(this)
                case "unary":
                    return unaryTemplate(this)
            }
        }
    }

}