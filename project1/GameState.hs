module GameState where

import Card

data GameState = GameState {possible :: [[Card]]}
                 deriving Show
