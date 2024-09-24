extends Area3D
class_name Sticker

@export var text := "Placeholder"
@export var id := 1
@export var picture : Texture2D
var function := "sticker"
@export var selected := false
@export var claimed := false
@export var is_visible := true
@export var offset_sticker_by_when_not_visible : Vector3
@export var run_function_on_claimed := false
@export var function_name : String
@export_category("Triggers")
@export var triggers_other_stickers := false
@export var trigger1 : Sticker
@export var trigger2 : Sticker
@export var trigger3 : Sticker


# Called when the node enters the scene tree for the first time.
func _ready():
	$StaticBody3D/MeshInstance3D/Text.text = text
	$StaticBody3D/MeshInstance3D/Sprite3D.texture = picture
	$StaticBody3D/MeshInstance3D/AnimationPlayer.play("RESET")

	if not is_visible:
		is_visible = true
		toggle_visibility()

func toggle_selected(skip_triggers=false):
	if not selected:
		$StaticBody3D/MeshInstance3D/AnimationPlayer.play("show_wisdom")

		if !claimed:
			claimed = true
			get_tree().get_first_node_in_group("globals").add_to_sticker_billboard(self.id)

			if self.id == 1:
				print("Sticker: Sticker at: " + str(get_path()) + " has id=1! ")
	else:
		$StaticBody3D/MeshInstance3D/AnimationPlayer.play("show_picture")
	selected = not selected

	if triggers_other_stickers and not skip_triggers:
		trigger1.toggle_selected(true)
		trigger2.toggle_selected(true)
		trigger3.toggle_selected(true)

func toggle_visibility():
	if is_visible:
		#self.visible = false
		is_visible = false
		position.x += offset_sticker_by_when_not_visible.x
		position.y += offset_sticker_by_when_not_visible.y
		position.z += offset_sticker_by_when_not_visible.z
	else:
		#self.visible = true
		is_visible = true
		position.x -= offset_sticker_by_when_not_visible.x
		position.y -= offset_sticker_by_when_not_visible.y
		position.z -= offset_sticker_by_when_not_visible.z

func save():
	return {
		"name": "sticker",
		"path": get_path(),
		"selected": selected,
		"claimed": claimed,
		"is_visible": is_visible
	}
