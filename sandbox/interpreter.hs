data BoolExpr = BoolConst Bool
    | BoolOp BoolOp BoolExpr BoolExpr
    | CompOp CompOp IntExpr IntExpr

data IntExpr = IntConst Int
    | IntOp IntOp IntExpr IntExpr
    | IntIfThenElse BoolExpr IntExpr IntExpr

data BoolOp = And
data CompOp = LessThan
data IntOp = Plus | Times

boolExprValue :: BoolExpr -> Bool
boolExprValue (BoolConst a) = a
boolExprValue (BoolOp And b1 b2) =
    boolExprValue b1 && boolExprValue b2
...
