extends Node2D
class_name NoteGroup
var downscroll_mult:int = -1
@onready var game = $"../../"
@onready var scroll_speed:float
func _process(delta:float) -> void:
	scroll_speed = game.speed
	downscroll_mult = (1 if !Preferences.getPreference('downscroll') else -1)
	for i in range(get_child_count()-1,-1,-1):
		var note:Note = get_child(i)
		var strum_pos:Vector2 = note.strumLine.get_child(note.dir).global_position
		if !note.wasGoodHit:
			note.position.y = strum_pos.y - ((0.45 * downscroll_mult) * (Conductor.songPos - note.pos) * scroll_speed)
		note.position.x = strum_pos.x
		var strum:Receptor = note.strumLine.get_child(note.dir)
