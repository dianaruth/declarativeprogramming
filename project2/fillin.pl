% Load the correct transpose/2 predicate
:- ensure_loaded(library(clpfd)).

% main(PuzzleFile, WordlistFile, Solutionfile)
% should hold when SolutionFile is a file that contains the solved version
% of the puzzle in PuzzleFile using the words in WordlistFile. The underscores
% in the Solutionfile should be replaced with characters from the words in
% WordlistFile, and each row or column of contiguous underscores in PuzzleFile
% should be replaced with a word from WordlistFile in the Solutionfile.
main(PuzzleFile, WordlistFile, SolutionFile) :-
	read_file(PuzzleFile, Puzzle),
	read_file(WordlistFile, Wordlist),
	valid_puzzle(Puzzle),
	solve_puzzle(Puzzle, Wordlist, Solved),
	print_puzzle(SolutionFile, Solved).

% read_file(Filename, Content)
% should hold when Content is a list of lists where the outside list contains
% lists that represent each line in the file. Each inner list is a list of
% characters in the line.
read_file(Filename, Content) :-
	open(Filename, read, Stream),
	read_lines(Stream, Content),
	close(Stream).

% read_lines(Stream, Content)
% should hold when Content is a list of lists where the outside list contains
% lists that represent each line in the file. Each inner list is a list of
% characters in the line. Content comes from Stream, which is an open file.
read_lines(Stream, Content) :-
	read_line(Stream, Line, Last),
	(   Last = true
	->  (   Line = []
	    ->  Content = []
	    ;   Content = [Line]
	    )
	;  Content = [Line|Content1],
	    read_lines(Stream, Content1)
	).

% read_line(Stream, Line, Last)
% should hold when Stream is an open file, Line is a line from the file, and
% Last is a boolean indicating whether or not Line is the last line in the file.
% Last will be true if Line is the last line in the file and false otherwise.
read_line(Stream, Line, Last) :-
	get_char(Stream, Char),
	(   Char = end_of_file
	->  Line = [],
	    Last = true
	; Char = '\n'
	->  Line = [],
	    Last = false
	;   Line = [Char|Line1],
	    read_line(Stream, Line1, Last)
	).

% print_puzzle(SolutionFile, Puzzle)
% should hold when SolutionFile is a file that Puzzle should be printed to
% and Puzzle is a list of lists where each inner list is a list of characters
% representing a line of the puzzle.
print_puzzle(SolutionFile, Puzzle) :-
	open(SolutionFile, write, Stream),
	maplist(print_row(Stream), Puzzle),
	close(Stream).

% print_row(Stream, Row)
% should hold when Row is a list of characters representing a row of the
% puzzle and Stream is an open file that Row should be output to.
print_row(Stream, Row) :-
	maplist(put_puzzle_char(Stream), Row),
	nl(Stream).

% put_puzzle_char(Stream, Char)
% should hold when Stream is an open file and Char is a single character
% that is output to Stream.
put_puzzle_char(Stream, Char) :-
	(   var(Char)
	->  put_char(Stream, '_')
	;   put_char(Stream, Char)
	).

% valid_puzzle(List)
% should hold when List is a list of lists where the inner lists contain
% characters and each list in List is the same length.
valid_puzzle([]).
valid_puzzle([Row|Rows]) :-
	maplist(samelength(Row), Rows).

% samelength(L1, L2)
% should hold when L1 and L2 are lists that have the same number of elements.
samelength([], []).
samelength([_|L1], [_|L2]) :-
	same_length(L1, L2).


% solve_puzzle(Puzzle, Words, Solved)
% should hold when Solved is a solved version of Puzzle, with the
% empty slots filled in with words from Words.  Puzzle and Solved
% should be lists of lists of characters (single-character atoms), one
% list per puzzle row. Words is also a list of lists of
% characters, one list per word.

solve_puzzle(Puzzle, Words, Solved) :-
	convert_puzzle(Puzzle, A),
	print(A).

% convert_puzzle(L1, L2)
% should hold when L2 and L1 contain lists, and L2 contains the lists in L1
% when the elements have been converted according to the predicate convert/2.
convert_puzzle([],[]).
convert_puzzle([E1|Rest1],[E2|Rest2]) :-
	convert(E1, E2),
	convert_puzzle(Rest1, Rest2).

% convert(L1, L2)
% should hold when the elements of L2 are the elements of L1 when each element
% has been changed based on the fillable/2 predicate.
convert([], []).
convert([E1|Rest1], [E2|Rest2]) :-
	fillable(E1, E2),
	convert(Rest1, Rest2).

% fillable(A, B)
% should hold when B is either blocked (if A is the # character), fill(A) (if
% A is a character), or fill(_) (if A is the underscore character).
fillable('#', blocked).
fillable('_', fill(_)).
fillable(A, fill(A)) :-
	char_type(A, alpha).
