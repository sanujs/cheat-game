class_name Hand
extends Node2D

@export var hand_radius: int = 2000 # Change to const
@export var selected_radius: int = 100
@export var card_location_angle: int = -90
@export var card_scene: PackedScene
@export var angle_limit: float = 25
@export var max_card_spread_angle: float = 5

@onready var debugcircle = $DebugArea/DebugCircle

var cards: Array = []
var selected_cards: Array = []
var touched_cards: Array = []
var highlight_index: int = -1

func play_selected_cards() -> Array:
	var selected_card_strings = []
	for card: Card in selected_cards:
		selected_card_strings.append(card.card_str)
		remove_card(card)
	selected_cards.clear()
	return selected_card_strings

func add_card(new_card: Card):
	cards.append(new_card)
	add_child(new_card)
	new_card.mouse_entered.connect(_handle_card_touched)
	new_card.mouse_exited.connect(_handle_card_untouched)
	new_card.clicked.connect(_handle_card_click)
	new_card.visible = true
	
func remove_card(card: Card):
	cards.erase(card)
	remove_child(card)
	
func reposition_cards():
	var card_spread = min(angle_limit / cards.size(), max_card_spread_angle)
	var current_angle = -90 - (card_spread * (cards.size() - 1))/2
	for card in cards:
		_update_card_transform(card, current_angle)
		current_angle += card_spread

func _update_card_transform(card: Card, angle_in_deg: float):
	var selected = selected_cards.has(card)
	card.set_position(_get_card_position(angle_in_deg, selected))
	card.set_rotation(deg_to_rad(angle_in_deg + 90))

func _get_card_position(angle_in_deg: float, selected: bool) -> Vector2:
	var card_radius = _get_card_radius(selected)
	var x: float = card_radius * cos(deg_to_rad(angle_in_deg))
	var y: float = card_radius * sin(deg_to_rad(angle_in_deg))
	return Vector2(int(x), int(y))

func _get_card_radius(selected: bool) -> int:
	return hand_radius + selected_radius if selected else hand_radius

func _input(event: InputEvent) -> void:
#	Affects all cards
	if event.is_action_pressed("right_mouse"):
		for card in selected_cards:
#			Using the inverse of card.selected because we are about to change it
			var end_position_magnitude = _get_card_radius(!card.selected)
			card.select_card(card.get_position().normalized() * end_position_magnitude)

func _handle_card_click(card: Card):
	if card.highlighted:
#		Using the inverse of card.selected because we are about to change it
		var end_position_magnitude = _get_card_radius(!card.selected)
		card.select_card(card.get_position().normalized() * end_position_magnitude)

func _handle_card_touched(card: Card):
	touched_cards.append(cards.find(card))
	var keep_highlighted = touched_cards.max()
	for touched_card in touched_cards:
		if touched_card != keep_highlighted:
			cards[touched_card].unhighlight()

func _handle_card_untouched(card: Card):
	var card_index = cards.find(card)
	touched_cards.erase(card_index)
	card.unhighlight()
	if highlight_index == card_index:
		highlight_index = -1

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if not touched_cards.is_empty():
		highlight_index = touched_cards.max()
		cards[highlight_index].highlight()

	for card: Card in cards:
		if card.selected and not selected_cards.has(card):
			selected_cards.append(card)
		elif not card.selected:
			selected_cards.erase(card)
		reposition_cards()
	#	Debugging circle radius
	if debugcircle and (debugcircle.shape as CircleShape2D).radius != hand_radius:
		(debugcircle.shape as CircleShape2D).set_radius(hand_radius)
