extends CharacterBody3D

@export_category("Player options")
@export var quit_delay := 5
@export var speed := 10.0
@export var jump_velocity := 4.5
@export var mouse_sensitivity := 1.0
@export var acceleration_damper := 1.5 # TODO: implement acceleration dampening
@export var deceleration_damper := 1.0
@export var inverted_mouse := false
@export_category("Debug")
@export var noclipping := false
@export var speed_boost := 25
var quit_timer := Timer.new()
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_mode := "captured"
var last_velocity : Vector3
var next_animation_left := true
@onready var pivot := $Pivot
@onready var camera := $Pivot/Camera
@onready var animation_player = $Pivot/Camera/AnimationPlayer
var crosshair_interacting := false
const RAY_LENGTH = 20
@onready var original_speed := speed
var current_location = null
var last_location = null
var tool_level = 0
var cubes_disabled = false
var tester = []

func _ready():
	quit_timer.set_wait_time(quit_delay)
	quit_timer.timeout.connect(self._on_timer_timeout)
	add_child(quit_timer)
	$Pivot/Camera/TransitionPlayer.play("RESET")

func _on_timer_timeout(): # If the user wishes to exit the game, save and then exit
	get_tree().get_first_node_in_group("globals").save_progress()
	get_tree().quit()

func _physics_process(delta) -> void:

	# raycast check for interactables
	var space_state = get_world_3d().direct_space_state # get current space_state
	var cam = $Pivot/Camera	#get player camera
	var mousepos = get_viewport().get_mouse_position() # get mouse pos

	var origin = cam.project_ray_origin(mousepos) # raycast origin set to current mouse pos
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH # calculate raycast end
	var query = PhysicsRayQueryParameters3D.create(origin, end, 1) # create the query
	query.collide_with_areas = true
	query.exclude = [self]
	var result = space_state.intersect_ray(query) # save result of query

	if result and result["collider"] is Area3D:
		# if an area3d was hit (which is the designated interactable type) ->
		# change crosshair to green to indicate that this is an interactable
		if not crosshair_interacting:
			$Pivot/Camera/Crosshair.visible = false
			$Pivot/Camera/Crosshair_green.visible = true
			crosshair_interacting = true


		# if the player clicks mouse1 he wants to pick this option, get the node and send it away to
		# the global script handler (Lobby.gd) for it to be executed.
		if Input.is_action_just_pressed("place"):
			#print(result["collider"].name + " just pressed!")
			$Effects.play()
			get_tree().get_first_node_in_group("globals").run_function(result)

		if result["collider"].function == "room_node":
			$Effects.play()
			get_tree().get_first_node_in_group("globals").run_function(result)
	else:
		# If we no longer see an interactable, set the crosshair back to white.
		if crosshair_interacting:
			$Pivot/Camera/Crosshair.visible = true
			$Pivot/Camera/Crosshair_green.visible = false
			crosshair_interacting = false

	# Add the gravity.
	if not is_on_floor() and not noclipping:
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("return_to_lobby") and current_location != "Lobby":
		print("Returning to lobby...")
		if !get_tree().get_first_node_in_group("return_sticker").is_visible:
			get_tree().get_first_node_in_group("return_sticker").set2visible()
			#get_tree().get_first_node_in_group("return_sticker").show_sticker()
		if get_tree().get_first_node_in_group("map").room_previews["Leap Of Faith"] != "res://src/resources/previews/lof1.png":
			get_tree().get_first_node_in_group("map").room_previews["Leap Of Faith"] = "res://src/resources/previews/lof1.png"
			get_tree().get_first_node_in_group("map").room_previews["LeapOfFaith"] = "res://src/resources/previews/lof1.png"
		# Save current crosshair, so we can disable them temporarily for the transition.
		var crosshair_states = [$Pivot/Camera/Crosshair.visible, $Pivot/Camera/Crosshair_green.visible]
		$Pivot/Camera/Crosshair.visible = false
		$Pivot/Camera/Crosshair_green.visible = false
		await get_tree().create_timer(0.005).timeout
		$Pivot/Camera/TransitionPlayer/TextureRect.texture = ImageTexture.create_from_image(get_viewport().get_texture().get_image())
		$Pivot/Camera/Crosshair.visible = crosshair_states[0]
		$Pivot/Camera/Crosshair_green.visible = crosshair_states[1]
		$Pivot/Camera/TransitionPlayer.play("Fade")
		self.position = Vector3(90.56,25.42,138.25)

		# reset map stuff
		get_tree().get_first_node_in_group("esc_room").reset()

	elif Input.is_action_just_pressed("return_to_lobby") and current_location == "Lobby":
		quit_timer.start()

	if Input.is_action_just_released("return_to_lobby") and current_location == "Lobby":
		quit_timer.stop()
		quit_timer.set_wait_time(quit_delay)

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

		# disable appearing cubes
		for node in get_tree().get_nodes_in_group("appearing_cube"):
			if node.is_visible:
				node.remove_cube()
			node.disabled = true
		cubes_disabled = true

	if is_on_floor() and cubes_disabled and velocity.y == 0:
		for node in get_tree().get_nodes_in_group("appearing_cube"):
			node.disabled = false
			node.player_check()
		cubes_disabled = false

	# Get the input direction and handle the movement, accelaration and deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (pivot.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)


	# Slope and Stair checking

	# view bobbing animation. temporarily disabled
	#if round(velocity.x) != 0 or round(velocity.z) != 0 :
	#	animation_player.play("view_bobbing")
	#elif snapped(animation_player.current_animation_position, 0.1) in [0.3,0.4,0.5]:
	#	animation_player.stop()

	# accel dampening. buggy. FIX
	#if last_velocity.x != 0 and velocity.x == 0:
	#	velocity.x = snapped(last_velocity.x / deceleration_damper, 0.01)

	#if last_velocity.z != 0 and velocity.z == 0:
	#	velocity.z = snapped(last_velocity.z / deceleration_damper, 0.01)

	# DEBUG: noclipping - fly through everything at will. Literally disables player's collider
	if not noclipping: # if the player is just playing like normal, set his last velocity.
		last_velocity = velocity
	else: # otherwise let him fly
		if direction:
			velocity.y = camera.global_transform.basis.get_euler()[0] * speed
		else:
			velocity.y = move_toward(velocity.y, 0, speed)
	move_and_slide()

	#DEBUG Check for noclip toggle
	if Input.is_action_just_pressed("debug_noclip"):
		noclipping = not noclipping

		if noclipping:
			$Collider.disabled = true
			last_velocity = Vector3(0.0,0.0,0.0)
		else:
			$Collider.disabled = false
	# noclip speed boost. more speed.
	if Input.is_action_pressed("debug_noclip_speedy"):
		speed = speed_boost
	elif Input.is_action_just_released("debug_noclip_speedy"):
		speed = original_speed

	if Input.is_action_just_pressed("toggle_debug"):
		$Pivot/Camera/DebugInfo.visible = not $Pivot/Camera/DebugInfo.visible

	if Input.is_action_just_pressed("debug_triggers"):
		var triggers = get_tree().get_nodes_in_group("trigger")
		#triggers.append(get_tree().get_nodes_in_group("trigger_teleport"))

		if triggers[0].debug_visible:
			for trigger in triggers:
				trigger.visible_off()
		else:
			for trigger in triggers:
				trigger.visible_on()

	# update debug gui
	if $Pivot/Camera/DebugInfo.visible:
		$Pivot/Camera/DebugInfo/FPS_num.text = str(Engine.get_frames_per_second())
		$Pivot/Camera/DebugInfo/PosX_num.text = str(self.position.x)
		$Pivot/Camera/DebugInfo/PosY_num.text = str(self.position.y)
		$Pivot/Camera/DebugInfo/PosZ_num.text = str(self.position.z)
		$Pivot/Camera/DebugInfo/CamRot_X.text = str($Pivot/Camera.rotation.x)
		$Pivot/Camera/DebugInfo/PivRot_Y.text = str($Pivot.rotation.y)
		$Pivot/Camera/DebugInfo/degCamRot_X.text = str(rad_to_deg($Pivot/Camera.rotation.x))
		$Pivot/Camera/DebugInfo/degPivRot_Y.text = str(rad_to_deg($Pivot.rotation.y))

# handle mouse
func _unhandled_input(event: InputEvent) -> void :
	if event is InputEventMouseButton: # This handles focusing and unfocusing the game window (debug)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_focus_next"):
		if mouse_mode == "captured":
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mouse_mode = "visible"
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mouse_mode = "captured"

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED: # if we're in the game window, move the camera
		if event is InputEventMouseMotion:
			if not inverted_mouse:
				pivot.rotate_y(-event.relative.x * (mouse_sensitivity/1000))
				camera.rotate_x(-event.relative.y * (mouse_sensitivity/1000))
				camera.rotation_degrees.x = clamp(
					camera.rotation_degrees.x,
					-90,
					90
				)
			else:
				pivot.rotate_y(-event.relative.x * (mouse_sensitivity/1000))
				camera.rotate_x(event.relative.y * (mouse_sensitivity/1000))
				camera.rotation_degrees.x = clamp(
					camera.rotation_degrees.x,
					-90,
					90
				)

func save():
	return {
		"path": get_path(),
		"name": "player",
		"tool_level": tool_level
		}
