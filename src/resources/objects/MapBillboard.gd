extends Node3D

var tutorial_text_state = 0
@onready var anim_player = $RoomPreview/RoomPreview/AnimationPlayer
var preview_visible := false
var room_previews = {
	"Placeholder": "res://src/resources/previews/lof.png",
	"Leap Of Faith": "res://src/resources/previews/lof.png",
	"LeapOfFaith": "res://src/resources/previews/lof.png",
	"aJumpTooFar": "res://src/resources/previews/jtf.png",
	"IntoDarkness": "res://src/resources/previews/id.png",
	"ManyPathsToNowhere": "res://src/resources/previews/mptn.png",
	"threePathsInSight": "res://src/resources/previews/tpis.png",
	"findingTheSeams" : "res://src/resources/previews/fts.png",
	"stuckInARut": "res://src/resources/previews/siar.png"
}
var room_names = {
	"Placeholder": "Missing Text!",
	"LeapOfFaith": "Leap Of Faith",
	"aJumpTooFar": "A Jump Too Far",
	"IntoDarkness": "Into Darkness",
	"ManyPathsToNowhere": "Many Paths To Nowhere",
	"threePathsInSight": "Three Paths In Sight",
	"findingTheSeams": "Finding The Seams",
	"stuckInARut": "Stuck In A Rut"
}
# Called when the node enters the scene tree for the first time.
func _ready():
	anim_player.play("RESET")
	if tutorial_text_state != 2:
		$AnimationPlayer.play("blink")
	else:
		$AnimationPlayer.play("RESET")

func change_tutorial_state(state):
	tutorial_text_state = state

	match state:
		0:
			$TutorialText.text = "Go Here?"
		1:
			$TutorialText.text = "Go Here Again?"
		2:
			$TutorialText.visible = false

func show_preview(room):
	if !preview_visible:
		$RoomPreview/RoomPreview/Node/Sprite3D.texture = load(room_previews[room])
		$RoomPreview/RoomPreview.text = room
		$RoomPreview/RoomPreview/Node/Label3D.text = room_names[room]
		anim_player.play("show_animation")
		preview_visible = true


func hide_preview():
	if preview_visible:
		anim_player.play("hide_preview")
		preview_visible = false

func _process(delta) -> void:
	if !get_tree().get_first_node_in_group("player").crosshair_interacting and preview_visible:
		hide_preview()

func save():
	return {
		"path": get_path(),
		"name": self.name,
		"tutorial_text_state": tutorial_text_state
	}
