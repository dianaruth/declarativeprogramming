quadRoots :: Double -> Double -> Double -> [Double]
quadRoots 0 0 _ = error "Either a or b must be non-zero"
quadRoots 0 b c = [-c / b]
quadRoots a b c
    | disc < 0  = error "No real solutions"
    | disc == 0 = [tp]
    | disc > 0  = [tp + temp, tp - temp]
    where   disc = b*b - 4*a*c
            temp = sqrt(disc) / (2*a)
            tp   = -b / (2*a)
