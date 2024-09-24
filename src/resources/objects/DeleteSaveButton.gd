extends Node3D

var is_visible := true
var function := "delete_save_button"

func change_visibility():
	if is_visible:
		self.visible = false
		is_visible = false
		self.position -= Vector3(0,0,2)
		$CollisionShape3D.disabled = true
	else:
		self.visible = true
		is_visible = true
		self.position += Vector3(0,0,2)
		$CollisionShape3D.disabled = false
