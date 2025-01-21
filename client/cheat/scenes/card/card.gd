class_name Card
extends Node2D

enum Suit {SPADES, HEARTS, CLUBS, DIAMONDS}
enum Rank {ACE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, TEN, JACK, QUEEN, KING}

signal clicked(card: Card)
signal mouse_entered(card: Card)
signal mouse_exited(card: Card)

@onready var card_front: Sprite2D = $CardFrontSprite
@onready var animation: AnimationPlayer = $AnimationPlayer
@export var rank: Rank = Rank.ACE
@export var suit: Suit = Suit.SPADES
@export var selected: bool = false

const SPEED: int = 8
var card_str: String = "AS"
var highlighted: bool = false
var t: float = 1.0
var start_position: Vector2
var end_position: Vector2

func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
#	Card click linear interpolation
	if t < 1.0:
		t += delta * SPEED
		self.position = start_position.lerp(end_position, t)

func select_card(new_position: Vector2):
	selected = not selected
#	Linear interpolation parameters
	start_position = position
	end_position = new_position
#	Setting t<1 triggers interpolation
	t = 0.0

func _set_values(_rank: Rank, _suit: Suit):
	rank = _rank
	suit = _suit
	
	var asset_filename = "res://assets/card_fronts/"

	match _suit:
		Suit.SPADES:
			asset_filename += "SPADE"
		Suit.HEARTS:
			asset_filename += "HEART"
		Suit.CLUBS:
			asset_filename += "CLUB"
		Suit.DIAMONDS:
			asset_filename += "DIAMOND"
	asset_filename += "-" + str(_rank+1) + ".svg"
	card_front.set_texture(load(asset_filename))

func set_values_from_string(characters: String):
	assert(len(characters) == 2)
	card_str = characters
	var _rank = char_to_rank(characters[0])
	var _suit = char_to_suit(characters[1])
	_set_values(_rank, _suit)

static func char_to_rank(character: String) -> Rank:
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
	return int(character)-1 as Rank

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
	if _rank > 8 or _rank == 0:
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


func highlight():
	if !highlighted:
		animation.play("hover")
	highlighted = true

func unhighlight():
	if highlighted:
		animation.play_backwards("hover")
	highlighted = false

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("left_mouse"):
		clicked.emit(self)

func _on_area_2d_mouse_entered() -> void:
	mouse_entered.emit(self)

func _on_area_2d_mouse_exited() -> void:
	mouse_exited.emit(self)
