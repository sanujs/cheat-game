class_name WebSocketClient
extends Node

@export var websocket_url = "wss://cheat-server.sudokusos.com"
#@export var websocket_url = "wss://localhost:8001/"

var socket = WebSocketPeer.new()
var connected = false
signal message_received(message: Variant)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var pkt := socket.get_packet()
			if socket.was_string_packet():
				var pkt_string = pkt.get_string_from_utf8()
				var json_recv: Variant = JSON.parse_string(pkt_string)
				message_received.emit(json_recv)
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		pass
		#var code = socket.get_close_code()
		#var reason = socket.get_close_reason()
		#print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		#set_process(false) # Stop processing.
	else:
		print(state)

func send(data: Variant) -> int:
	while socket.get_ready_state() == WebSocketPeer.STATE_CONNECTING:
		await get_tree().create_timer(2).timeout
	return socket.send_text(JSON.stringify(data))
	
func connect_to_server() -> void:
	var err = socket.connect_to_url(websocket_url)
	print(err)
	if err != OK:
		print("Unable to connect")
		set_process(false)
	else:
		connected = true
		# Wait for the socket to connect.
		await get_tree().create_timer(5).timeout
