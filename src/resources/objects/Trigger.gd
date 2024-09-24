extends Node3D

@export_category("Trigger")
@onready var player_reference := get_tree().get_first_node_in_group("player")
@export var works_once: bool
@export_group("Function")
@export var on_entered_function := "None"
@export var on_exited_function := "None"
@export var debug_visible = false
var used = false # This var is checked only when works_once is selcted, otherwise ignored

func _ready():
	$PositionHelper.visible = false
	if works_once:
		add_to_group("persist")

func run_global_function(function):
	get_tree().get_first_node_in_group("globals").run_function_by_name(on_entered_function)
	get_tree().get_first_node_in_group("globals").run_function_by_name(on_exited_function)

func reset():
	used = false

func visible_on():
	$PositionHelper.visible = true
	debug_visible = true

func visible_off():
	$PositionHelper.visible = false
	debug_visible = false

func _on_area_3d_body_entered(body):
	run_global_function(self)

func _on_area_3d_body_exited(body):
	run_global_function(self)
