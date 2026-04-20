extends Control

# ── Estructura de un nodo del mapa ────────────────────────────────
const MAP_NODES := [
	{
		"id"       : "ruins_01",
		"name"     : "Ruinas de Aethelgard",
		"desc"     : "Nivel 1 — Los primeros pasos del héroe",
		"type"     : "combat",
		"position" : Vector2(0.15, 0.6),   # posición relativa 0-1
		"connects" : ["forest_02"],
		"unlocked" : true,
		"enemy_id" : "goblin",
	},
	{
		"id"       : "forest_02",
		"name"     : "Bosque Maldito",
		"desc"     : "Nivel 2 — Criaturas acechan entre los árboles",
		"type"     : "combat",
		"position" : Vector2(0.35, 0.4),
		"connects" : ["cave_03"],
		"unlocked" : false,
		"enemy_id" : "wolf",
	},
	{
		"id"       : "cave_03",
		"name"     : "Caverna del Troll",
		"desc"     : "Nivel 3 — Un troll guarda el paso",
		"type"     : "elite",
		"position" : Vector2(0.55, 0.55),
		"connects" : ["castle_04"],
		"unlocked" : false,
		"enemy_id" : "troll",
	},
	{
		"id"       : "castle_04",
		"name"     : "Castillo Oscuro",
		"desc"     : "JEFE — El señor de las tinieblas",
		"type"     : "boss",
		"position" : Vector2(0.8, 0.35),
		"connects" : [],
		"unlocked" : false,
		"enemy_id" : "dark_lord",
	},
]

# Colores por tipo de nodo
const NODE_COLORS := {
	"combat" : Color("#4A6741"),   # verde oscuro
	"elite"  : Color("#6B4A8C"),   # púrpura
	"boss"   : Color("#8C2A2A"),   # rojo oscuro
}

# ── Nodos de escena ────────────────────────────────────────────────
@onready var btn_back        : Button  = $TopBar/BtnBack
@onready var stamina_label   : Label   = $TopBar/StaminaDisplay/StaminaLabel
@onready var nodes_container : Control = $MapContainer/NodesContainer
@onready var path_lines      : Control = $MapContainer/PathLines
@onready var info_panel      : PanelContainer = $NodeInfoPanel
@onready var node_name_lbl   : Label   = $NodeInfoPanel/InfoContent/NodeName
@onready var node_desc_lbl   : Label   = $NodeInfoPanel/InfoContent/NodeDesc
@onready var btn_enter       : Button  = $NodeInfoPanel/InfoContent/BtnEnter
@onready var chapter_label   : Label   = $BottomBar/ChapterLabel

var _selected_node : Dictionary = {}
var _node_buttons  : Dictionary = {}   # id → Button

# ── Lifecycle ──────────────────────────────────────────────────────
func _ready() -> void:
	btn_back.pressed.connect(func(): SceneManager.go_to("lobby"))
	btn_enter.pressed.connect(_on_enter_node)
	_build_map()
	_update_stamina()

# ── Construye el mapa dinámicamente ───────────────────────────────
func _build_map() -> void:
	var map_size := nodes_container.get_viewport_rect().size
	map_size.y -= 150.0  # margen topbar + bottombar

	for node_data in MAP_NODES:
		_create_map_node(node_data, map_size)

	# Dibuja líneas de conexión después de crear todos los botones
	await get_tree().process_frame
	queue_redraw()

@warning_ignore("unused_parameter")
func _create_map_node(node_data: Dictionary, _map_size: Vector2) -> void:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(100, 100)
	btn.text = _get_node_icon(node_data["type"])

	# Posición basada en coordenadas relativas
	var pos := Vector2(
		node_data["position"].x * 1920.0 - 50.0,
		node_data["position"].y * 900.0  - 50.0
	)
	btn.set_position(pos)

	# Estilo según estado
	if not node_data["unlocked"]:
		btn.modulate = Color(0.4, 0.4, 0.4, 0.7)
		btn.disabled = true
	else:
		btn.modulate = NODE_COLORS.get(node_data["type"], Color.WHITE)

	btn.pressed.connect(_on_node_pressed.bind(node_data))
	nodes_container.add_child(btn)
	_node_buttons[node_data["id"]] = btn

func _get_node_icon(type: String) -> String:
	match type:
		"combat"  : return "⚔"
		"elite"   : return "★"
		"boss"    : return "☠"
	return "?"

# ── Dibuja líneas entre nodos conectados ──────────────────────────
func _draw() -> void:
	for node_data in MAP_NODES:
		if not _node_buttons.has(node_data["id"]):
			continue
		var from_btn : Button = _node_buttons[node_data["id"]]
		var from_pos := from_btn.position + Vector2(50, 50)

		for connected_id in node_data["connects"]:
			if not _node_buttons.has(connected_id):
				continue
			var to_btn   : Button = _node_buttons[connected_id]
			var to_pos   := to_btn.position + Vector2(50, 50)
			var color    := Color(0.5, 0.4, 0.2, 0.6)
			draw_line(from_pos, to_pos, color, 3.0)

# ── Handlers ───────────────────────────────────────────────────────
func _on_node_pressed(node_data: Dictionary) -> void:
	_selected_node = node_data
	node_name_lbl.text = node_data["name"]
	node_desc_lbl.text = node_data["desc"]

	# Muestra panel con animación
	info_panel.visible   = true
	info_panel.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(info_panel, "modulate:a", 1.0, 0.2)

func _on_enter_node() -> void:
	if _selected_node.is_empty():
		return
	# Pasa el enemy_id al CombatScene
	SceneManager.go_to("combat", {
		"enemy_id"  : _selected_node.get("enemy_id", "goblin"),
		"node_id"   : _selected_node.get("id", ""),
		"node_type" : _selected_node.get("type", "combat"),
	})

func _update_stamina() -> void:
	# Por ahora hardcodeado, luego lo conectas a PlayerData
	stamina_label.text = "Stamina: 5/5"

# ── Desbloqueo de nodo tras victoria ─────────────────────────────
func unlock_node(node_id: String) -> void:
	for node_data in MAP_NODES:
		if node_data["id"] == node_id:
			node_data["unlocked"] = true
			if _node_buttons.has(node_id):
				var btn : Button = _node_buttons[node_id]
				btn.disabled = false
				btn.modulate = NODE_COLORS.get(node_data["type"], Color.WHITE)
			break

# ── Recibe datos al volver del combate ────────────────────────────
func on_scene_data(data: Dictionary) -> void:
	if data.has("victory") and data["victory"]:
		var completed_id : String = data.get("node_id", "")
		# Desbloquea los nodos conectados
		for node_data in MAP_NODES:
			if node_data["id"] == completed_id:
				for connected in node_data["connects"]:
					unlock_node(connected)
				break
