class_name Hand
extends Node2D

@export var hand_radius: int = 1400 # Change to const
@export var card_location_angle: int = -90
@export var card_scene: PackedScene
@export var angle_limit: float = 25
@export var max_card_spread_angle: float = 5

var cards: Array = []
var selected_cards: Array = []

func play_selected_cards() -> Array:
	var selected_card_strings = []
	for card: Card in selected_cards:
		selected_card_strings.append(card.card_str)
		remove_card(card)
	selected_cards.clear()
	return selected_card_strings

func add_card(new_card: Control):
	cards.append(new_card)
	add_child(new_card)
	reposition_cards()
	
func remove_card(card: Control):
	cards.erase(card)
	remove_child(card)
	reposition_cards()
	
func reposition_cards():
	var card_spread = min(angle_limit / cards.size(), max_card_spread_angle)
	var current_angle = -90 - (card_spread * (cards.size() - 1))/2
	for card in cards:
		_update_card_transform(card, current_angle)
		current_angle += card_spread

func _get_card_position(angle_in_deg: float) -> Vector2:
	var x: float = hand_radius * cos(deg_to_rad(angle_in_deg))
	var y: float = hand_radius * sin(deg_to_rad(angle_in_deg))

	return Vector2(int(x), int(y))

func _update_card_transform(card: Control, angle_in_drag: float):
	card.set_position(_get_card_position(angle_in_drag))
	card.set_rotation(deg_to_rad(angle_in_drag + 90))

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	for card: Card in cards:
		if card.selected and not selected_cards.has(card):
			selected_cards.append(card)
		elif not card.selected:
			selected_cards.erase(card)
