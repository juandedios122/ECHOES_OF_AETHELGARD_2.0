extends Node

const SCENES := {
	"main_menu"  : "res://scenes/screens/MainMenu.tscn",
	"lobby"      : "res://scenes/screens/Lobby.tscn",
	"gacha"      : "res://scenes/screens/GachaScreen.tscn",
	"combat"     : "res://scenes/screens/CombatScene.tscn",
	"exploration": "res://scenes/screens/ExplorationMap.tscn",
}

var _current_scene_key : String = ""
var _is_transitioning  : bool   = false
var _transition_scene  : PackedScene = preload("res://scenes/transitions/SceneTransition.tscn")

func go_to(scene_key: String, data: Dictionary = {}) -> void:
	if _is_transitioning:
		return
	assert(SCENES.has(scene_key), "Escena no registrada: " + scene_key)
	_current_scene_key = scene_key
	_is_transitioning  = true
	await _play_transition(SCENES[scene_key], data)
	_is_transitioning  = false

func _play_transition(scene_path: String, data: Dictionary) -> void:
	var transition = _transition_scene.instantiate()
	get_tree().root.add_child(transition)
	await transition.fade_out()
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	transition.inject_data(data)
	await transition.fade_in()
	transition.queue_free()

func get_current() -> String:
	return _current_scene_key
