acronym :: String -> String
acronym [] = []
acronym (c:cs) = c:acronym (skipOverWord cs)

skipOverWord :: String -> String
skipOverWord [] = []
skipOverWord (' ':cs) = cs
skipOverWord (_:cs) = skipOverWord cs

main = do
    acronym "International Business Machines"
