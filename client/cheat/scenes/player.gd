class_name Player
extends Node2D

@export var turn: bool = false

@onready var nameLbl = $NameLabel
@onready var handSizeLbl = $HandSizeLabel

func set_player_name(name: String) -> void:
	nameLbl.set_text(name)

func set_hand_size(size: int) -> void:
	handSizeLbl.set_text(str(size))
