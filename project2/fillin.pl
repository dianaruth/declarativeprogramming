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
	convert_puzzle(Puzzle, Converted),
	extract_puzzle_slots(Converted, Slots),
	match_slots(Slots, Words),
	Solved = Converted.

% match_slots(Slots, Words)
% should hold when Slots is a list of slots (containing letters or variables)
% that has been filled with the words in Words. Each word in Words can only
% fit into one slot in Slots.
match_slots([], []).
match_slots(Slots, Words) :-
	match_lengths(Slots, Words, MatchesWithLengths),
	pick_match(MatchesWithLengths, Slot, Match),
	Slot = Match,
	select(Match, Words, NewWords),
	select(Slot, Slots, NewSlots),
	match_slots(NewSlots, NewWords).

% pick_match(MatchesWithLengths, Match)
% should hold when Match is the first match of the slot with the lowest number
% of matches. MatchesWithLengths is a list of lists where the first element
% of each inner list is the number of compatible matches for a given slot. Each
% list in MatchesWithLengths represents a slot in the puzzle.
pick_match(MatchesWithLengths, Slot, Match) :-
	sort(MatchesWithLengths, [[Len, Slot, [Match|Tail]]|Sorted]).

% match_lengths(Slots, Words, MatchesWithLengths)
% should hold when MatchesWithLengths is a list where the first element is a
% list of matches for the slot at that position and the second element is the
% length of the list. The matches in MatchesWithLengths should be based on
% compatibility with Words.
match_lengths([], _, []).
match_lengths([S|Slots], Words, Lst) :-
	matches_for_slot(S, Words, M),
	length(M, Len),
	Lst = [[Len, S, M]|Ys],
	match_lengths(Slots, Words, Ys).

% matches_for_slot(Slot, Words, Matches)
% should hold when Matches is the list of all possible words that fit in Slot.
% Slot is the slot containing variables and letters, and Words is the list of
% all possible words that can fit in that slot.
matches_for_slot(_, [], []).
matches_for_slot(Slot, [W|Words], Matches) :-
	(compatible(Slot, W)
	-> Matches = [W|Ys]
	;  Matches = Ys
	),
	matches_for_slot(Slot, Words, Ys).

% compatible(Slot, Word)
% should hold when Word is able to fit into slot. That is, letters in Slot have
% to be in the same position as the same letter in Word. Slot and Word must
% also have the same length.
compatible([], []).
compatible([S|Slot], [W|Word]) :-
	(atom(S)
	-> S == W,
	   compatible(Slot, Word)
	;  compatible(Slot, Word)
	).

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
% should hold when B is either blocked (if A is the # character), Char (if
% Char is a character), or a variable (if A is the underscore character).
% fillable('#', blocked).
fillable('_', _).
fillable(Char, Char) :-
	atom(Char).

% extract_puzzle_slots(Puzzle, Slots)
% should hold when Slots is a list of all sequences of non-blocked variables
% or atoms in the puzzle, which we will call slots. First, all slots are found
% for each row in the puzzle. Then the puzzle is transposed and all slots are
% found for each column in the puzzle. Slots contains all the slots that have
% been found for each row and column in the puzzle. Slots of length 1 or less
% are removed because a slot must have two or more characters.
extract_puzzle_slots(Puzzle, Slots) :-
	extract_all_slots(Puzzle, RowSlots),
	transpose(Puzzle, Transposed),
	extract_all_slots(Transposed, ColumnSlots),
	append(RowSlots, ColumnSlots, SlotsBeforeRemove),
	exclude(short_list, SlotsBeforeRemove, Slots).

% extract_all_slots(Rows, Slots)
% should hold when Slots contains all the slots contained in every row in Rows.
% Rows is a list of rows of the puzzle that need to have the slots extracted
% and added to Slots. Slots should contain the accumulation of every possible
% slot found in Rows. A slot is defined by a subsequnce of non-blocked atoms
% or variables.
extract_all_slots([], []).
extract_all_slots([Row|Rows], Slots) :-
    extract_slots(Row, Slots1),
    append(Slots1, Ys, Slots),
    extract_all_slots(Rows, Ys).

% extract_slots(Row, Slots)
% should hold when Slots is a list of the sequences of non-blocked variables or
% atoms found in Row. Row can contain several such subsequences where variables
% and letter atoms are separated by any number of blocked atoms. Slots is a
% list containing all such subsequences, none containing blocked atoms.
extract_slots([], []).
extract_slots(Row, Slots) :-
	append(Row, ['#'], Row1),
    extract_slots(Row1, [], Slots).

% extract_slots(Row, Slot, Slots)
% should hold when Slots is a list of all the non-blocked subsequences that have
% been found so far in Row. Slot contains the running list of non-blocked
% variables that have been found so far without encountering a blocked atom.
% When a blocked atom is reached, Slot is added to Slots. Otherwise, the current
% character is added to the current slot until a blocked character is reached.
extract_slots([], [], []).
extract_slots([X|Xs], Slot, Slots) :-
    (X == '#'
    -> (Slot == []
	   -> Slots = Ys
	   ;
	   Slots = [Slot|Ys]
	   ),
       extract_slots(Xs, [], Ys)
	;  append(Slot, [X], Ys),
       extract_slots(Xs, Ys, Slots)
	).

% short_list(Lst)
% should hold when Lst contains zero elements or one element.
short_list(Lst) :-
	length(Lst, Len),
	Len =< 1.
