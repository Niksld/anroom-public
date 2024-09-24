extends Node3D
class_name TeleportTrigger

@onready var player_reference := get_tree().get_first_node_in_group("player") # so we dont need to specify each time
@export var works_once: bool
@export var disabled: bool
@export var paired_with : TeleportTrigger
@export var portal : Portal
@export var teleportee_exit_rotate_pivot_degrees : float
@export var y_offset := 0
@export var skip_intersect_check := false
@export_group("Teleport")
@export var destination : Vector3
@export var rotation_offset_degrees : float
@export var offset_player_by_value := false # instead of setting the absolute position, add to the players position
@export_group("Function")
@export var on_entered_function := "None"
@export var on_exited_function := "None"
@export var debug_visible = false
var temporary_disabled = false
var used = false # This var is checked only when works_once is selcted, otherwise ignored

func _ready():
	$PositionHelper.visible = false # disable the visible mesh
	if works_once:
		add_to_group("persist") # and save the trigger if its persistent

func run_global_function(function):
	get_tree().get_first_node_in_group("globals").run_function_by_name(function)

func reset():
	used = false

func visible_on():
	$PositionHelper.visible = true
	debug_visible = true

func visible_off():
	$PositionHelper.visible = false
	debug_visible = false

func _on_area_3d_body_entered(body):
	# Dont teleport the player if the teleport is disabled
	if disabled or temporary_disabled and not skip_intersect_check:
		return
	# If the teleport has another function, run it
	run_global_function(on_entered_function)
	# If we didnt pair this teleport with another, we probably want
	# to teleport to specific coords
	if paired_with == null:
		if not offset_player_by_value:
			player_reference.position = destination
		else:
			player_reference.position.x += destination.x
			player_reference.position.y += destination.y
			player_reference.position.z += destination.z

		if rotation_offset_degrees != 0:
			player_reference.pivot.rotation_degrees.y += rotation_offset_degrees
	else: # Otherwise teleport to the other teleport
		print("Teleporting Player from "+ str(global_position))
		if portal != null:
			paired_with.temporary_disabled = true
			var destination = portal.real_to_exit_position(player_reference.camera.global_position)
			player_reference.position = destination
			player_reference.position.y += y_offset
			player_reference.pivot.rotation_degrees.y += teleportee_exit_rotate_pivot_degrees
		else:
			print("Relative teleports without portals are unavailable.")
			return


		#player_reference.pivot.rotation_degrees.y += teleportee_exit_rotate_pivot_degrees
		# this works way better than i expected -  rewrote original function as well\
		# (its the obvious approach i dont know why i didnt do it this way before 💀)

func _on_area_3d_body_exited(body):
	if disabled:
		return

	if temporary_disabled and not skip_intersect_check:
		temporary_disabled = false # This prevents the player for teleporting endlessly
		print("reset portal")
		return

	run_global_function(on_exited_function)

func disable():
	disabled = true
func enable():
	disabled = false
