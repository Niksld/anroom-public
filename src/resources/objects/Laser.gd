extends Area3D

@export var triggers : Node3D
@export var triggers2 : Node3D
@export_category("Trigger1")
@export_subgroup("Door1 functions")
@export var t1_closes_door := false
@export var t1_opens_door := false
@export_category("Trigger2")
@export_subgroup("Door2 functions")
@export var t2_closes_door := false
@export var t2_opens_door := false

@onready var particles = [$laser, $laser2, $laser3,$laser4,$laser5,$laser7,$laser8,$laser9,$laser11,$laser12]

func _ready():
	$AnimationPlayer.play("oscillate")

func _on_body_entered(body: Node3D) -> void:
	for particle in particles:
		particle.get_active_material(0).albedo_color = Color("magenta")
	if triggers:
		if t1_closes_door:
			triggers.close()
		elif t1_opens_door:
			triggers.open()

	if triggers2:
		if t2_closes_door:
			triggers2.close()
		elif t2_opens_door:
			triggers2.open()

func _on_body_exited(body: Node3D) -> void:
	for particle in particles:
		particle.get_active_material(0).albedo_color = Color("red")
