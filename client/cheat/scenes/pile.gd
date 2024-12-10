class_name Pile

extends Node2D

@export var size: int
@onready var sprite: Sprite2D = $PileSprite
@onready var lbl: Label = $PileSprite/LblShadow/PileLbl

func set_size(_size: int) -> void:
	if _size == 0:
		sprite.visible = false
	elif _size == 1:
		sprite.visible = true
		sprite.set_texture(load("res://assets/card_back.png"))
	elif _size < 5:
		sprite.visible = true
		sprite.set_texture(load("res://assets/pile_small.png"))
	else:
		sprite.visible = true
		sprite.set_texture(load("res://assets/pile_med.png"))
	size = _size
	lbl.set_text(str(_size))
