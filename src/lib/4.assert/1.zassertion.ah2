class zz_assert {

    class Assertion {
        __New(isInverted, real) {
            this.Real := real
            this.IsInverted := isInverted
        }
    }

    class TypeAssertion extends zz_assert.Assertion {
        __New(isInverted, real, type) {
            super.__New(isInverted, real)
            this.Type := type
        }
    }

    class RelationAssertion extends zz_assert.Assertion {
        __New(isInverted, real, relation, value) {
            super.__New(isInverted, real)
            this.Relation := relation
            this.Value := value
        }
    }
}