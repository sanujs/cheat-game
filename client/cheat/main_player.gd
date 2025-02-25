extends Node2D

class_name MainPlayer

@onready var nameLabel: Label = $NameLabel
@onready var avatar: Sprite2D = $Avatar
@onready var editNodes = $Edit
@onready var nameInput = $Edit/ChangeName

var editing: bool = false

func _ready() -> void:
	nameLabel.set_text(Globals.player_name)
	nameInput.set_placeholder(Globals.player_name)

func set_editing(new_state: bool):
	editing = new_state
	editNodes.visible = new_state
	nameLabel.visible = !new_state

func _on_change_name_text_submitted(new_text: String) -> void:
	Globals.player_name = new_text
	nameLabel.set_text(Globals.player_name)
	nameInput.set_placeholder(Globals.player_name)
	set_editing(false)
