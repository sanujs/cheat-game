class_name Card
extends Control

enum Suit {SPADES, HEARTS, CLUBS, DIAMONDS}
# TODO: Finish ranks
enum Rank {TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, TEN, JACK, QUEEN, KING, ACE}

@export var rank: Rank = Rank.ACE
@export var suit: Suit = Suit.SPADES
@export var selected: bool = false

@onready var rank_lbl: Label = $RankLbl
@onready var suit_lbl: Label = $SuitLbl

var card_str: String = "AS"

func _ready() -> void:
	visible = false

func _set_values(_rank: Rank, _suit: Suit):
	rank = _rank
	suit = _suit

	rank_lbl.set_text(Rank.keys()[_rank])
	suit_lbl.set_text(Suit.keys()[_suit])

func set_values_from_string(characters: String):
	assert(len(characters) == 2)
	var _rank = char_to_rank(characters[0])
	var _suit = char_to_suit(characters[1])
	_set_values(_rank, _suit)
	card_str = characters

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if selected:
		$Color.color = Color.AQUA
	else:
		$Color.set_color(Color.WHITE)

func _gui_input(event: InputEvent) -> void:
#	Affects current control only
	if event.is_action_pressed("left_mouse"):
		selected = not selected

func _input(event: InputEvent) -> void:
#	Affects all controls
	if event.is_action_pressed("right_mouse"):
		selected = false

func char_to_rank(character: String) -> Rank:
	assert(len(character) == 1)
#	when character is not a number
	if not character.is_valid_int():
		match character:
			"T":
				return Rank.TEN
			"J":
				return Rank.JACK
			"Q":
				return Rank.QUEEN
			"K":
				return Rank.KING
			"A":
				return Rank.ACE
			"_":
				print("Not a valid character")
#				Default to ACE
				return Rank.ACE

#	calculate the Rank enum equivalent to the number
	return int(character)-2 as Rank

func char_to_suit(character: String) -> Suit:
	assert(len(character) == 1)
	match character:
		"S":
			return Suit.SPADES
		"H":
			return Suit.HEARTS
		"C":
			return Suit.CLUBS
		"D":
			return Suit.DIAMONDS
		"_":
			print("Not a valid suit")

#	Default to SPADES
	return Suit.SPADES

static func rank_to_char(_rank: Rank) -> String:
#	the char representation is the first character in ranks ten to ace
	if _rank > 7:
		return Rank.keys()[_rank][0]
	match _rank:
		Rank.TWO:
			return "2"
		Rank.THREE:
			return "3"
		Rank.FOUR:
			return "4"
		Rank.FIVE:
			return "5"
		Rank.SIX:
			return "6"
		Rank.SEVEN:
			return "7"
		Rank.EIGHT:
			return "8"
		Rank.NINE:
			return "9"
	return ""
