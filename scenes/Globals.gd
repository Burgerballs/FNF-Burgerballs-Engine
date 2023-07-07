extends CanvasLayer
@onready var funnygradient = $funnygradient
@onready var SoundStream = $SoundStream
@onready var BGMStream = $BGMStream
@onready var CreditLabel = $"Panel/Label"
@onready var CreditAnimP = $"Panel/AnimationPlayer"
var curDiff = 'normal'
var curSong = 'test'
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
var song:Song
func switchTo(scenepath):
	get_tree().paused = true
	var animer = funnygradient.find_child("AnimationPlayer") # the animer,,,
	animer.speed_scale = Preferences.getPreference('transitionspd')
	$Loading.visible = true
	animer.play('godown')
	await get_tree().create_timer(animer.get_animation('godown').length).timeout
	get_tree().change_scene_to_file("res://scenes/"+scenepath+'.tscn')
	get_tree().paused = false
	$Loading.visible = false
	animer.play('godowner')
func play_song(songname,diff):
	BGMStream.stop()
	get_tree().paused = true
	song = Song.new()
	song.parse_chart(songname, diff)
	curDiff = diff
	curSong=songname
	var animer = funnygradient.find_child("AnimationPlayer") # the animer,,,
	animer.speed_scale = Preferences.getPreference('transitionspd')
	$Loading.visible = true
	animer.play('godown')
	await get_tree().create_timer(animer.get_animation('godown').length).timeout
	get_tree().change_scene_to_file("res://scenes/playstate/PlayState.tscn")
	get_tree().paused = false
	$Loading.visible = false
	animer.play('godowner')
func playSound(sex):
	SoundStream.stream = load("res://assets/sfx/"+sex+".ogg")
	SoundStream.play()
