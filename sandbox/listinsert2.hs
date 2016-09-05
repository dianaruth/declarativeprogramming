listInsert :: Ord a => a -> [a] -> [a]
listInsert elt [] = [elt]
listinsert elt (x:xs)
    | elt <= x = elt:x:xs
    | otherwise = x:listinsert elt xs
