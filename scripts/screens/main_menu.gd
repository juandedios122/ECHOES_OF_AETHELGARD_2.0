extends Control

func _ready() -> void:
	$VBoxContainer/ButtonPlay.pressed.connect(_on_play)
	$VBoxContainer/ButtonGacha.pressed.connect(_on_gacha)
	# Animación de entrada: los botones bajan desde arriba
	_animate_entrance()

func _animate_entrance() -> void:
	var buttons = $VBoxContainer.get_children()
	for i in buttons.size():
		var btn = buttons[i]
		btn.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_interval(0.1 * i)
		tween.tween_property(btn, "modulate:a", 1.0, 0.3)

func _on_play() -> void:
	SceneManager.go_to("lobby")

func _on_gacha() -> void:
	SceneManager.go_to("gacha")
