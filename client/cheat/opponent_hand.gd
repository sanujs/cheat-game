extends Node2D
class_name OpponentHand

@export var hand_size: int = 0
var max_card_spread: int = 150
var max_width: int = 2500
var cards: Array = []
var card_back: Texture2D = load("res://assets/card_back_real.svg")


func set_hand_size(size: int):
	hand_size = size

func add_card():
	var new_card_sprite: Sprite2D = Sprite2D.new()
	new_card_sprite.set_texture(card_back)
	self.add_child(new_card_sprite)
	cards.append(new_card_sprite)
	reposition_cards()
	
func remove_card():
	remove_child(cards.pop_back())
	if len(cards) > 0:
		reposition_cards()
	
func reposition_cards():
	var x_position = max(-1*max_width/2, -1*(len(cards)-1)*max_card_spread/2)
	var y_position: float = 0.0
	var card_spread = min(max_card_spread, max_width/len(cards))
	var current_angle = cards.size()/-2
	for i in cards.size():
		var card = cards[i]
		card.set_position(Vector2(x_position, y_position))
		card.set_rotation(deg_to_rad(current_angle))
		current_angle += 1
		x_position += card_spread
		if i < cards.size()/2:
			y_position -= 2
		else:
			y_position += 2

func _process(delta: float) -> void:
	while hand_size > len(cards):
		add_card()
	while hand_size < len(cards):
		remove_card()
