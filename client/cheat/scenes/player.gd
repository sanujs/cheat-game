class_name Player
extends Node2D

@export var turn: bool = false
@export var hand_size: int = 0

@onready var nameLbl = $NameLabel
@onready var handSizeLbl = $HandSizeLabel


func set_player_name(name: String) -> void:
	nameLbl.set_text(name)

func set_hand_size(size: int) -> void:
	hand_size = size
	handSizeLbl.set_text(str(size))

func add_cards(num: int) -> void:
	hand_size += num
	handSizeLbl.set_text(str(hand_size))
