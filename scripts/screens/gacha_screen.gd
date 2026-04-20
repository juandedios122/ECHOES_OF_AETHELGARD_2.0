extends Control

# ── Nodos ──────────────────────────────────────────────────────────
@onready var gems_label   : Label        = $TopBar/GemsDisplay/GemsLabel
@onready var btn_back     : Button       = $TopBar/BtnBack
@onready var btn_single   : Button       = $ButtonsRow/BtnSingle
@onready var btn_multi    : Button       = $ButtonsRow/BtnMulti
@onready var hero_card    : PanelContainer = $ResultPanel/HeroCard
@onready var multi_panel  : GridContainer  = $MultiPanel
@onready var rarity_label : Label        = $ResultPanel/HeroCard/CardContent/RarityLabel
@onready var hero_color   : ColorRect    = $ResultPanel/HeroCard/CardContent/HeroColor
@onready var hero_name    : Label        = $ResultPanel/HeroCard/CardContent/HeroName
@onready var hero_desc    : Label        = $ResultPanel/HeroCard/CardContent/HeroDesc
@onready var atk_label    : Label        = $ResultPanel/HeroCard/CardContent/StatsRow/AtkLabel
@onready var hp_label     : Label        = $ResultPanel/HeroCard/CardContent/StatsRow/HpLabel
@onready var pity_label   : Label        = $PityBar/PityLabel
@onready var pity_bar     : ProgressBar  = $PityBar/PityProgress

var _is_pulling : bool = false

# ── Lifecycle ──────────────────────────────────────────────────────
func _ready() -> void:
	btn_back.pressed.connect(func(): SceneManager.go_to("lobby"))
	btn_single.pressed.connect(_on_single)
	btn_multi.pressed.connect(_on_multi)
	_update_hud()

# ── HUD ────────────────────────────────────────────────────────────
func _update_hud() -> void:
	gems_label.text = str(PlayerData.gems)
	pity_label.text = "Pity: %d / 90" % GachaSystem.pity_counter
	pity_bar.value  = GachaSystem.pity_counter
	# Deshabilita botones si no hay gemas
	btn_single.disabled = PlayerData.gems < GachaSystem.COST_SINGLE
	btn_multi.disabled  = PlayerData.gems < GachaSystem.COST_MULTI

# ── Handlers ───────────────────────────────────────────────────────
func _on_single() -> void:
	if _is_pulling:
		return
	var results := GachaSystem.pull_single()
	if results.is_empty():
		_flash_no_gems()
		return
	_show_single_result(results[0])

func _on_multi() -> void:
	if _is_pulling:
		return
	var results := GachaSystem.pull_multi()
	if results.is_empty():
		_flash_no_gems()
		return
	_show_multi_result(results)

# ── Mostrar resultado x1 ───────────────────────────────────────────
func _show_single_result(hero: HeroData) -> void:
	rarity_label.text  = GachaSystem.get_rarity_name(hero.rarity).to_upper()
	hero_color.color   = hero.color
	hero_name.text     = hero.hero_name
	hero_desc.text     = hero.desc
	atk_label.text     = "ATK: %d" % hero.atk
	hp_label.text      = "HP: %d"  % hero.hp

	# Animación de entrada
	hero_card.modulate.a = 0.0
	hero_card.scale      = Vector2(0.6, 0.6)
	hero_card.visible    = true

	var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(hero_card, "scale",      Vector2(1.0, 1.0), 0.45)
	tw.parallel().tween_property(hero_card, "modulate:a", 1.0,         0.3)
	await tw.finished

	# Efecto especial si es legendario
	if hero["rarity"] == GachaSystem.Rarity.LEGENDARY:
		await _play_legendary_effect()

	_update_hud()
	_is_pulling = false

# ── Mostrar resultado x10 ──────────────────────────────────────────
func _show_multi_result(heroes: Array) -> void:
	_is_pulling = true
	hero_card.visible   = false

	# Limpia resultados anteriores
	for child in multi_panel.get_children():
		child.queue_free()
	await get_tree().process_frame

	multi_panel.visible = true
	multi_panel.modulate.a = 0.0

	# Crea una mini-carta por héroe
	for i in heroes.size():
		var hero : Dictionary = heroes[i]
		var card := _make_mini_card(hero)
		multi_panel.add_child(card)
		card.modulate.a = 0.0
		# Aparecen en cascada
		var t := create_tween()
		t.tween_interval(i * 0.06)
		t.tween_property(card, "modulate:a", 1.0, 0.25)

	var tw := create_tween()
	tw.tween_property(multi_panel, "modulate:a", 1.0, 0.2)
	await tw.finished

	_update_hud()
	_is_pulling = false

func _make_mini_card(hero: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(200, 160)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)  # ← corregido
	card.add_child(vbox)

	var color_rect := ColorRect.new()
	color_rect.custom_minimum_size = Vector2(180, 80)
	color_rect.color = hero["color"]
	vbox.add_child(color_rect)

	var name_lbl := Label.new()
	name_lbl.text = hero["name"]
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 14)
	vbox.add_child(name_lbl)

	var rarity_lbl := Label.new()
	rarity_lbl.text = GachaSystem.get_rarity_name(hero["rarity"])
	rarity_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rarity_lbl.add_theme_font_size_override("font_size", 12)
	rarity_lbl.add_theme_color_override("font_color", GachaSystem.get_rarity_color(hero["rarity"]))
	vbox.add_child(rarity_lbl)

	return card

# ── Efecto legendario ──────────────────────────────────────────────
func _play_legendary_effect() -> void:
	# Parpadeo dorado 3 veces
	for i in 3:
		var tw := create_tween()
		tw.tween_property(hero_card, "modulate", Color(1.5, 1.3, 0.2, 1.0), 0.15)
		tw.tween_property(hero_card, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.15)
		await tw.finished

# ── Sin gemas ──────────────────────────────────────────────────────
func _flash_no_gems() -> void:
	var tw := create_tween()
	tw.tween_property(gems_label, "modulate", Color(1.0, 0.2, 0.2, 1.0), 0.1)
	tw.tween_property(gems_label, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3)
