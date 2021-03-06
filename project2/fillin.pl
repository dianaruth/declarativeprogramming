% fillin.pl
% Diana Ruth
% druth
% 851465

% This file implements solving fill-in puzzles using Prolog. Given the structure
% of a puzzle with free spaces represented by underscores and blocked spaces
% represented by pound symbols, as well as a list of words, the program solves
% the fill-in puzzle by inserting words into the slots so that every slot is
% a valid word in the word list.

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
	convert_puzzle(Puzzle, Converted, fillable),
	extract_puzzle_slots(Converted, Slots),
	extract_puzzle_slots(Converted, Slots),
	match_slots(Slots, Words),
	convert_puzzle(Converted, Solved, fillable_reverse).

% match_slots(Slots, Words)
% should hold when Slots is a list of slots (containing letters or variables)
% that has been filled with the words in Words. Each word in Words can only
% fit into one slot in Slots.
match_slots([], []).
match_slots(Slots, Words) :-
	match_lengths(Slots, Words, SlotsWithLengths),
	slot_with_min_matches(SlotsWithLengths, NextSlot),
	pick_match(NextSlot, Words, Match),
	convert(Match, ConvertedMatch, fillable),
	NextSlot = ConvertedMatch,
	select(Match, Words, NewWords),
	select(NextSlot, Slots, NewSlots),
	match_slots(NewSlots, NewWords).

% pick_match(Slot, Words, Match)
% should hold when Match is a word from Words that is compatible with Slot. That
% is, Match should be able to fit into Slot based on the variables and characters
% already contained in Slot. All of the possible words in Words that can fit into
% Slot are found and Match is the first word in that list.
pick_match(Slot, Words, Match) :-
	matches_for_slot(Slot, Words, [Match|_]).

% slot_with_min_matches(Lst, Slot)
% should hold when Slot is the slot that has the least number of matches out of
% all remaining slots. Lst is a list of key-value pairs where the key is the
% number of matches for the slot and the value is the slot. The slot with the
% least amount of matches is returned as Slot. The key-value pairs are sorted
% using the built-in predicate keysort/2.
slot_with_min_matches(Lst, Slot) :-
	keysort(Lst, [_-Slot|_]).

% match_lengths(Slots, Words, Lst)
% should hold when Lst is a list of key-value pairs where each key-value pair
% represents a slot. The key is the number of words in Words that can fit into
% the slot and the value is the slot. matches_for_slot/3 is used to determine
% the number of matches that each slot has.
match_lengths([], _, []).
match_lengths([S|Slots], Words, Lst) :-
	matches_for_slot(S, Words, M),
	length(M, Len),
	Lst = [Len-S|Ys],
	match_lengths(Slots, Words, Ys).

% matches_for_slot(Slot, Words, Matches)
% should hold when Matches is a list of the words in Words that can fit into
% Slot. compatible/2 is used to determine if a word is compatible with a slot.
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
compatible([fill(S)|Slot], [W|Word]) :-
	(atom(S)
	-> S == W,
	   compatible(Slot, Word)
	;  compatible(Slot, Word)
	).

% convert_puzzle(L1, L2, Pred)
% should hold when L2 and L1 contain lists, and L2 contains the lists in L1
% when the elements have been converted according to the predicate specified
% by Pred.
convert_puzzle([],[], _).
convert_puzzle([E1|Rest1],[E2|Rest2], Pred) :-
	convert(E1, E2, Pred),
	convert_puzzle(Rest1, Rest2, Pred).

% convert(L1, L2)
% should hold when the elements of L2 are the elements of L1 when each element
% has been changed using Pred.
convert([], [], _).
convert([E1|Rest1], [E2|Rest2], Pred) :-
	call(Pred, E1, E2),
	convert(Rest1, Rest2, Pred).

% fillable(A, B)
% should hold when B is either Char (if Char is an alphanumeric character) or
% a variable (if A is the underscore character).
fillable('#', blocked).
fillable('_', fill(_)).
fillable(Char, fill(Char)) :-
	char_type(Char, alpha).

% fillable_reverse(A, B)
% should hold when B is '#' (if A is the blocked atom) or Char (if A is fill(Char)
% and Char is an alphanumeric character).
fillable_reverse(blocked, '#').
fillable_reverse(fill(Char), Char) :-
	char_type(Char, alpha).

% extract_puzzle_slots(Puzzle, Slots)
% should hold when Slots is a list of all sequences of non-blocked atoms
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
% should hold when Slots is a list of the sequences of non-blocked atoms or
% atoms found in Row. Row can contain several such subsequences where variables
% and letter atoms are separated by any number of blocked atoms. Slots is a
% list containing all such subsequences, none containing blocked atoms.
extract_slots([], []).
extract_slots(Row, Slots) :-
	append(Row, [blocked], Row1),
    extract_slots(Row1, [], Slots).

% extract_slots(Row, Slot, Slots)
% should hold when Slots is a list of all the non-blocked subsequences that have
% been found so far in Row. Slot contains the running list of non-blocked
% atoms that have been found so far without encountering a blocked atom.
% When a blocked atom is reached, Slot is added to Slots. Otherwise, the current
% character is added to the current slot until a blocked character is reached.
extract_slots([], [], []).
extract_slots([X|Xs], Slot, Slots) :-
    (X == blocked
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
