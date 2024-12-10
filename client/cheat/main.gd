extends Node

@export var card_scene: PackedScene
@onready var client: WebSocketClient = $WebSocketClient
@onready var hand = $PlayUI/Hand
@onready var startGameBtn = $LobbyUI/StartGame
@onready var newGameBtn = $LandingPage/NewGame
@onready var joinGameBtn = $LandingPage/JoinGame
@onready var joinCodeLbl = $LobbyUI/JoinCode
@onready var playerList = $LobbyUI/PlayerList
@onready var rankOption = $PlayUI/RankOption
@onready var yourTurnLbl = $PlayUI/YourTurn
@onready var roundRankLbl = $PlayUI/RoundRank
@onready var activePileLbl = $PlayUI/ActivePileLbl
@onready var activePile = $PlayUI/ActivePile
@onready var discardPileLbl = $PlayUI/DiscardPileLbl
@onready var outPileLbl = $PlayUI/OutPileLbl
@onready var gameOverLbl = $PlayUI/GameOverLbl
@onready var uuidLbl = $PlayUI/UUIDLbl
@onready var playerUI = $PlayerUI

var connected = false
var uuid = ""
var join_key = ""
var your_turn = false
var round_rank: Card.Rank
var round_start = true
var player_uuids = []
var players = {}
var active_pile_len = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gameOverLbl.visible = false
	$PlayUI.visible = false
	$LobbyUI.visible = false
	$PlayerUI.visible = false
	$LandingPage.visible = true
	rankOption.visible = false
	yourTurnLbl.visible = your_turn
	for rank in Card.Rank.keys():
		rankOption.add_item(rank)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if your_turn != yourTurnLbl.visible:
		yourTurnLbl.visible = your_turn


func _on_new_game_pressed() -> void:
	$LandingPage.visible = false
	client.connect_to_server()

	connected = true

	# Send data.
	var data = {"type": "init"}
	$LobbyUI.visible = true
	var send_data = await client.send(data)
	print(send_data)


func _on_join_game_text_submitted(new_text: String) -> void:
	$LandingPage.visible = false
	client.connect_to_server()

	connected = true

	# Send data.
	var data = {"type": "init", "join": new_text}
	client.send(data)
	startGameBtn.disabled = true
	$LobbyUI.visible = true


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
			var playerNodes: Array = $PlayerUI.get_children()
			var my_index = player_uuids.find(uuid)

			# Rearrange player list around current player
			for i in player_uuids.size():
				var new_index
				if i >= my_index:
					new_index = i-my_index
				else:
					new_index = i+(player_uuids.size()-my_index)
				playerNodes[new_index].set_player_name(player_uuids[i])
				players[player_uuids[i]] = playerNodes[new_index]
			print(players)
			$LobbyUI.visible = false
			$PlayUI.visible = true
			$PlayerUI.visible = true
			round_start = true
			gameOverLbl.visible = false
		"players":
			player_uuids = json_recv["players"]
			for i in range(player_uuids.size()):
				playerList.set_item_text(i, player_uuids[i])
			playerList.visible = true
		"setup":
			var hand_length: int = len(json_recv["hand"])
			for uuid in player_uuids:
				players[uuid].set_hand_size(hand_length)
			update_hand(json_recv["hand"])
			discardPileLbl.set_text("Discard Pile: " + str(json_recv["discard_pile"]))
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
			# Calculate new player hand sizes from the change in active pile size
			var num_played_cards = json_recv["active_pile"] - active_pile_len
			active_pile_len = json_recv["active_pile"]
			activePile.set_size(active_pile_len)
			if json_recv.has("prev_player"):
				players[json_recv["prev_player"]].add_cards(num_played_cards * -1)

			if json_recv["player"] == uuid:
				your_turn = true
				if round_start:
					rankOption.visible = true
			else:
				your_turn = false
			if json_recv.has("out_pile"):
				outPileLbl.set_text("Out Pile: " + str(json_recv["out_pile"]))
		"end":
			gameOverLbl.set_text("Game Over!\nWinner is " + json_recv["winner"])
			#print("Winner is " + json_recv["winner"])
			gameOverLbl.visible = true


func update_hand(new_hand: Array) -> void:
	var current_hand = hand.get_children().map(func(card): return card.card_str)
	for card_str in new_hand:
		if not current_hand.has(card_str):
			add_card_to_hand(card_str)


func add_card_to_hand(card_string: String) -> void:
	var new_card: Card = card_scene.instantiate()
	hand.add_child(new_card)
	new_card.set_values_from_string(card_string)
	new_card.visible = true


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
	rankOption.visible = false


func _on_call_cheat_pressed() -> void:
	if not your_turn:
		return
	var data = {
		"type": "call_cheat"
	}
	client.send(data)


func _on_pass_pressed() -> void:
	if not your_turn:
		return
	var data = {
		"type": "pass"
	}
	client.send(data)
