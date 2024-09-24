extends Node3D

@export_category("ConfigButton")
@onready var label = $Label3D
@export var text := "Placeholder"
@export var function := "none"
@export var selected := false
@export_category("Pairing") # since Godot doesnt allow an array of Nodes in @export, we have to do this...
var paired_count := 0
@export var paired_with_1: Node3D
@export var paired_with_2: Node3D
@export var paired_with_3: Node3D
@export var paired_with_4: Node3D
@export var paired_with_5: Node3D
@export var paired_with_6: Node3D
@export var paired_with_7: Node3D
@export var paired_with_8: Node3D
@export var paired_with_9: Node3D
@export var paired_with_10: Node3D
@onready var paired_with := [paired_with_1, paired_with_2, paired_with_3, paired_with_4,
paired_with_5, paired_with_6, paired_with_7, paired_with_8, paired_with_9, paired_with_10]

func _ready():
	label.text = text
	if selected:
		toggle_selection()
	# count how many nodes are paired togheter with this node. for ease of use
	for i in range(len(paired_with)):
		if paired_with[i] != null:
			paired_count += 1

func toggle_selection():

	$Selected.visible = not $Selected.visible
	selected = $Selected.visible

	if selected:
		$Label3D.modulate = Color(Color.BLACK)
	else:
		$Label3D.modulate = Color(Color.WHITE)

func check_paired():
	for i in range(paired_count):
		if paired_with[i].selected:
			paired_with[i].toggle_selection()
	toggle_selection()

func save():
	return {
		"path": get_path(),
		"name": self.name,
		"selected": selected
	}


