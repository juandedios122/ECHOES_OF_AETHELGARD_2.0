# PlayerData.gd — Autoload
# Registrar en: Project > Project Settings > Autoload
# Nombre: PlayerData
extends Node

# ── Datos del jugador ──────────────────────────────────────────────
var player_name : String = "Viajero"
var level       : int    = 1
var experience  : int    = 0
var gold        : int    = 500
var gems        : int    = 50

# ── Héroes y progresión ───────────────────────────────────────────
var active_heroes : Array = []
var all_heroes    : Array = []

# ── Persistencia simple (sin servidor) ───────────────────────────
const SAVE_PATH := "user://playerdata.cfg"

func _ready() -> void:
	load_data()

func save_data() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("player", "name",       player_name)
	cfg.set_value("player", "level",      level)
	cfg.set_value("player", "experience", experience)
	cfg.set_value("player", "gold",       gold)
	cfg.set_value("player", "gems",       gems)
	cfg.set_value("player", "all_heroes", all_heroes)  # ← agrega esta
	cfg.save(SAVE_PATH)

func load_data() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	player_name = cfg.get_value("player", "name",       player_name)
	level       = cfg.get_value("player", "level",      level)
	experience  = cfg.get_value("player", "experience", experience)
	gold        = cfg.get_value("player", "gold",       gold)
	gems        = cfg.get_value("player", "gems",       gems)
	all_heroes  = cfg.get_value("player", "all_heroes", all_heroes)  # ← agrega esta
func add_gold(amount: int) -> void:
	gold += amount
	save_data()

func spend_gold(amount: int) -> bool:
	if gold < amount:
		return false
	gold -= amount
	save_data()
	return true

func add_gems(amount: int) -> void:
	gems += amount
	save_data()

func spend_gems(amount: int) -> bool:
	if gems < amount:
		return false
	gems -= amount
	save_data()
	return true
	
	
	
