@tool
class_name Hand
extends Node2D

@export var hand_radius: int = 2000 # Change to const
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

func add_card(new_card: Node2D):
	cards.append(new_card)
	add_child(new_card)
	new_card.mouse_entered.connect(_handle_card_touched)
	new_card.mouse_exited.connect(_handle_card_untouched)
	new_card.clicked.connect(_handle_card_click)
	reposition_cards()
	new_card.visible = true
	
func remove_card(card: Node2D):
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

func _update_card_transform(card: Node2D, angle_in_deg: float):
	card.set_position(_get_card_position(angle_in_deg))
	card.set_rotation(deg_to_rad(angle_in_deg + 90))
	
func _handle_card_touched(card: Card):
	for touched_card in touched_cards:
		cards[touched_card].unhighlight()
	touched_cards.append(cards.find(card))

func _handle_card_untouched(card: Card):
	var card_index = cards.find(card)
	touched_cards.erase(card_index)
	card.unhighlight()
	if highlight_index == card_index:
		highlight_index = -1
		
		
func _handle_card_click(card: Card):
	if card.highlighted:
		card.select_card()

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
	#	Debugging circle radius
	if debugcircle and (debugcircle.shape as CircleShape2D).radius != hand_radius:
		(debugcircle.shape as CircleShape2D).set_radius(hand_radius)
