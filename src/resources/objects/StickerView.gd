extends Area3D

var function = "sticker_view"
@export var picture: Texture2D
@export var wisdom: String
@onready var animplayer = $AnimationPlayer
@export var is_visible = false
var finished = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$Label3D.visible = false
	$Sprite3D.texture = picture
	$Label3D.text = wisdom
	animplayer.play("RESET")

	if !is_visible:
		set2invisible()

func set2visible():
	self.visible = true
	$CollisionShape3D.disabled = false

func set2invisible():
	self.visible = false
	$CollisionShape3D.disabled = true

func show_sticker():
	get_tree().get_first_node_in_group("globals").sticker_animation_playing = true
	$CollisionShape3D.disabled = true
	animplayer.get_animation("show").track_set_key_value(0, 1, Vector3(-position.z, -position.y,-0.1))
	animplayer.get_animation("show").track_set_key_value(1, 1, Vector3(-position.z, -position.y,-0.2))
	animplayer.get_animation("unwrap").track_set_key_value(1, 0, Vector3(-position.z, -position.y,-0.2))
	animplayer.get_animation("unwrap").track_set_key_value(1, 1, Vector3(-position.z+2, -position.y,-0.2))
	animplayer.get_animation("unwrap").track_set_key_value(2, 0, Vector3(-position.z, -position.y,-0.11))
	animplayer.get_animation("unwrap").track_set_key_value(2, 1, Vector3(-position.z-1.5, -position.y,-0.11))
	animplayer.play("show")
	await get_tree().create_timer(0.5).timeout
	$Label3D.visible = true
	animplayer.play("unwrap")
	#await get_tree().create_timer(1).timeout
	$CollisionShape3D.position = Vector3(-position.z, -position.y,-0.1)
	$CollisionShape3D.scale = Vector3(8,4,0.1)
	$CollisionShape3D.disabled = false
	function = "sticker_hide"
	finished = true

func hide_sticker():
	get_tree().get_first_node_in_group("globals").sticker_animation_playing = true
	$CollisionShape3D.disabled = true
	animplayer.play_backwards("unwrap")
	await get_tree().create_timer(0.5).timeout
	$Label3D.visible = false
	animplayer.get_animation("show").track_set_key_value(0, 1, Vector3(-position.z,-position.y,-0.1))
	animplayer.get_animation("show").track_set_key_value(1, 1, Vector3(-position.z,-position.y,-0.2))
	animplayer.get_animation("unwrap").track_set_key_value(1, 0, Vector3(-position.z, -position.y,-0.2))
	animplayer.get_animation("unwrap").track_set_key_value(1, 1, Vector3(-position.z+2, -position.y,-0.2))
	animplayer.get_animation("unwrap").track_set_key_value(2, 0, Vector3(-position.z, -position.y,-0.11))
	animplayer.get_animation("unwrap").track_set_key_value(2, 1, Vector3(-position.z-1.5, -position.y,-0.11))
	animplayer.play_backwards("show")
	#await get_tree().create_timer(1).timeout
	$CollisionShape3D.position = Vector3(0,0,0)
	$CollisionShape3D.scale = Vector3(2,2,0.1)
	$CollisionShape3D.disabled = false
	function = "sticker_view"
	finished = true

func unblock_animations(anim_name):
	if finished:
		get_tree().get_first_node_in_group("globals").sticker_animation_playing = false
		finished = false

func save():
	return {
		"name": "sticker_view",
		"path": get_path(),
		"visible": self.visible
	}
