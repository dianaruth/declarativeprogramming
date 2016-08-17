module TicTacToe where

data State = Empty | O | X
data Row = Row1 | Row2 | Row3
data Column = Col1 | Col2 | Col3
data Square = TicTacToe Row Column
data SquareState = SquareState Square State
data Board = Board State State State
                   State State State
                   State State State
