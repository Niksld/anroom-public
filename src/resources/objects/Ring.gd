extends StaticBody3D

@export var is_visible = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func change_visibility():
	if is_visible:
		self.visible = false
		$CollisionShape3D.disabled = true
	else:
		self.visible = true
		$CollisionShape3D.disabled = false

func save():
	return {
		"name": "ring",
		"path": get_path(),
		"is_visible": is_visible
	}
