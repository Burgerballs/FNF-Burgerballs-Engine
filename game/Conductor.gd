extends Node
var bpm:float = 100
var crotchet:float = ((60/bpm)*1000)
var stepCrotchet:float = crotchet/4
var songPos:float = 0;
var prevSongPos:float = 0;

var curStep:int
var oldStep:int
var oldBeat:int
var curBeat:int
var safeZoneOffset:float = 10.0 / 60.0 * 1000

signal beatHit(beat:int)
signal stepHit(step:int)

var AttatchedStream:AudioStreamPlayer
func linkStream(stream:AudioStreamPlayer):
	AttatchedStream = stream
func _process(delta):
	if AttatchedStream != null:
		songPos = AttatchedStream.get_playback_position()*1000
		crotchet = ((60/bpm)*1000)
		stepCrotchet = crotchet/4
	oldStep = curStep
	updateStep()
	if oldStep != curStep && curStep > 0: stepHit.emit(curStep)
	if oldBeat != curBeat && curBeat > 0: beatHit.emit(curBeat)

func updateStep():
	curStep = floor(songPos / stepCrotchet)
	curBeat = floor(curStep / 4)
func playMusic(path:String, stream:AudioStreamPlayer):
	path = "res://assets/"+path+".ogg"
	stream.stop()
	stream.stream = load(path)
	stream.stream.loop = false
	stream.play(0.0)
