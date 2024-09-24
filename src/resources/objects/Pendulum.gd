extends Node3D

@export var delay := 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if delay:
		await get_tree().create_timer(delay).timeout


	$AnimationPlayer.play("swing")
	$Text/AnimationPlayer.play("swing")
