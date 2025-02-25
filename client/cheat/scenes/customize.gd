extends Control
class_name Customize

@onready var mainPlayer: MainPlayer = $MainPlayer

func _ready() -> void:
	mainPlayer.set_editing(true)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
