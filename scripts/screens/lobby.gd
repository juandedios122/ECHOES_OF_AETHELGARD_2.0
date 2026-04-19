extends Control

@onready var player_name  : Label  = $TopBar/TopBarContent/PlayerInfo/PlayerName
@onready var gold_label   : Label  = $TopBar/TopBarContent/CurrencyDisplay/GoldContainer/GoldLabel
@onready var gems_label   : Label  = $TopBar/TopBarContent/CurrencyDisplay/GemsContainer/GemsLabel
@onready var btn_combat   : Button = $MainContent/QuickPlay
@onready var btn_explore  : Button = $MainContent/Exploration
@onready var btn_gacha    : Button = $MainContent/Gacha
@onready var nav_home     : Button = $BottomNav/NavHome
@onready var nav_heroes   : Button = $BottomNav/NavHeroes
@onready var nav_shop     : Button = $BottomNav/NavShop

func _ready() -> void:
	_connect_signals()
	_update_ui()
	_animate_entrance()

func _connect_signals() -> void:
	btn_combat.pressed.connect(func(): SceneManager.go_to("combat"))
	btn_explore.pressed.connect(func(): SceneManager.go_to("exploration"))
	btn_gacha.pressed.connect(func(): SceneManager.go_to("gacha"))

	nav_home.pressed.connect(func(): print("Ya estás en Inicio"))
	nav_heroes.pressed.connect(func(): print("Héroes — pendiente"))
	nav_shop.pressed.connect(func(): print("Tienda — pendiente"))

	# Hover en botones principales
	for btn in [btn_combat, btn_explore, btn_gacha]:
		btn.mouse_entered.connect(_on_btn_hover.bind(btn))
		btn.mouse_exited.connect(_on_btn_unhover.bind(btn))

func _update_ui() -> void:
	player_name.text = PlayerData.player_name
	gold_label.text  = str(PlayerData.gold)
	gems_label.text  = str(PlayerData.gems)

func _animate_entrance() -> void:
	# TopBar baja desde arriba
	var topbar := $TopBar
	topbar.modulate.a = 0.0
	var tt := create_tween()
	tt.tween_property(topbar, "modulate:a", 1.0, 0.4)

	# Botones principales aparecen en cascada
	var btns := [btn_combat, btn_explore, btn_gacha]
	for i in btns.size():
		var b : Button = btns[i]
		b.modulate.a = 0.0
		var t := create_tween()
		t.tween_interval(0.1 + i * 0.1)
		t.tween_property(b, "modulate:a", 1.0, 0.35)\
		 .set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# BottomNav aparece desde abajo
	var botnav := $BottomNav
	botnav.modulate.a = 0.0
	var tb := create_tween()
	tb.tween_interval(0.4)
	tb.tween_property(botnav, "modulate:a", 1.0, 0.3)

func _on_btn_hover(btn: Button) -> void:
	var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(btn, "scale", Vector2(1.06, 1.06), 0.12)

func _on_btn_unhover(btn: Button) -> void:
	var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.12)

# Recibe datos al volver de combate o gacha
func on_scene_data(data: Dictionary) -> void:
	if data.has("reward_gold"):
		PlayerData.add_gold(data["reward_gold"])
	if data.has("reward_gems"):
		PlayerData.add_gems(data["reward_gems"])
	_update_ui()
