extends Node2D
@export var card_scene: PackedScene = preload("res://scenes/card/card.tscn")
@onready var hand = $Hand

func _on_button_pressed() -> void:
	var new_card: Card = card_scene.instantiate()
	hand.add_card(new_card)
