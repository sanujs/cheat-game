extends Node

@export var card_scene: PackedScene
@onready var hand: Hand = $PlayUI/Hand
@onready var rankOption = $PlayUI/RankOption
@onready var yourTurnLbl = $PlayUI/YourTurn
@onready var roundRankLbl = $PlayUI/RoundRank
@onready var activePileLbl = $PlayUI/ActivePileLbl
@onready var activePile: Pile = $PlayUI/ActivePile
@onready var discardPileLbl = $PlayUI/DiscardPileLbl
@onready var outPileLbl = $PlayUI/OutPileLbl
@onready var gameOverLbl = $PlayUI/GameOverLbl
@onready var uuidLbl = $PlayUI/UUIDLbl
@onready var playerUI = $PlayerUI

var connected = false
var your_turn = false
var round_rank: Card.Rank
var round_start = true
var players = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gameOverLbl.visible = false
	rankOption.visible = false
	yourTurnLbl.visible = your_turn
	WebSocket.message_received.connect(_on_web_socket_client_message_received)
	for rank in Card.Rank.keys():
		rankOption.add_item(rank)

	var playerNodes: Array = $PlayerUI.get_children()
	var my_index = Globals.player_uuids.find(Globals.uuid)

	# Rearrange player list around current player
	for i in Globals.player_uuids.size():
		var new_index
		if i >= my_index:
			new_index = i-my_index
		else:
			new_index = i+(Globals.player_uuids.size()-my_index)
		playerNodes[new_index].set_player_name(Globals.player_uuids[i])
		players[Globals.player_uuids[i]] = playerNodes[new_index]
		playerNodes[new_index].visible = true
	print(players)
	round_start = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if your_turn != yourTurnLbl.visible:
		yourTurnLbl.visible = your_turn


func _on_web_socket_client_message_received(json_recv: Dictionary) -> void:
	print(json_recv)
	match json_recv["type"]:
		"setup":
			var hand_length: int = len(json_recv["hand"])
			for player_uuid in Globals.player_uuids:
				players[player_uuid].set_hand_size(hand_length)
			update_hand(json_recv["hand"])
			discardPileLbl.set_text("Discard Pile: " + str(json_recv["discard_pile"]))
		"hand":
			update_hand(json_recv["hand"])
		"turn":
			print(json_recv["player"] + "'s turn")

			# Identify who's turn it is
			for player_uuid: String in players:
				players[player_uuid].change_turn(json_recv["player"] == player_uuid)

			if json_recv.get("round_start"):
				round_start = true
				roundRankLbl.set_text("Round Rank: ")
			else:
				round_start = false
				if json_recv.has("round_rank"):
					round_rank = Card.char_to_rank(json_recv["round_rank"])
					roundRankLbl.set_text("Round Rank: " + Card.Rank.keys()[round_rank])

			var num_played_cards = 0
			if json_recv.has("active_pile"):
				activePileLbl.set_text("Active Pile: " + str(json_recv["active_pile"]))
				# Calculate new player hand sizes from the change in active pile size
				num_played_cards = json_recv["active_pile"] - activePile.get_size()
				activePile.set_size(json_recv["active_pile"])

			if json_recv.has("prev_player"):
				players[json_recv["prev_player"]].add_cards(num_played_cards * -1)

			if json_recv["player"] == Globals.uuid:
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
	var current_hand = hand.cards.map(func(card): return card.card_str)
	for card_str in new_hand:
		if not current_hand.has(card_str):
			add_card_to_hand(card_str)


func add_card_to_hand(card_string: String) -> void:
	var new_card: Card = card_scene.instantiate()
	hand.add_card(new_card)
	new_card.set_values_from_string(card_string)
	new_card.visible = true


func _on_play_cards_pressed() -> void:
	if not your_turn:
		return
	var played_cards = hand.play_selected_cards()
	if round_start:
		round_rank = Card.Rank[rankOption.get_item_text(rankOption.selected)]
	var data = {
		"type": "play",
		"cards": played_cards,
		"round_rank": Card.rank_to_char(round_rank),
	}
	WebSocket.send(data)
	round_start = false
	rankOption.visible = false


func _on_call_cheat_pressed() -> void:
	if not your_turn:
		return
	var data = {
		"type": "call_cheat"
	}
	WebSocket.send(data)


func _on_pass_pressed() -> void:
	if not your_turn:
		return
	var data = {
		"type": "pass"
	}
	WebSocket.send(data)
