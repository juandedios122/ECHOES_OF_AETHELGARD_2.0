extends Control

@onready var btn_play     : TextureButton = $ButtonPlay
@onready var btn_gacha    : TextureButton = $ButtonGacha
@onready var btn_settings : TextureButton = $ButtonSettings
@onready var logo         : Label  = $Logo

func _ready() -> void:
	_connect_buttons()
	_animate_entrance()

func _connect_buttons() -> void:
	btn_play.pressed.connect(_on_play)
	btn_gacha.pressed.connect(_on_gacha)
	btn_settings.pressed.connect(_on_settings)

	for btn in [btn_play, btn_gacha, btn_settings]:
		btn.mouse_entered.connect(_on_btn_hover.bind(btn))
		btn.mouse_exited.connect(_on_btn_unhover.bind(btn))

func _on_play() -> void:
	SceneManager.go_to("lobby")

func _on_gacha() -> void:
	SceneManager.go_to("gacha")

func _on_settings() -> void:
	print("Ajustes — pendiente")

func _on_btn_hover(btn: Button) -> void:
	var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(btn, "scale", Vector2(1.05, 1.05), 0.12)

func _on_btn_unhover(btn: Button) -> void:
	var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.12)

func _animate_entrance() -> void:
	# Logo fade in desde arriba — solo modulate, no position
	logo.modulate.a = 0.0
	var tl := create_tween()
	tl.tween_property(logo, "modulate:a", 1.0, 0.6)\
	  .set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# Botones: solo fade, SIN mover position (el VBoxContainer los controla)
	var btns := [btn_play, btn_gacha, btn_settings]
	for i in btns.size():
		var b : TextureButton = btns[i]
		b.modulate.a = 0.0
		var t := create_tween()
		t.tween_interval(0.15 + i * 0.12)
		t.tween_property(b, "modulate:a", 1.0, 0.4)\
		 .set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
