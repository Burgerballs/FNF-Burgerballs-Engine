extends CanvasLayer
@onready var funnygradient = $funnygradient
@onready var SoundStream = $SoundStream
@onready var BGMStream = $BGMStream
@onready var CreditLabel = $"Panel/Label"
@onready var CreditAnimP = $"Panel/AnimationPlayer"
func _ready():
	Conductor.connect('songLoaded', creditShow)
func creditShow(song):
	CreditLabel.text = song.capitalize() + '\nBy ' + findArtist(song)
	CreditAnimP.play("show")
var songArtist = [
	['peebutter', 'Kawai Sprite']
]
func findArtist(song):
	var ret = 'idk'
	for i in songArtist.size():
		if songArtist[i][0] == song:
			ret = songArtist[i][1]
	return ret

func switchTo(scenepath):
	funnygradient.find_child("AnimationPlayer").play('godown')
	funnygradient.find_child("AnimationPlayer").connect("animation_finished", func(animnam):
		if animnam == 'godown':
			get_tree().change_scene_to_file("res://scenes/"+scenepath+'.tscn')
			funnygradient.find_child("AnimationPlayer").play('godowner'))
func playSound(sex):
	SoundStream.stream = load("res://assets/sfx/"+sex+".ogg")
	SoundStream.play()
