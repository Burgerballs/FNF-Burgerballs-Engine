extends AnimatedSprite2D
class_name Receptor
@onready var strumLine = $"../"
@onready var notedir = str(get_indexed('metadata/direction'))
func _ready():
	playAnim('static')
func playAnim(a):
	match(a):
		'press':
			play(notedir.to_lower() + ' press')
		'confirm':
			play(notedir.to_lower() + ' confirm')
		'static':
			play('arrow' + notedir.to_upper())


func _on_animation_finished():
	if !strumLine.playing:
		playAnim("static")
