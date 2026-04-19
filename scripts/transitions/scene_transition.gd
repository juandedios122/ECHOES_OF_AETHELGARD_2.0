extends Node

@onready var overlay: ColorRect = $ColorRect
var _scene_data: Dictionary = {}

func _ready() -> void:
	overlay.color = Color(0, 0, 0, 0)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func fade_out() -> void:
	var tween = create_tween()
	tween.tween_property(overlay, "color:a", 1.0, 0.25)
	await tween.finished

func fade_in() -> void:
	var tween = create_tween()
	tween.tween_property(overlay, "color:a", 0.0, 0.3)
	await tween.finished

# La nueva escena puede llamar esto desde su _ready()
func inject_data(data: Dictionary) -> void:
	_scene_data = data
	# Notifica a la escena recién cargada
	var new_scene = get_tree().current_scene
	if new_scene.has_method("on_scene_data"):
		new_scene.on_scene_data(data)
