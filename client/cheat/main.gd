extends Node

@export var card_scene: PackedScene
@onready var hand = $Hand

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_add_card_pressed() -> void:
	var new_card: Card = card_scene.instantiate()
	hand.add_child(new_card)
	new_card.set_values(Card.Rank.THREE, Card.Suit.HEARTS)
	new_card.visible = true


func _on_remove_card_pressed() -> void:
	for card: Card in hand.get_children():
		if card.selected:
			hand.remove_child(card)


func _on_line_edit_text_submitted(new_text: String) -> void:
	var new_card: Card = card_scene.instantiate()
	hand.add_child(new_card)
	new_card.set_values_from_string(new_text)
	new_card.visible = true
