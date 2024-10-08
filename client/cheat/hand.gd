extends HBoxContainer

@export var card_scene: PackedScene


func _on_button_pressed() -> void:
	var new_card = card_scene.instantiate()
	add_child(new_card)
