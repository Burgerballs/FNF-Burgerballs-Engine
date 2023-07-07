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
	get_tree().paused = true
	var animer = funnygradient.find_child("AnimationPlayer") # the animer,,,
	animer.speed_scale = Preferences.getPreference('transitionspd')
	animer.play('godown')
	await get_tree().create_timer(animer.get_animation('godown').length).timeout
	get_tree().change_scene_to_file("res://scenes/"+scenepath+'.tscn')
	get_tree().paused = false
	animer.play('godowner')
func playSound(sex):
	SoundStream.stream = load("res://assets/sfx/"+sex+".ogg")
	SoundStream.play()
