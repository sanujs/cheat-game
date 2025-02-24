extends Control

class_name GameOver

@onready var outcome_lbl: Label = $Panel/OutcomeLbl

func set_outcome(winner: bool):
	if winner:
		outcome_lbl.set_text("Wow you won!")
	else:
		outcome_lbl.set_text("Oh boy you stink!")


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/lobby_screen.tscn")


func _on_play_again_pressed() -> void:
	pass # Replace with function body.
