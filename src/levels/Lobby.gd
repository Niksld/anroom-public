extends Node3D

var resolution := Vector2(1920,1080)
var mouse_direction := "normal"
var mouse_sensitivity := ""
var countdown := 5400 # seconds - 1h 30min
var fullscreen := false
var claimed_stickers := []
var unlocked_locations := []
var sticker_displayed = false
var sticker_animation_playing = false
var game_loaded = false
@onready var p_default_sens = get_tree().get_first_node_in_group("player").mouse_sensitivity

# Map part variables
var mptn_stairs_crossed = []
var spiral_triggers_crossed = []
var spiral_direction = null

var ignored_buttons_when_selected = ["change_res", "change_mouse_normal","change_mouse_inverted",
"change_fullscreen", "change_windowed", "change_resolution_scale", "change_mouse_sensitivity"]

@onready var map_parts = {
	"None": self.map_part_none,
	"none": self.map_part_none,
	"LoF_Walk?" : self.walk_jump,
	"mptn_sticker1" : get_tree().get_first_node_in_group("mptn_sticker1").toggle_visibility,
	"mptn_sticker2" : get_tree().get_first_node_in_group("mptn_sticker2").toggle_visibility,
	"mptn_switch_teleport" : get_tree().get_first_node_in_group("mptn_new_teleport").enable, # not doing anything
	"mptn_disable_old_teleport" : get_tree().get_first_node_in_group("mptn_stairs_teleport").disable
}

var teleport_locations = {
	"LeapOfFaith":{
		"destination": Vector3(0, 2.92, 114.58),
		"rotation": {"x": -0.002, "y": 3.1412}
		},
	"aJumpTooFar":{
		"destination": Vector3(0.407, -84.5815, 146.4523),
		"rotation": {"x": -0.065, "y": 0.01839}
		},
	"IntoDarkness":{
		"destination": Vector3(0.166, -171.5815, 136.666),
		"rotation": {"x": -0.0068, "y": 3.1396}
		},
	"ManyPathsToNowhere":{
		"destination": Vector3(-29.0748, -135.6444, 143.761),
		"rotation": {"x": -0.0168, "y": 3.1278}
	},
	"threePathsInSight":{
		"destination": Vector3(-0.6583, -79.582, 81.253),
		"rotation": {"x": -0.014, "y": -0.0145}
	},
	"findingTheSeams":{
		"destination": Vector3(-0.3765, -69.5195, -61.3875),
		"rotation": {"x": 0.0046, "y": 0.002}
	},
	"stuckInARut":{
		"destination": Vector3(44.5854, -69.5815, -124.8488),
		"rotation": {"x": 0.0086, "y": -0.0037}
	}
}

var sticker_billboard_ids

func map_part_none():
	print("Map part None called, skipping...")

func walk_jump():
	get_tree().get_first_node_in_group("LoF_Text").change_to_walk()
	get_tree().get_first_node_in_group("map").room_previews["Leap Of Faith"] = "res://src/resources/previews/lof1.png"
	get_tree().get_first_node_in_group("map").room_previews["LeapOfFaith"] = "res://src/resources/previews/lof1.png"

func many_paths_to_nowhere(stairs):
	if stairs not in self.mptn_stairs_crossed:
		self.mptn_stairs_crossed.append(stairs)
	else:
		return

	match len(self.mptn_stairs_crossed):
		1:
			if !get_tree().get_first_node_in_group("mptn_sticker1").is_visible:
				map_parts["mptn_sticker1"].call()
		2:
			if !get_tree().get_first_node_in_group("mptn_sticker2").is_visible:
				map_parts["mptn_sticker2"].call()
			map_parts["mptn_switch_teleport"].call()
			map_parts["mptn_disable_old_teleport"].call()
			unlocked_locations.append("mptn_new_path")

func spiral_finish():
	if len(spiral_triggers_crossed) == 2:
		$"Maze/TočkyKolotočky/Druha/ProtiSměru/ProtiDruhaTeleport".disabled = true
		$"Maze/TočkyKolotočky/Left/PendulumExit".visible = true
		$"Maze/TočkyKolotočky/Left/PendulumExit/PenTele".disabled = false
		if spiral_direction == "left":
			$"Maze/TočkyKolotočky/Druha/ProtiSměruExit/ProtiDruhaExitTeleport".disabled = false
		if spiral_direction == "right":
			$"Maze/TočkyKolotočky/Druha/ProtiSměruExitRight/ProtiDruhaExitTeleport".disabled = false
func _ready() -> void:
	load_settings()
	load_progress()

	await get_tree().create_timer(0.5).timeout
	game_loaded = true
	sticker_billboard_ids = {
	1: $Interactables/Lobby_room/StickerBillboard/Stickers/LobbySticker,
	2: $Interactables/Lobby_room/StickerBillboard/Stickers/aGameOfLeapFrog,
	3: $Interactables/Lobby_room/StickerBillboard/Stickers/LeapOfFaith,
	4: $Interactables/Lobby_room/StickerBillboard/Stickers/NowYouSeeIt,
	5: $Interactables/Lobby_room/StickerBillboard/Stickers/ManyPathsToNowhere,
	6: $Interactables/Lobby_room/StickerBillboard/Stickers/MainHub,
	7: $Interactables/Lobby_room/StickerBillboard/Stickers/IntoDarkness,
	8: $Interactables/Lobby_room/StickerBillboard/Stickers/IntoDarkness2,
	9: $Interactables/Lobby_room/StickerBillboard/Stickers/DownTheRabbitHole,
	10: $Interactables/Lobby_room/StickerBillboard/Stickers/ManyPathsToNowhere2,
	11: $Interactables/Lobby_room/StickerBillboard/Stickers/ManyPathsToNowhere3,
	12: $Interactables/Lobby_room/StickerBillboard/Stickers/ReturnToMainHub,
	13: $Interactables/Lobby_room/StickerBillboard/Stickers/ManyPathsToNowhere4,
	}
	$Node3D2/AnimationPlayer.play("točky")
	$Node3D/AnimationPlayer.play("kolotočky")

func save_settings():
	var save_settings = FileAccess.open("user://settings.cfg", FileAccess.WRITE_READ)
	var save_nodes = get_tree().get_nodes_in_group("config_persist")

	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("SaveSettings: persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("SaveSettings: persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		if node.selected:
			save_settings.store_line(json_string)

func load_settings():
	if not FileAccess.file_exists("user://settings.cfg"):
		print("LoadSettings: Settings not found, skipping...")
		return # Error! We don't have a save to load.
	#Unselect all buttons:
	var save_nodes = get_tree().get_nodes_in_group("config_persist")
	for node in save_nodes:
		if node.selected:
			node.toggle_selection()
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_game = FileAccess.open("user://settings.cfg", FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("LoadSettings: JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var node_data = json.get_data()

		var object = get_node_or_null(node_data["path"])
		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "path" or i == "name":
				continue
			match i:
				"selected":
					object.toggle_selection()
					self.run_function({"collider": object}, true, true)
				_:
					print("LoadSettings: Parameter ",i, " unrecognized. Skipping...")

func save_progress():
	var save_game = FileAccess.open("user://progress.save", FileAccess.WRITE_READ)
	var save_nodes = get_tree().get_nodes_in_group("persist")

	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("SaveProgress: persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("SaveProgress: persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_game.store_line(json_string)
	var temp_locations = '"'
	for location in unlocked_locations:
		temp_locations += location + ","
	temp_locations[-1] = '"'
	save_game.store_line('{"path":"","locations" :'+ temp_locations + '}')

func load_progress():
	if not FileAccess.file_exists("user://progress.save"):
		print("LoadProgress: Save Game not found, skipping...")
		get_tree().get_first_node_in_group("beginning_sticker").show_sticker()
		sticker_displayed = true
		return # Error! We don't have a save to load.

	#Unselect all buttons:
	var save_nodes = get_tree().get_nodes_in_group("persist")
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_game = FileAccess.open("user://progress.save", FileAccess.READ)
	var reading_locations = false
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("LoadProgress: JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var node_data = json.get_data()
		var object = get_node_or_null(node_data["path"])
		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "path":
				continue
			if i == "name":
				match node_data[i]:
					"sticker":
						if node_data["selected"]:
							object.toggle_selected()
						if node_data["claimed"]:
							claimed_stickers.append(object)
						if node_data["is_visible"] and !object.is_visible:
							object.toggle_visibility()
					"ring":
						if !node_data["is_visible"]:
							object.toggle_visibility()
					"LoF_Text":
						if !node_data["jump_visible"]:
							object.change_to_walk()
							get_tree().get_first_node_in_group("map").room_previews["Leap Of Faith"] = "res://src/resources/previews/lof1.png"
							get_tree().get_first_node_in_group("map").room_previews["LeapOfFaith"] = "res://src/resources/previews/lof1.png"
					"timer":
						object.set_time(node_data["time_remaining"])
					"MapBillboard":
						object.change_tutorial_state(int(node_data["tutorial_text_state"]))
					"sticker_view":
						if node_data["visible"]:
							object.set2visible()
					_:
						print("LoadProgress: Parameter ",i, " unrecognized. Skipping...")
			if i == "locations":
				# unlock each part
				for location in node_data["locations"].split(','):
					if location != "LeapOfFaith":
						add_room_to_map(location)
					match location:
						"mptn_new_path":
							map_parts["mptn_switch_teleport"].call()
							map_parts["mptn_disable_old_teleport"].call()
						_:
							print("LoadProgress.Locations: Undefined action for map part :", location)

func unlock_map_part(part):
	map_parts[part].call()

func teleport_player(location: String):
	$"Maze/TočkyKolotočky/Left/PendulumExit".visible = false
	$"Maze/TočkyKolotočky/Left/PendulumExit/PenTele".disabled = true
	# fade animation
	var crosshair_states = [$Player/Pivot/Camera/Crosshair.visible, $Player/Pivot/Camera/Crosshair_green.visible]
	$Player/Pivot/Camera/Crosshair.visible = false
	$Player/Pivot/Camera/Crosshair_green.visible = false
	await get_tree().create_timer(0.005).timeout
	$Player/Pivot/Camera/TransitionPlayer/TextureRect.texture = ImageTexture.create_from_image(get_viewport().get_texture().get_image())
	$Player/Pivot/Camera/Crosshair.visible = crosshair_states[0]
	$Player/Pivot/Camera/Crosshair_green.visible = crosshair_states[1]
	$Player/Pivot/Camera/TransitionPlayer.play("Fade")

	$Player.position = teleport_locations[location]["destination"]
	$Player/Pivot/Camera.rotation.x = teleport_locations[location]["rotation"]["x"]
	$Player/Pivot.rotation.y = teleport_locations[location]["rotation"]["y"]
	$Player.current_location = location

	if $Interactables/LeapOfFaith/LoF_Text.jump_visible and $Interactables/Lobby_room/MapBillboard.tutorial_text_state == 1:
		$Interactables/LeapOfFaith/LoF_Text.change_to_walk()
		get_tree().get_first_node_in_group("map").room_previews["Leap Of Faith"] = "res://src/resources/previews/lof1.png"
		get_tree().get_first_node_in_group("map").room_previews["LeapOfFaith"] = "res://src/resources/previews/lof1.png"

	if location == "LeapOfFaith":
		if $Interactables/Lobby_room/MapBillboard.tutorial_text_state < 2:
			$Interactables/Lobby_room/MapBillboard.change_tutorial_state($Interactables/Lobby_room/MapBillboard.tutorial_text_state + 1)


func run_function_by_name(name):
	match name:
		"kill_pendulum_teleport":
			$"Maze/TočkyKolotočky/Left/PendulumExit".visible = false
			$"Maze/TočkyKolotočky/Left/PendulumExit/PenTele".disabled = true
		"red_stairs_crossed":
			many_paths_to_nowhere(name)
		"blue_stairs_crossed":
			many_paths_to_nowhere(name)
		"spiral_trigger_passed_left":
			if "left" not in spiral_triggers_crossed:
				spiral_triggers_crossed.append("left")
			spiral_finish()
		"spiral_trigger_passed_right":
			if "right" not in spiral_triggers_crossed:
				spiral_triggers_crossed.append("right")
			spiral_finish()
		"spiral_trigger_reset":
			spiral_triggers_crossed = []
			spiral_direction = null
			$Trigger.reset()
			$Trigger2.reset()
			$Trigger3.reset()
			$"Maze/TočkyKolotočky/Left/PendulumExit".visible = false
			$"Maze/TočkyKolotočky/Left/PendulumExit/PenTele".disabled = true
			$"Maze/TočkyKolotočky/Druha/ProtiSměruExit/ProtiDruhaExitTeleport".disabled = true
			$"Maze/TočkyKolotočky/Druha/ProtiSměru/ProtiDruhaTeleport".disabled = false
			$"Maze/TočkyKolotočky/Druha/ProtiSměruExitRight/ProtiDruhaExitTeleport".disabled = true
		"spiral_trigger_check":
			if len(spiral_triggers_crossed) == 2:
				spiral_triggers_crossed = []
				$"Maze/TočkyKolotočky/Druha/ProtiSměruExit/ProtiDruhaExitTeleport".disabled = true
				$"Maze/TočkyKolotočky/Druha/ProtiSměru/ProtiDruhaTeleport".disabled = false
				$"Maze/TočkyKolotočky/Druha/ProtiSměruExitRight/ProtiDruhaExitTeleport".disabled = true
				spiral_direction = null
				$"Maze/TočkyKolotočky/Left/PendulumExit".visible = false
				$"Maze/TočkyKolotočky/Left/PendulumExit/PenTele".disabled = true
				$Trigger.reset()
				$Trigger2.reset()
				$Trigger3.reset()
			# if we swiched teleporters, switch them back.
		"set_direction_left":
			if spiral_direction == null:
				spiral_direction = "left"
		"set_direction_right":
			if spiral_direction == null:
				spiral_direction = "right"
		"change_mouse_sensitivity":
			pass
		"None":
			pass
		_:
			print("RunFunctionByName: Function ", name, " unrecognized.")

func add_to_sticker_billboard(id):
	if game_loaded:
		sticker_billboard_ids[id].set2visible()

func add_room_to_map(location):
	print("AddRoomToMap: "+location)
	var position = Vector3(0,0,0)
	var new_node
	match location:
		"Lobby":
			return
		"LeapOfFaith":
			pass
		"fallLoF":
			pass

		"aJumpTooFar":
			position = Vector3(0,.5,0)
			var corridor1 = load("res://src/resources/objects/MapObjects/RoomCorridor.tscn").instantiate()
			corridor1.position = Vector3(0.005,1.1,0)
			corridor1.scale.x = 1.5
			$Interactables/Lobby_room/MapBillboard.add_child(corridor1)
			#new_node = load("res://src/resources/objects/MapObjects/RoomNodeSmall.tscn").instantiate()
		"IntoDarkness":
			position = Vector3(0,-.7,0)
			var corridor1 = load("res://src/resources/objects/MapObjects/RoomCorridor.tscn").instantiate()
			corridor1.position = Vector3(0.005,-.1,0)
			corridor1.scale.x = 1.5
			$Interactables/Lobby_room/MapBillboard.add_child(corridor1)
		"ManyPathsToNowhere":
			position = Vector3(0,-1.9,0)
			var corridor1 = load("res://src/resources/objects/MapObjects/RoomCorridor.tscn").instantiate()
			corridor1.position = Vector3(0.005,-1.3,0)
			corridor1.scale.x = 1.5
			$Interactables/Lobby_room/MapBillboard.add_child(corridor1)
		"threePathsInSight":
			position = Vector3(0,0.5,1.15)
			var corridor1 = load("res://src/resources/objects/MapObjects/RoomCorridor.tscn").instantiate()
			corridor1.position = Vector3(0.005,0.5,0.6)
			corridor1.rotation_degrees.x = 90
			corridor1.scale.x = 1.5
			$Interactables/Lobby_room/MapBillboard.add_child(corridor1)
			new_node = load("res://src/resources/objects/MapObjects/RoomNodeSmall.tscn").instantiate()
		"findingTheSeams":
			position = Vector3(0,0.5,2.25)
			var corridor1 = load("res://src/resources/objects/MapObjects/RoomCorridor.tscn").instantiate()
			corridor1.position = Vector3(0.005,0.5,1.7)
			corridor1.rotation_degrees.x = 90
			corridor1.scale.x = 1.5
			$Interactables/Lobby_room/MapBillboard.add_child(corridor1)
			new_node = load("res://src/resources/objects/MapObjects/RoomNodeSmall.tscn").instantiate()
		"stuckInARut":
			position = Vector3(0,0.5,3.35)
			var corridor1 = load("res://src/resources/objects/MapObjects/RoomCorridor.tscn").instantiate()
			corridor1.position = Vector3(0.005,0.5,2.8)
			corridor1.rotation_degrees.x = 90
			corridor1.scale.x = 1.5
			$Interactables/Lobby_room/MapBillboard.add_child(corridor1)
			new_node = load("res://src/resources/objects/MapObjects/RoomNodeSmall.tscn").instantiate()
		_:
			print("AddRoomToMap: Undefined map room node for ", location, ", skipping...")
			return
	if new_node == null:
		new_node = load("res://src/resources/objects/MapObjects/RoomNode.tscn").instantiate()
	$Interactables/Lobby_room/MapBillboard.add_child(new_node)
	new_node.position = position
	print(new_node)
	new_node.room = location

	if location not in unlocked_locations:
		unlocked_locations.append(location)

func run_function(node_reference, force=false, no_save=false):
	var node = node_reference["collider"]

	if not force:
		if node.function in ignored_buttons_when_selected and node.selected:
			print("RunFunction: Current node ",node ," is already selected - ignore.")
			return

		if node.function in ignored_buttons_when_selected and node.paired_count > 0:
			node.check_paired()
	match node.function:
		"teleport_player":
			self.teleport_player(node.text)
		"room_node":
			if !$Interactables/Lobby_room/MapBillboard.preview_visible:
				$Interactables/Lobby_room/MapBillboard/RoomPreview/RoomPreview.position.z = node.position.z
				$Interactables/Lobby_room/MapBillboard/RoomPreview/RoomPreview.position.y = node.position.y - 2
				$Interactables/Lobby_room/MapBillboard.show_preview(node.room)
		"sticker":
			node.toggle_selected()
			if not node.claimed:
				# update sticker collection board()
				claimed_stickers[node.text] = node
		"sticker_view":
			if !sticker_animation_playing and !sticker_displayed:
				node.show_sticker()
				sticker_displayed = true
		"sticker_hide":
			if !sticker_animation_playing and sticker_displayed:
				node.hide_sticker()
				sticker_displayed = false
		"change_res": # unused
			print("Change res to: ", node.text)
			resolution = node.text.split("x")
			get_window().size = Vector2i(int(resolution[0]),int(resolution[1]))
			get_window().position = Vector2(int(resolution[0])/2,int(resolution[1])/2)
			#ProjectSettings.set_setting("display/window/size/viewport_width", resolution[0])
			#ProjectSettings.set_setting("display/window/size/viewport_height", resolution[1])
			#get_viewport().set_content_scale(Vector2i(int(resolution[0]),int(resolution[1])))

				#DisplayServer.window_set_mode()
				#get_tree().set_screen_stretch(DisplayServer.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, Vector2i(int(resolution[0]),int(resolution[1])))
		"change_mouse_sensitivity":
			var new_sens = 0
			match node.name:
				"ButtonDefault":
					new_sens = 1
				"ButtonHigh":
					new_sens = p_default_sens * 1.5
				"ButtonLow":
					new_sens = p_default_sens * 0.5

			get_tree().get_first_node_in_group("player").mouse_sensitivity = new_sens
		"change_mouse_normal":
				get_tree().get_first_node_in_group("player").inverted_mouse = false
		"change_mouse_inverted":
				get_tree().get_first_node_in_group("player").inverted_mouse = true
		"change_resolution_scale":
				get_viewport().scaling_3d_scale = float(node.text)
		"change_fullscreen":
			if not fullscreen:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
				fullscreen = true
			else:
				print("RunFunction: Game is already fullscreen, skipping...")
		"change_windowed":
			if fullscreen:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				fullscreen = false
			else:
				print("RunFunction: Game is already windowed, skipping...")
		"delete_save":
			if FileAccess.file_exists("user://progress.save"):
				DirAccess.remove_absolute("user://progress.save")
				print("Save game deleted!")
				get_tree().reload_current_scene()
				return
			else:
				get_tree().reload_current_scene()
				return
		"abort_delete_save":
			get_tree().get_first_node_in_group("delete_save_dialog").change_visibility()
			get_tree().get_first_node_in_group("delete_save_button").change_visibility()
		"delete_save_button":
			node.change_visibility()
			get_tree().get_first_node_in_group("delete_save_dialog").change_visibility()
		_:
			print("RunFunction: Function for ", node, " is undefined or unrecognized.")
	if not no_save:
		self.save_settings()
