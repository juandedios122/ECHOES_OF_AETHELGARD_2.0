# SceneManager.gd
# Autoload - agrégalo en Project > Project Settings > Autoload
extends Node

const SCENES = {
	"main_menu":     "res://scenes/screens/MainMenu.tscn",
	"lobby":         "res://scenes/screens/Lobby.tscn",
	"gacha":         "res://scenes/screens/GachaScreen.tscn",
	"combat":        "res://scenes/screens/CombatScene.tscn",
	"exploration":   "res://scenes/screens/ExplorationMap.tscn",
}

var _transition_scene: PackedScene = preload("res://scenes/transitions/SceneTransition.tscn")
var _current_scene_key: String = ""
var _transition_layer: CanvasLayer

func _ready() -> void:
	_transition_layer = CanvasLayer.new()
	_transition_layer.layer = 100  # siempre encima de todo
	add_child(_transition_layer)

# Uso: SceneManager.go_to("lobby")
# Con datos opcionales: SceneManager.go_to("combat", { "enemy_id": "goblin_01" })
func go_to(scene_key: String, data: Dictionary = {}) -> void:
	assert(SCENES.has(scene_key), "Escena no registrada: " + scene_key)
	_current_scene_key = scene_key
	_play_transition(SCENES[scene_key], data)

func _play_transition(scene_path: String, data: Dictionary) -> void:
	var transition = _transition_scene.instantiate()
	_transition_layer.add_child(transition)
	await transition.fade_out()          # espera animación de salida
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame       # espera un frame para que cargue
	transition.inject_data(data)         # pasa datos a la nueva escena
	await transition.fade_in()
	transition.queue_free()

func get_current() -> String:
	return _current_scene_key