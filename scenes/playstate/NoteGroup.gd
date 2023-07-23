extends Node2D
class_name NoteGroup
var downscroll_mult:int = -1
@onready var game = $"../../"
@onready var scroll_speed:float
func _init():
	downscroll_mult = (1 if !Preferences.getPreference('downscroll') else -1)
func _process(delta:float) -> void:
	scroll_speed = game.speed
	
	for i in get_children():
		var note:Note = i
		var strum_pos:Vector2 = note.thisStrum.global_position
		note.position.y = strum_pos.y - ((0.45 * downscroll_mult) * (Conductor.songPos - note.pos) * (scroll_speed * note.strumLine.scale.y))
		note.position.x = strum_pos.x
		note.scale = Vector2.ONE * note.strumLine.scale
