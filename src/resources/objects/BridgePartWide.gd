extends Area3D

# Called when the node enters the scene tree for the first time.
func _ready():
	for node in self.get_children():
		if node is CollisionShape3D:
			return
		node.disable()

func _on_body_entered(body):
	for node in self.get_children():
		if node is CollisionShape3D:
			return
		node.enable()

func _on_body_exited(body):
	self._ready()
