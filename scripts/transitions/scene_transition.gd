extends CanvasLayer

@onready var overlay: ColorRect = $ColorRect

func _ready() -> void:
	overlay.color = Color(0, 0, 0, 0)

func fade_out() -> void:
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween()
	tween.tween_property(overlay, "color:a", 1.0, 0.25)
	await tween.finished

func fade_in() -> void:
	var tween := create_tween()
	tween.tween_property(overlay, "color:a", 0.0, 0.3)
	await tween.finished
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

func inject_data(data: Dictionary) -> void:
	var new_scene = get_tree().current_scene
	if new_scene and new_scene.has_method("on_scene_data"):
		new_scene.on_scene_data(data)
