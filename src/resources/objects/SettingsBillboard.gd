extends Node3D

# This needs to exist because godot on windows is unhappy if this script full of nothing isnt here.
# Tough luck i guess.
var time_remaining = 5400
@onready var timer := Timer.new()

func _ready() -> void:
	timer.set_wait_time(time_remaining)
	timer.timeout.connect(self._on_timer_timeout)
	timer.one_shot = true # Niko oneshot reference

	add_child(timer)
	timer.start()

	if time_remaining == 0:
		$Timer/Time.visible = false
		$Timer/Headline.visible = false
		$Timer/Wisdom.visible = true
		$Timer/Sprite3D.visible = true

func _physics_process(delta: float) -> void:
	# Convert seconds into time:
	if !timer.is_stopped():
		var time = (timer.time_left / 60) / 60
		var hours = floor(time)
		var minutes = floor((time - hours) * 60)
		var seconds = floor((((time - hours) * 60) - minutes) * 60)

		if seconds < 10:
			seconds = "0"+str(seconds)
		if minutes < 10:
			minutes = "0"+str(minutes)
		#print(hours, ":",minutes,":",seconds, "   ",timer.time_left)
		$Timer/Time.text = "0{hours}  :  {minutes}  :  {seconds}".format({"hours": hours, "minutes": minutes, "seconds": seconds})

func _on_timer_timeout():
	get_tree().get_first_node_in_group("globals").add_to_sticker_billboard(6)
	$Timer/Time.visible = false
	$Timer/Headline.visible = false
	$Timer/Wisdom.visible = true
	$Timer/Sprite3D.visible = true

func reset():
	time_remaining = 5400
	var timer := Timer.new()
	_ready()

func save():
	return {
		"name": "timer",
		"path": get_path(),
		"time_remaining" : floor(timer.time_left)
	}

func set_time(new_time):
	time_remaining = new_time
	var timer := Timer.new()
	_ready()
