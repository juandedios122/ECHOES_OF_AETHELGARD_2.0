# HeroData.gd — Recurso de héroe
# NO es Autoload, es una clase de dato
class_name HeroData
extends Resource

@export var id        : String = ""
@export var hero_name : String = ""
@export var rarity    : int    = 0   # 0=común 1=raro 2=épico 3=legendario
@export var desc      : String = ""
@export var atk       : int    = 100
@export var hp        : int    = 500
@export var color     : Color  = Color.WHITE
@export var sprite    : Texture2D = null  # para cuando tengas sprites
