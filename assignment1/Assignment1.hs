module Assignment1 (elementPosition, everyNth, elementBefore) where

elementPosition :: Eq t => t -> [t] -> Int
elementPosition _ [] = error "Element cannot be found in empty list"
elementPosition elt (x:xs)
    | elt == x = 0
    | otherwise = 1 + elementPosition elt xs

everyNth :: Int -> [t] -> [t]
everyNth 0 _ = error "Invalid argument for n"
everyNth n [] = []
everyNth n lst
    | n <= length lst = head (drop (n - 1) lst) : everyNth n (drop n lst)
    | n > length lst = []

elementBefore :: Eq a => a -> [a] -> Maybe a
elementBefore n [] = Nothing
elementBefore n [_] = Nothing
elementBefore n (x:xs@(second:_))
    | x == n = Nothing
    | second == n   = Just x
    | otherwise = elementBefore n xs
