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
@onready var yourTurnLbl = $PlayUI/YourTurn
@onready var roundRankLbl = $PlayUI/RoundRank
@onready var activePileLbl = $PlayUI/ActivePileLbl
@onready var gameOverLbl = $PlayUI/GameOverLbl
@onready var uuidLbl = $PlayUI/UUIDLbl

var connected = false
var uuid = ""
var join_key = ""
var your_turn = false
var round_rank: Card.Rank
var round_start = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gameOverLbl.visible = false
	startGameBtn.visible = false
	playerList.visible = false
	$PlayUI.visible = false
	rankOption.visible = false
	yourTurnLbl.visible = your_turn
	for rank in Card.Rank.keys():
		rankOption.add_item(rank)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if your_turn != yourTurnLbl.visible:
		yourTurnLbl.visible = your_turn


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


func _on_web_socket_client_message_received(json_recv: Dictionary) -> void:
	print(json_recv)
	match json_recv["type"]:
		"init":
			uuid = json_recv["uuid"]
			uuidLbl.set_text(uuid)
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
			update_hand(json_recv["hand"])
		"turn":
			print(json_recv["player"] + "'s turn")

			if json_recv.get("round_start"):
				round_start = true
				roundRankLbl.set_text("Round Rank: ")
			else:
				round_start = false
				if json_recv.has("round_rank"):
					round_rank = Card.char_to_rank(json_recv["round_rank"])
					roundRankLbl.set_text("Round Rank: " + Card.Rank.keys()[round_rank])

			activePileLbl.set_text("Active Pile: " + str(json_recv["active_pile"]))

			if json_recv["player"] == uuid:
				your_turn = true
				if round_start:
					rankOption.visible = true
		"end":
			gameOverLbl.set_text("Game Over!\nWinner is " + json_recv["winner"])
			#print("Winner is " + json_recv["winner"])
			gameOverLbl.visible = true


func update_hand(new_hand: Array) -> void:
	for card_str in new_hand:
		str_to_card(card_str)


func _on_play_cards_pressed() -> void:
	if not your_turn:
		return
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
	your_turn = false
	rankOption.visible = false


func _on_call_cheat_pressed() -> void:
	if not your_turn:
		return
	var data = {
		"type": "call_cheat"
	}
	client.send(data)
	round_start = false


func _on_pass_pressed() -> void:
	if not your_turn:
		return
	var data = {
		"type": "pass"
	}
	client.send(data)
	round_start = false
	your_turn = false
