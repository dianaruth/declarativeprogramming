module Guess (allCards, getAllPossibleSets, initialGuess, selectCards) where

import Card
import GameState
import Data.List

--initialGuess :: Int -> ([Card], GameState)
--initialGuess num =

allCards :: [Card]
allCards = [Card suit rank | suit <- [Club .. Spade], rank <- [R2 .. Ace]]

getAllPossibleSets :: Int -> [Card] -> [[Card]]
getAllPossibleSets 0 _ = []
getAllPossibleSets 1 _ = [[Card suit rank] | suit <- [Club .. Spade], rank <- [R2 .. Ace]]
getAllPossibleSets _ [] = []
getAllPossibleSets num (x:xs) = [x:others | others <- getAllPossibleSets (num - 1) xs] ++ getAllPossibleSets num xs

initialGuess :: Int -> [Card]--([Card], GameState)
initialGuess num = let numPossible = quot (length $ allCards) (num + 1)
                   in selectCards num numPossible allCards

selectCards :: Int -> Int -> [Card] -> [Card]
selectCards 0 _ _ = []
selectCards num range lst = lst!!(range * num) : (selectCards (num - 1) range lst)

--nextGuess :: ([Card], GameState) -> (Int, Int, Int, Int, Int) -> ([Card], GameState)
