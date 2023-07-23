extends Node2D
class_name StrumLine
@export var controls:Array[String] = ['left', 'down', 'up', 'right']
var playing = false
func _input(event:InputEvent) -> void:
	if event is InputEventKey and playing:
		keyShite()
func keyShite():
	for i in get_child_count():
		if playing && Input.is_action_just_pressed(controls[i]):
			var receptor:Receptor = get_child(i)
			receptor.playAnim("press")
		elif playing && Input.is_action_just_released(controls[i]):
			var receptor:Receptor = get_child(i)
			receptor.playAnim("static")
