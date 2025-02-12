extends Control

class_name TitleScreen

@onready var hand: Hand = $Hand
#var card_scene = load("res://scenes/card/card.tscn")
@export var card_scene: PackedScene

func _ready() -> void:
	create_card("AS")
	create_card("AH")
	create_card("AC")
	create_card("AD")
	
func create_card(card_string: String):
	var new_card: Card = card_scene.instantiate()
	hand.add_card(new_card)
	new_card.set_values_from_string(card_string)
	new_card.visible = true
