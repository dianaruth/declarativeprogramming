recycle :: [t] -> [t]
recycle lst = lst ++ recycle lst
