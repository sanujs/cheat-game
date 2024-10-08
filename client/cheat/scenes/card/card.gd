class_name Card
extends Control

enum Suit {SPADES, HEARTS, CLUBS, DIAMONDS}
# TODO: Finish ranks
enum Rank {TWO, THREE, FOUR, JACK, QUEEN, KING, ACE}

@export var rank: Rank = Rank.ACE
@export var suit: Suit = Suit.SPADES
@export var selected: bool = false

@onready var rank_lbl: Label = $RankLbl
@onready var suit_lbl: Label = $SuitLbl

func _ready() -> void:
	visible = false

func set_values(_rank: Rank, _suit: Suit):
	rank = _rank
	suit = _suit

	rank_lbl.set_text(Rank.keys()[_rank])
	suit_lbl.set_text(Suit.keys()[_suit])

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
