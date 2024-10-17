extends Node

@export var card_scene: PackedScene
@onready var client: WebSocketClient = $WebSocketClient
@onready var hand = $PlayUI/Hand
@onready var startGameBtn = $LobbyUI/StartGame
@onready var newGameBtn = $LobbyUI/NewGame
@onready var joinGameBtn = $LobbyUI/JoinGame
@onready var joinCodeLbl = $LobbyUI/JoinCode
@onready var playerList = $LobbyUI/PlayerList
@onready var rankOption = $PlayUI/RankOption

var connected = false
var uuid = ""
var join_key = ""
var your_turn = false
var round_rank: Card.Rank
var round_start = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startGameBtn.visible = false
	playerList.visible = false
	$PlayUI.visible = false
	rankOption.visible = false
	for rank in Card.Rank.keys():
		rankOption.add_item(rank)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func str_to_card(card_string: String) -> void:
	var new_card: Card = card_scene.instantiate()
	hand.add_child(new_card)
	new_card.set_values_from_string(card_string)
	new_card.visible = true


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
	startGameBtn.visible = true
	startGameBtn.disabled = true


func _on_start_game_pressed() -> void:
	var data = {"type": "start"}
	client.send(data)
	startGameBtn.visible = false


func _on_web_socket_client_message_received(json_recv: Variant) -> void:
	print(json_recv)
	match json_recv["type"]:
		"init":
			uuid = json_recv["uuid"]
			join_key = json_recv["join"]
			joinCodeLbl.set_text("Join Code: " + join_key)
			print(uuid)
		"start":
			var data = {"type": "start"}
			client.send(data)
			$LobbyUI.visible = false
			$PlayUI.visible = true
			round_start = true
		"players":
			var player_uuids = json_recv["players"]
			for i in range(player_uuids.size()):
				playerList.set_item_text(i, player_uuids[i])
			playerList.visible = true
		"hand":
			for card_str in json_recv["hand"]:
				str_to_card(card_str)
		"turn":
			print(uuid + " turn")
			assert(json_recv["player"] == uuid)
			your_turn = true
			if round_start:
				rankOption.visible = true


func _on_play_cards_pressed() -> void:
	var played_cards = []
	for card: Card in hand.get_children():
		if card.selected:
			played_cards.append(card.card_str)
			hand.remove_child(card)
	if round_start:
		round_rank = Card.Rank[rankOption.get_item_text(rankOption.selected)]
	var data = {
		"type": "play",
		"cards": played_cards,
		"round_rank": Card.rank_to_char(round_rank),
	}
	client.send(data)
	round_start = false
	rankOption.visible = false
