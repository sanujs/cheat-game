extends Node

@export var websocket_url = "ws://localhost:8001/"
@export var card_scene: PackedScene
@onready var hand = $Hand

var socket = WebSocketPeer.new()
var connected = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	socket.poll()
	if connected:
		var state = socket.get_ready_state()
		if state == WebSocketPeer.STATE_OPEN:
			while socket.get_available_packet_count():
				var pkt := socket.get_packet()
				if socket.was_string_packet():
					var pkt_string = pkt.get_string_from_utf8()
					var json_recv = JSON.parse_string(pkt_string)
					print(json_recv['join'])
		elif state == WebSocketPeer.STATE_CLOSING:
			# Keep polling to achieve proper close.
			pass
		elif state == WebSocketPeer.STATE_CLOSED:
			var code = socket.get_close_code()
			var reason = socket.get_close_reason()
			print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
			#set_process(false) # Stop processing.
		else:
			print(state)


func _on_add_card_pressed() -> void:
	var new_card: Card = card_scene.instantiate()
	hand.add_child(new_card)
	new_card.set_values(Card.Rank.THREE, Card.Suit.HEARTS)
	new_card.visible = true


func _on_remove_card_pressed() -> void:
	for card: Card in hand.get_children():
		if card.selected:
			hand.remove_child(card)


func _on_line_edit_text_submitted(new_text: String) -> void:
	var new_card: Card = card_scene.instantiate()
	hand.add_child(new_card)
	new_card.set_values_from_string(new_text)
	new_card.visible = true


func _on_new_game_pressed() -> void:
	var err = socket.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)
	else:
		# Wait for the socket to connect.
		await get_tree().create_timer(1).timeout
		
		# Send data.
		var data = {"type": "init"}
		socket.send_text(JSON.stringify(data))
		connected = true


func _on_join_game_text_submitted(new_text: String) -> void:
	var err = socket.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)
	else:
		# Wait for the socket to connect.
		await get_tree().create_timer(1).timeout

		connected = true
		# Send data.
		var data = {"type": "init", "join": new_text}
		socket.send_text(JSON.stringify(data))
