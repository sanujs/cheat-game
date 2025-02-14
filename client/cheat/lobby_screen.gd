extends Control

class_name LobbyScreen

@onready var joinCodeLbl = $JoinCode
@onready var playerList = $PlayerList

func _ready() -> void:
	# Connect to lobby
	var data = {}
	if Globals.join_code != "":
		data = {"type": "init", "join": Globals.join_code}
	else:
		data = {"type": "init"}
	print(data)
	WebSocket.connect_to_server()
	await get_tree().create_timer(5).timeout
	WebSocket.send(data)
	
	WebSocket.message_received.connect(_on_message_received)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

func _on_message_received(json_recv: Dictionary) -> void:
	print(json_recv)
	match json_recv["type"]:
		"init":
			Globals.uuid = json_recv["uuid"]
			Globals.join_code = json_recv["join"]
			joinCodeLbl.set_text("Join Code: " + Globals.join_code)
		"players":
			# Update player list when a new player joins
			Globals.player_uuids = json_recv["players"]
			for i in range(Globals.player_uuids.size()):
				playerList.set_item_text(i, Globals.player_uuids[i])
		"start":
			var data = {"type": "start"}
			WebSocket.send(data)
			print("Game has been started")


func _on_start_pressed() -> void:
	var data = {"type": "start"}
	WebSocket.send(data)


func _on_copy_join_code_pressed() -> void:
	DisplayServer.clipboard_set(Globals.join_code)
