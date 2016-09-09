module Guess (initialGuess, nextGuess) where

import Card
import GameState
import Feedback
import Data.List

allCards :: [Card]
allCards = [Card suit rank | suit <- [Club .. Spade], rank <- [R2 .. Ace]]

getAllPossibleSets :: Int -> [Card] -> [[Card]]
getAllPossibleSets 0 _ = []
getAllPossibleSets _ [] = []
getAllPossibleSets 1 _ = [[Card suit rank] | suit <- [Club .. Spade], rank <- [R2 .. Ace]]
getAllPossibleSets num (x:xs) = let lst = [x:others | others <- getAllPossibleSets (num - 1) xs] ++ getAllPossibleSets num xs
                                in strictlyOrdered lst

strictlyOrdered :: (Ord a) => [[a]] -> [[a]]
strictlyOrdered [] = []
strictlyOrdered (x:xs) = if (strictlyOrdered' x) then x:(strictlyOrdered xs)
                         else strictlyOrdered xs

strictlyOrdered' :: (Ord a) => [a] -> Bool
strictlyOrdered' [] = True
strictlyOrdered' [x] = True
strictlyOrdered' (x1:x2:xs) = if (x1 < x2) then strictlyOrdered' (x2:xs)
                             else False

initialGuess :: Int -> ([Card], GameState)
initialGuess num = let sets = getAllPossibleSets num allCards
                       guess = middle sets
                   in (guess, GameState sets)

nextGuess :: ([Card], GameState) -> (Int,Int,Int,Int,Int) -> ([Card], GameState)
nextGuess (_, GameState [correct]) _ = (correct, GameState [])
nextGuess (prevGuess, GameState gs) f = let filtered = filter (\possibleAnswer -> feedback possibleAnswer prevGuess == f) gs
                                            updatedState = delete prevGuess filtered
                                        in (middle updatedState, GameState updatedState)

selectNextGuess :: (Ord a) => [[a]] -> [a]
selectNextGuess [] = []
selectNextGuess [x] = x
selectNextGuess lst
    | length lst > 100 = middle lst
    | otherwise = head lst

middle :: (Ord a) => [[a]] -> [a]
middle [] = []
middle [x] = x
middle lst = lst!!((quot (length lst) 2) - 1)
