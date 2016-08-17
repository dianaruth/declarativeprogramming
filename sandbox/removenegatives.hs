removenegatives :: [Int] -> [Int]
removenegatives [] = []
removenegatives (x:xs)
    | x < 0 = removenegatives xs
    | otherwise = x:removenegatives xs
