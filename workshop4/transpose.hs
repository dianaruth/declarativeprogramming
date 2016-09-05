transpose :: [[a]] -> [[a]]
transpose [] = error "transpose of zero-height matrix"
transpose list@(xs:xss)
  | len > 0   = transpose' len list
  | otherwise = error "transpose of zero-width matrix"
  where len = length xs

transpose' len [] = replicate len []
transpose' len (xs:xss)
  | len == length xs = zipWith (:) xs (transpose' len xss)
  | otherwise = error "transpose of non-rectangular matrix"
