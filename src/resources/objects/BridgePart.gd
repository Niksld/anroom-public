extends Node3D

func disable():
	for node in self.get_children():
		if node is Area3D:
			node.disable()

func enable():
	for node in self.get_children():
		if node is Area3D:
			node.enable()
