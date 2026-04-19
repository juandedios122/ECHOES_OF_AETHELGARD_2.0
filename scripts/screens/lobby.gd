extends Control

func _ready() -> void:
	_update_ui()
	$MainContent/QuickPlay.pressed.connect(func(): SceneManager.go_to("combat"))
	$MainContent/Exploration.pressed.connect(func(): SceneManager.go_to("exploration"))
	$MainContent/Gacha.pressed.connect(func(): SceneManager.go_to("gacha"))

# Integración con tu PlayerData existente
func _update_ui() -> void:
	# PlayerData es tu Autoload existente
	$TopBar/PlayerName.text = PlayerData.player_name
	$TopBar/CurrencyDisplay/GoldLabel.text = str(PlayerData.gold)
	$TopBar/CurrencyDisplay/GemsLabel.text = str(PlayerData.gems)

# Recibe datos de la transición (si vienen de combate con recompensas, etc.)
func on_scene_data(data: Dictionary) -> void:
	if data.has("reward_gold"):
		PlayerData.gold += data.reward_gold
		_update_ui()
