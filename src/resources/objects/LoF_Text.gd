extends Node3D

var jump_visible = true

func change_to_walk():
	if jump_visible:
		$"JUMP!!".visible = false
		$"WALK?".visible = true
		jump_visible = false

func save():
	return {
		"name": "LoF_Text",
		"path": get_path(),
		"jump_visible": jump_visible
	}
