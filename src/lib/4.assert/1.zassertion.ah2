class zz_assert {

    class Assertion {
        __New(isInverted, real) {
            this.Real := real
            this.IsInverted := isInverted
        }
        
    }

    class TypeAssertion extends zz_assert.Assertion {
        kind := "type"
        __New(isInverted, real, type) {
            super.__New(isInverted, real)
            this.Type := type
        }

        ToString() {
            static relTemplate := zTemplate("Expected REAL {1}to {2.Type}, but was {2.Real}")
            return relTemplate(
                this.IsInverted ? "not " : "",
                this
            )
        }
    }

    class RelationAssertion extends zz_assert.Assertion {
        kind := "relation"
        __New(isInverted, real, relation, value) {
            super.__New(isInverted, real)
            this.Relation := relation
            this.Value := value
        }

        ToString() {
            static relTemplate := zTemplate("Expected REAL {1}to {2.Relation} {2.Value}, but was {2.Real}.")
            return relTemplate(
                this.IsInverted ? "not " : "",
                this
            )
        }
    }
}