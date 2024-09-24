extends Node3D

@export var isOpen := false
@export var wait_time := 5.0
@onready var timer := Timer.new()
@onready var AnimPlayer = $StaticBody3D/AnimationPlayer
var hasPassedThrough := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AnimPlayer.play("RESET")
	timer.set_wait_time(wait_time)
	timer.timeout.connect(self._on_timer_timeout)

	add_child(timer)

func open():
	if not isOpen:
		AnimPlayer.play("open")
		isOpen = true

func close():
	if isOpen:
		AnimPlayer.play("close")
		isOpen = false

func reset():
	AnimPlayer.play("RESET")
	timer.stop()
	timer.set_wait_time(wait_time)
	isOpen = false

func _on_visible_on_screen_notifier_3d_screen_entered():
	timer.start()

func _on_visible_on_screen_notifier_3d_screen_exited():
	if not hasPassedThrough:
		timer.stop()
		timer.set_wait_time(wait_time)
		close()

func _on_timer_timeout():
	open()
# Pass Through check
func _on_area_3d_body_entered(body):
	hasPassedThrough = true

func _on_before_eye_trigger_body_entered(body):
	hasPassedThrough = false
