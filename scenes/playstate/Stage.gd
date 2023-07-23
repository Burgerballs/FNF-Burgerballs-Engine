extends Node2D
class_name Stage

@onready var game = $'../'
@onready var gf = game.gf
@onready var dad = game.dad
@onready var boyfriend = game.boyfriend
@export var bfPos:Node2D
@export var dadPos:Node2D
@export var gfPos:Node2D
@export var defaultCamZoom:float = 1
