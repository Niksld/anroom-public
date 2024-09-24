extends Node3D

@onready var player_reference := get_tree().get_first_node_in_group("player")
@export var location := self.name
@export var unlocks_map_part := false
@export var unlocks := "None"
@export var works_once: bool
var debug_visible := false
var used = false # This var is checked only when works_once is selcted, otherwise ignored

func _ready():
	$PositionHelper.visible = false
	if works_once:
		add_to_group("persist")

func reset():
	used = false

func visible_on():
	$PositionHelper.visible = true

func visible_off():
	$PositionHelper.visible = false

func _on_body_entered(body):
	player_reference.current_location = location
	print("Changing location to:", location)
	if unlocks_map_part:
		unlock_map(unlocks)
	if location not in get_tree().get_first_node_in_group("globals").unlocked_locations:
		get_tree().get_first_node_in_group("globals").unlocked_locations.append(location)
		if location != "LeapOfFaith":
			get_tree().get_first_node_in_group("globals").add_room_to_map(location)
func _on_body_exited(body):
	player_reference.last_location = location

func unlock_map(unlockable):
	get_tree().get_first_node_in_group("globals").unlock_map_part(unlockable)

