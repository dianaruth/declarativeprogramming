listinsert :: Int -> [Int] -> [Int]
listinsert a [] = [a]
listinsert a (x:xs)
    | a <= x = a:x:xs
    | otherwise = x:listinsert a xs
