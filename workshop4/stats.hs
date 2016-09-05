stats1 ns =
	(length ns,
	 sum ns,
	 sumsq ns
	)

sumsq [] = 0
sumsq (n:ns) = n*n + sumsq ns

stats2 [] = (0,0,0)
stats2 (n:ns) =
	let (l,s,sq) = stats2 ns
	in (l+1, s+n, sq+n*n)
