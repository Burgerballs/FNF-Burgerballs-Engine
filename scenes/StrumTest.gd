extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Strumline2.playing = true
	
func _input(event):
	if Input.is_key_pressed(KEY_Z):
		get_tree().change_scene_to_file("res://scenes/playstate/PlayState.tscn")
