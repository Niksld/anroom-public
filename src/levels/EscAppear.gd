extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MeshInstance3D.visible = false
	$StaticBody3D/CollisionShape3D.disabled = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	$MeshInstance3D.visible = true
	$StaticBody3D/CollisionShape3D.disabled = false

func reset():
	self._ready()
