extends Control

@onready var player_name  : Label  = $TopBar/PlayerName
@onready var gold_label   : Label  = $TopBar/CurrencyDisplay/GoldLabel
@onready var gems_label   : Label  = $TopBar/CurrencyDisplay/GemsLabel
@onready var btn_combat   : Button = $MainContent/QuickPlay
@onready var btn_explore  : Button = $MainContent/Exploration
@onready var btn_gacha    : Button = $MainContent/Gacha
@onready var nav_home     : Button = $BottomNav/NavHome
@onready var nav_heroes   : Button = $BottomNav/NavHeroes
@onready var nav_shop     : Button = $BottomNav/NavShop

# Datos temporales hasta que integres tu PlayerData real
var _gold  : int = 0
var _gems  : int = 0
var _pname : String = "Viajero"

func _ready() -> void:
	_connect_signals()
	_update_ui()

func _connect_signals() -> void:
	btn_combat.pressed.connect(func(): SceneManager.go_to("combat"))
	btn_explore.pressed.connect(func(): SceneManager.go_to("exploration"))
	btn_gacha.pressed.connect(func(): SceneManager.go_to("gacha"))
	nav_home.pressed.connect(func(): print("Ya estás en Home"))
	nav_heroes.pressed.connect(func(): print("Heroes — pendiente"))
	nav_shop.pressed.connect(func(): print("Tienda — pendiente"))

func _update_ui() -> void:
	player_name.text = _pname
	gold_label.text  = "Oro: %d" % _gold
	gems_label.text  = "Gemas: %d" % _gems

# Cuando integres PlayerData, reemplaza las vars locales:
# func _update_ui() -> void:
#     player_name.text = PlayerData.player_name
#     gold_label.text  = "Oro: %d" % PlayerData.gold
#     gems_label.text  = "Gemas: %d" % PlayerData.gems

func on_scene_data(data: Dictionary) -> void:
	if data.has("reward_gold"):
		_gold += data["reward_gold"]
	if data.has("reward_gems"):
		_gems += data["reward_gems"]
	_update_ui()
