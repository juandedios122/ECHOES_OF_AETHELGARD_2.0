# GachaSystem.gd — Autoload
extends Node

# ── Rareza ────────────────────────────────────────────────────────
enum Rarity { COMMON, RARE, EPIC, LEGENDARY }

# ── Pool de personajes ────────────────────────────────────────────
# Reemplaza la constante HERO_POOL y agrega esto arriba del todo
var HERO_POOL : Array[HeroData] = []

func _ready() -> void:
	_load_heroes()

func _load_heroes() -> void:
	var dir := DirAccess.open("res://data/heroes/")
	if not dir:
		push_error("Carpeta res://data/heroes/ no existe")
		return
	dir.list_dir_begin()
	var file := dir.get_next()
	while file != "":
		if file.ends_with(".tres"):
			var hero := load("res://data/heroes/" + file) as HeroData
			if hero:
				HERO_POOL.append(hero)
		file = dir.get_next()
	dir.list_dir_end()

# ── Probabilidades base ───────────────────────────────────────────
const RATES := {
	Rarity.COMMON    : 60.0,
	Rarity.RARE      : 25.0,
	Rarity.EPIC      : 12.0,
	Rarity.LEGENDARY :  3.0,
}

# ── Costos ────────────────────────────────────────────────────────
const COST_SINGLE : int = 10
const COST_MULTI  : int = 100   # x10 con descuento

# ── Pity ──────────────────────────────────────────────────────────
const PITY_LEGENDARY : int = 90

# ── Estado (se guarda con PlayerData) ────────────────────────────
var pity_counter : int = 0

# ─────────────────────────────────────────────────────────────────
# API pública
# ─────────────────────────────────────────────────────────────────

# Retorna un Array con 1 resultado
func pull_single() -> Array:
	if not PlayerData.spend_gems(COST_SINGLE):
		return []
	return [_roll()]

# Retorna un Array con 10 resultados
func pull_multi() -> Array:
	if not PlayerData.spend_gems(COST_MULTI):
		return []
	var results := []
	for i in 10:
		results.append(_roll())
	return results

func get_rarity_name(rarity: Rarity) -> String:
	match rarity:
		Rarity.COMMON    : return "Común"
		Rarity.RARE      : return "Raro"
		Rarity.EPIC      : return "Épico"
		Rarity.LEGENDARY : return "Legendario"
	return ""

func get_rarity_color(rarity: Rarity) -> Color:
	match rarity:
		Rarity.COMMON    : return Color("#AAAAAA")
		Rarity.RARE      : return Color("#4CAF50")
		Rarity.EPIC      : return Color("#9C27B0")
		Rarity.LEGENDARY : return Color("#FFD700")
	return Color.WHITE

# ─────────────────────────────────────────────────────────────────
# Lógica interna
# ─────────────────────────────────────────────────────────────────

func _roll() -> HeroData:
	pity_counter += 1
	var rarity := _determine_rarity()
	if rarity == 3:  # LEGENDARY
		pity_counter = 0
	var hero := _pick_hero_of_rarity(rarity)
	if not PlayerData.all_heroes.has(hero.id):
		PlayerData.all_heroes.append(hero.id)
		PlayerData.save_data()
	return hero


func _determine_rarity() -> Rarity:
	# Pity: si llegó a 90 sin legendario, fuerza legendario
	if pity_counter >= PITY_LEGENDARY:
		return Rarity.LEGENDARY

	var roll := randf() * 100.0
	var accumulated := 0.0
	for rarity in [Rarity.LEGENDARY, Rarity.EPIC, Rarity.RARE, Rarity.COMMON]:
		accumulated += RATES[rarity]
		if roll <= accumulated:
			return rarity
	return Rarity.COMMON

func _pick_hero_of_rarity(rarity: int) -> HeroData:
	var pool := HERO_POOL.filter(func(h): return h.rarity == rarity)
	if pool.is_empty():
		return HERO_POOL[0]
	return pool[randi() % pool.size()]
