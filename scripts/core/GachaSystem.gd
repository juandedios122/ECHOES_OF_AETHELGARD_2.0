# GachaSystem.gd — Autoload
extends Node

# ── Rareza ────────────────────────────────────────────────────────
enum Rarity { COMMON, RARE, EPIC, LEGENDARY }

# ── Pool de personajes ────────────────────────────────────────────
const HERO_POOL := [
	{
		"id"     : "knight",
		"name"   : "Sir Aldric",
		"rarity" : Rarity.COMMON,
		"desc"   : "Caballero leal del reino",
		"atk"    : 120,
		"hp"     : 800,
		"color"  : Color("#7A8C99"),  # gris acero
	},
	{
		"id"     : "archer",
		"name"   : "Lyria Voss",
		"rarity" : Rarity.RARE,
		"desc"   : "Arquera élfica de los bosques",
		"atk"    : 180,
		"hp"     : 600,
		"color"  : Color("#4CAF50"),  # verde
	},
	{
		"id"     : "mage",
		"name"   : "Zephyr Ashcroft",
		"rarity" : Rarity.EPIC,
		"desc"   : "Mago del fuego antiguo",
		"atk"    : 260,
		"hp"     : 450,
		"color"  : Color("#9C27B0"),  # púrpura
	},
	{
		"id"     : "dragon",
		"name"   : "Vaelthorn",
		"rarity" : Rarity.LEGENDARY,
		"desc"   : "El último dragón de Aethelgard",
		"atk"    : 420,
		"hp"     : 1200,
		"color"  : Color("#FFD700"),  # dorado
	},
]

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

func _roll() -> Dictionary:
	pity_counter += 1
	var rarity := _determine_rarity()
	pity_counter = 0 if rarity == Rarity.LEGENDARY else pity_counter
	var hero := _pick_hero_of_rarity(rarity)
	# Agrega al inventario del jugador
	if not PlayerData.all_heroes.has(hero["id"]):
		PlayerData.all_heroes.append(hero["id"])
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

func _pick_hero_of_rarity(rarity: Rarity) -> Dictionary:
	var pool := HERO_POOL.filter(func(h): return h["rarity"] == rarity)
	if pool.is_empty():
		return HERO_POOL[0]
	return pool[randi() % pool.size()]
