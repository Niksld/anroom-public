extends StaticBody3D

var is_visible = false
var disappear = false
var disabled = false
var player_detected = false
#@onready var collider = $MeshInstance3D/StaticBody3D/CollisionShape3D

func _ready():
	$MeshInstance3D.visible = false

func _on_body_entered(body):
	if disabled:
		return

	if not $MeshInstance3D.visible:
		toggle_invis_and_collider()
	$MeshInstance3D/AnimationPlayer.play("appear")
	#collider.disabled = false
	is_visible = true
	player_detected = true

func _on_body_exited(body):
	if disabled:
		return
	disappear = true
	$MeshInstance3D/AnimationPlayer.play("disappear")
	#collider.disabled = true
	is_visible = false
	player_detected = false

func remove_cube():
	self._on_body_exited(null)

func disable():
	self.monitorable = false
	self.monitoring = false
	$CollisionShape3D.disabled = true
	disabled = true

func enable():
	self.monitorable = true
	self.monitoring = true
	$CollisionShape3D.disabled = false
	disabled = false

func player_check():
	if player_detected:
		self._on_body_entered(null)

func toggle_invis_and_collider():
	$MeshInstance3D.visible = not $MeshInstance3D.visible
	$MeshInstance3D/StaticBody3D/CollisionShape3D.disabled = not $MeshInstance3D/StaticBody3D/CollisionShape3D.disabled
