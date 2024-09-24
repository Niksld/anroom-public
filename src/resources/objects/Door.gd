extends Node3D

@export var isOpen := false

@onready var AnimPlayer = $StaticBody3D/AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AnimPlayer.play("RESET")

func open():
	if not isOpen:
		AnimPlayer.play("open")
		isOpen = true

func close():
	if isOpen:
		AnimPlayer.play("close")
		isOpen = false

func reset():
	AnimPlayer.play("RESET")
	isOpen = false
