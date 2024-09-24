extends Area3D

@export var text := "Leap Of Faith"
@export var preview := "res://textures/defur.png"
var function = "teleport_player"

# Called when the node enters the scene tree for the first time.
func _ready():
	$Node/Label3D.text = text
	$Node/Sprite3D.texture = load(preview)
	$AnimationPlayer.play("hide_preview")
