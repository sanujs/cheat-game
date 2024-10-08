class_name Card
extends Control

enum Suit {SPADES, HEARTS, CLUBS, DIAMONDS}
# TODO: Finish ranks
enum Rank {TWO, THREE, FOUR, JACK, QUEEN, KING, ACE}

@export var rank: Rank = Rank.ACE
@export var suit: Suit = Suit.SPADES
@export var selected: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$State.text = str(Rank.keys()[rank]) + " of " + str(Suit.keys()[suit])

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
