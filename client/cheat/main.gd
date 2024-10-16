extends Node

@export var card_scene: PackedScene
@onready var client: WebSocketClient = $WebSocketClient
@onready var hand = $Hand
@onready var startGameBtn = $LobbyUI/StartGame
@onready var newGameBtn = $LobbyUI/NewGame
@onready var joinGameBtn = $LobbyUI/JoinGame

var connected = false
var uuid = ""
var join_key = ""
var your_turn = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startGameBtn.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func str_to_card(card_string: String) -> void:
	var new_card: Card = card_scene.instantiate()
	hand.add_child(new_card)
	new_card.set_values_from_string(card_string)
	new_card.visible = true


func _on_remove_card_pressed() -> void:
	for card: Card in hand.get_children():
		if card.selected:
			hand.remove_child(card)


func _on_new_game_pressed() -> void:
	client.connect_to_server()

	connected = true
	newGameBtn.visible = false
	joinGameBtn.visible = false

	# Send data.
	var data = {"type": "init"}
	var send_data = await client.send(data)
	print(send_data)
	startGameBtn.visible = true



func _on_join_game_text_submitted(new_text: String) -> void:
	client.connect_to_server()

	connected = true
	newGameBtn.visible = false
	joinGameBtn.visible = false

	# Send data.
	var data = {"type": "init", "join": new_text}
	client.send(data)


func _on_start_game_pressed() -> void:
	var data = {"type": "start"}
	client.send(data)


func _on_web_socket_client_message_received(json_recv: Variant) -> void:
	print(json_recv)
	match json_recv["type"]:
		"init":
			uuid = json_recv["uuid"]
			join_key = json_recv["join"]
			print(uuid)
		"start":
			var data = {"type": "start"}
			client.send(data)
		"hand":
			for card_str in json_recv["hand"]:
				str_to_card(card_str)
		"turn":
			assert(json_recv["player"] == uuid)
			your_turn = true
