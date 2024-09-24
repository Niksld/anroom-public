extends Node3D
class_name PortalWall

@onready var portal = $Portal
@export var vertical_viewport_resolution := 0
@export var disable_viewport_distance := 250
@export var destroy_disabled_viewport := true
@export var fade_out_distance_max := 250
@export var fade_out_distance_min := 8
@export var fade_out_color := Color.WHITE
@export var exit_scale := 1
@export var exit_near_subtract := 0.05
@export var main_camera : Camera3D
@export var environment = Environment.new()
@export var exit_portal : PortalWall
@export_group("Environment")
@export_subgroup("Background")
@export_enum("Custom Color", "Camera Feed") var background_mode : String
@export var background_color := Color.WHITE
@export var background_energy_multiplier := 1.0
@export_subgroup("Ambient Light")
@export_enum("Color","Background", "Disabled", "Sky") var ambient_light_source: String
@export var ambient_color := Color.WHITE
@export var ambient_energy := 1.2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the environment
	match ambient_light_source:
		"Color":
			environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		"Background":
			environment.ambient_light_source = Environment.AMBIENT_SOURCE_BG
		"Disabled":
			environment.ambient_light_source = Environment.AMBIENT_SOURCE_DISABLED
		"Sky":
			environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY

	environment.ambient_light_color = ambient_color
	environment.ambient_light_energy = ambient_energy

	match background_mode:
		"Custom Color":
			environment.background_mode = Environment.BG_COLOR
		"Camera Feed":
			environment.background_mode = Environment.BG_CAMERA_FEED
	environment.background_color = background_color
	environment.background_energy_multiplier = background_energy_multiplier

	# Set the actual portals properties
	portal.vertical_viewport_resolution = vertical_viewport_resolution
	portal.disable_viewport_distance = disable_viewport_distance
	portal.destroy_disabled_viewport = destroy_disabled_viewport
	portal.fade_out_distance_max = fade_out_distance_max
	portal.fade_out_distance_min = fade_out_distance_min
	portal.fade_out_color = fade_out_color
	portal.exit_scale = exit_scale
	portal.exit_near_subtract = exit_near_subtract
	portal.main_camera = main_camera
	#portal.environment = environment
	portal.exit_portal = exit_portal.portal

	# Warn if portal is misplaced -: missplacing causes artifacts and the portal doesnt work properly
	if portal.position != Vector3(0,0,0):
		print("!!!WARN!!! TELEPORT "+ name +" MISPLACED!")
