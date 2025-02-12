extends Control

@onready var join_input = $JoinInput


func submit() -> void:
	Globals.join_code = join_input.get_text().strip_edges()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

func _on_join_input_text_submitted(new_text: String) -> void:
	submit()

func _on_submit_join_pressed() -> void:
	submit()

func _on_paste_join_code_pressed() -> void:
	join_input.set_text(DisplayServer.clipboard_get().strip_edges())
