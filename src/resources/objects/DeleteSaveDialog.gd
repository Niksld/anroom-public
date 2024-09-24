extends Node3D

var is_visible := false

func _ready():
	if not is_visible:
		self.visible = false

func change_visibility():
	if is_visible:
		self.position += Vector3(0,0,1)
		is_visible = false
		self.visible = false
	else:
		self.position -= Vector3(0,0,1)
		is_visible = true
		self.visible = true
