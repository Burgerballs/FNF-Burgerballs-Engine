extends Node2D

@onready var playerStrums = $"CamHUD/BFStrums"
@onready var dadStrums = $"CamHUD/DadStrums"
@onready var Inst = $InstStream
@onready var Voices = $VoiceStream
@onready var noteGroup = $"CamHUD/NoteGroup"
@onready var SongProgress = $"CamHUD/SongProgress"
@onready var boyfriend = $"BF"
@onready var dad = $"DAD"
@onready var sound = $"/root/Globals/SoundStream"
var SONG = Song.new();
var difficulty = 'Normal'
var speed = 1.0
var curSong:String
var camFollow:Vector2
class Rating extends Node2D:
	var accWorth = 1.0
	var accNeed = 45.0
	var scoreGiven = 500
	func _init(a = 1.0, b = 45.0, c = 500, d = "sick"):
		accWorth = a
		accNeed = b
		scoreGiven = c
		name = d
var judgements = [Rating.new(), Rating.new(0.7, 55.0, 250, 'good'), Rating.new(0.3, 77.0, 100, 'bad'), Rating.new(0, 130.0, 25, 'shit')]
var accuracy = 1.0
var totalHitNotes = 0.0
var totalLooseHits = 0.0
var score = 0
var misses = 0
var combo = 0
var amnts = {
	"sick": 0,
	"good": 0,
	"bad": 0,
	"shit": 0
}
var health = 1.0
var ratingList = [
	['S++',100],
	['S+',99.75],
	['S',99],
	['S-',98],
	['A',95],
	['B',90],
	['C',85],
	['D',80],
	['E',60],
	['F',50],
	['F-',0]
]
var isCurSecBF:bool = false
var startedSong = false
var stages = {
	"Default" = 'res://scenes/playstate/stages/Default.tscn'
}
var Stage
func _ready():
	SONG.parse_chart('south-erect', difficulty.to_lower())
	Conductor.connect("beatHit", beatHit)
	generateSong()
	Stage = findStage(curSong).instantiate()
	add_child(Stage)
	Stage.z_index = -2
	playerStrums.playing = true
	boyfriend.position = Stage.bfPos.position
	dad.position = Stage.dadPos.position
	boyfriend._loadChar(SONG.player_1, true)
	dad._loadChar(SONG.player_2)
	doThing(curSong)
	Conductor.songPos -= Conductor.crotchet*4
func findStage(a):
	match a:
		_:
			return load(stages['Default'])
func doThing(c):
	match c:
		_:
			doCountDown()
var countDownAmnt = 4
func doCountDown():
	var countDownThings = ['introGo', 'intro1', 'intro2', 'intro3']
	var countDownThings2 = ['go', 'set', 'set', 'ready']
	var countDownTimer:Timer = Timer.new()
	add_child(countDownTimer)
	countDownTimer.start(Conductor.crotchet/1000)
	countDownTimer.connect("timeout", func():
		if countDownAmnt != 0:
			countDownAmnt -= 1
			sound.stream = load("res://assets/sfx/"+countDownThings[countDownAmnt]+".ogg")
			sound.play()
			beatHit(0)
			match countDownAmnt:
				3:
					var obj3:Sprite2D = Sprite2D.new()
					obj3.texture = load("res://assets/images/countdown/"+countDownThings2[countDownAmnt]+".png")
					obj3.position = Vector2(640,360)
					$CamHUD.add_child(obj3)
					var tween3 = create_tween()
					tween3.tween_property(obj3, "modulate", Color.TRANSPARENT, Conductor.crotchet/1000)
					tween3.connect('finished', func(): obj3.queue_free())
				2:
					var obj2:Sprite2D = Sprite2D.new()
					obj2.texture = load("res://assets/images/countdown/"+countDownThings2[countDownAmnt]+".png")
					obj2.position = Vector2(640,360)
					$CamHUD.add_child(obj2)
					var tween2 = create_tween()
					tween2.tween_property(obj2, "modulate", Color.TRANSPARENT, Conductor.crotchet/1000)
					tween2.connect('finished', func(): obj2.queue_free())
				0:
					var obj1:Sprite2D = Sprite2D.new()
					obj1.texture = load("res://assets/images/countdown/"+countDownThings2[countDownAmnt]+".png")
					obj1.position = Vector2(640,360)
					$CamHUD.add_child(obj1)
					var tween1 = create_tween()
					tween1.tween_property(obj1, "modulate", Color.TRANSPARENT, Conductor.crotchet/1000)
					tween1.connect('finished', func(): obj1.queue_free())
		else:
			countDownTimer.stop()
			startSong()
	)
func startSong():
	Conductor.playMusic('songs/' + str(curSong).to_lower().replace(' ', '-') + '/Inst', Inst)
	if FileAccess.file_exists('res://assets/songs/' + str(curSong).to_lower().replace(' ', '-') + '/Voices'):
		Conductor.playMusic('songs/' + str(curSong).to_lower().replace(' ', '-') + '/Voices', Voices)
	Conductor.linkStream(Inst)
	startedSong = true
var camSpeed = 1
func _process(delta):
	accuracy = (totalLooseHits / totalHitNotes)
	if !(totalLooseHits == 0):
		var curRating = findRating(accuracy*100)
		$"CamHUD/ScoreTxt".text = 'Score: ' + str(int(score)) + ' // Accuracy: ' + str(snapped(accuracy*100, 0.1)) + '% ['+curRating+'] // Combo Breaks: ' + str(misses)
	else:
		$"CamHUD/ScoreTxt".text = 'Score: ' + str(int(score))  + ' // Combo Breaks: ' + str(misses)
	
	if health > 2.02:
		health = 2
	elif health <= 0:
		kill()
		health = 0
	$"CamHUD/HealthBar/HealthBarBar (lol)".value = -health + 2
	for note in noteGroup.get_children():
		if note.tooLate && note.mustHit && !note.canBeHit:
			miss(note)
	if startedSong:
		isCurSecBF = SONG.notes[floor(Conductor.curStep/16)].mustHitSection
		var length = ((Inst.stream.packet_sequence.get_length()) - Conductor.songPos/1000)
		SongProgress.value = (-(length) / Inst.stream.packet_sequence.get_length() + 1) * 100
		$"CamHUD/TimeDisplay".text = convertToTimeString(length) + ' / ' + convertToTimeString(-(length) + Inst.stream.packet_sequence.get_length())
	else:
		Conductor.songPos += delta*1000
		isCurSecBF = SONG.notes[0].mustHitSection
	var lerpVal:float = CoolUtil.boundTo(delta * 2.4 * camSpeed, 0, 1)
	$Camera2D.position = Vector2(lerp($Camera2D.position.x, camFollow.x, lerpVal), lerp($Camera2D.position.y, camFollow.y, lerpVal))
	moveCam()
	

func moveCam():
	if isCurSecBF:
		camFollow = boyfriend.position + boyfriend.cameraPos
	else:
		camFollow = dad.position + dad.cameraPos
	
func kill():
	print('KILL HIMMMM')
	pass

func findRating(acc):
	for i in ratingList.size():
		if ratingList[i][1] <= acc:
			return ratingList[i][0]
			break
func convertToTimeString(time):
	var minutes = floor(time / 60)
	var seconds = int(time) % 60
	if seconds > 9:
		return str(minutes) + ':' + str(seconds)
	else:
		return str(minutes) + ':0' + str(seconds)
	
func miss(note):
	misses = misses + 1 # it is always doubling for some reason
	note.queue_free()
	totalHitNotes += 1
	score -= 150 + (150*(note.holdLength / Conductor.stepCrotchet)) 
	health -= 0.04
	Voices.volume_db = -60
	if combo != 0:
		combo = 0
		dispCombo()
	playDirectionAnim(note.dir, 'miss', boyfriend)
var dirNames = ['LEFT', 'DOWN', 'UP', 'RIGHT']
func playDirectionAnim(noteData, suffix, char):
	if suffix != '':
		char._playAnim('sing' + dirNames[noteData] + suffix)
	else:
		char._playAnim('sing' + dirNames[noteData])
func generateSong():
	Conductor.bpm = SONG.bpm
	speed = SONG.speed
	for sec in SONG.notes:
		var prevNote:Note
		for notes in sec.notes:
			if sec.notes.find(notes) == 0 && SONG.notes.find(sec) == 0:
				prevNote = null
			var NoteDir = notes.NoteDir
			var StrumTime = notes.StrumTime
			var PlayedByBf = notes.playedByBf
			var suslength = notes.susLength
			var newNote:Note = Note.new(StrumTime,NoteDir,PlayedByBf)
			newNote.holdLength = suslength
			if newNote.mustHit == false:
				newNote.strumLine = dadStrums
				newNote.char = dad
			else:
				newNote.strumLine = playerStrums
				newNote.char = boyfriend
			newNote.game = self
			newNote.reloadSprites()
			noteGroup.add_child(newNote)
			prevNote = newNote
		curSong = SONG.songName
		$"CamHUD/SongDisplay".text = SONG.songName.to_upper() + '\n[' + difficulty.to_upper() + ']'

func beatHit(cr):
	if SONG.needsVoices:
		syncSong()
	dad._dance()
	boyfriend._dance()

func syncSong():
	if (Inst != null):
		if ((Inst.get_playback_position() - Voices.get_playback_position()) * 1000) >= 20:
			Voices.seek(Inst.get_playback_position())
func opponentNote(note):
	pass
func dispCombo():
	var comboNum = ComboNumbers.new(combo)
func goodNoteHit(note):
	if !note.wasGoodHit:
		var diff = absf(Conductor.songPos - note.pos)
		totalHitNotes += 1.0
		$"CamHUD/ScoreTxt".find_child("AnimationPlayer").stop()
		$"CamHUD/ScoreTxt".find_child("AnimationPlayer").play('boing')
		resolveRatings(diff)
		health += 0.08
		note.wasGoodHit = true
		Voices.volume_db = 0
		combo+=1
		dispCombo()
func resolveRatings(diff):
	for i in judgements:
		if i.accNeed >= diff:
			totalLooseHits += i.accWorth
			score += i.scoreGiven
			print(i.name)
			break
func key_from_event(event):
	#from swordcube's nova engine !
	var data:int = -1
	for i in playerStrums.controls.size():
		if event.is_action_pressed(playerStrums.controls[i]) or event.is_action_released(playerStrums.controls[i]) && event == InputEventKey:
			data = i
			break
	return data
	
var pressed:Array[bool] = [false,false,false,false]
func _input(key_event):
	var data:int = key_from_event(key_event)
	var notesStopped:bool = false
	if data > -1:
		pressed[data] = key_event.is_pressed()

	if data == -1 or not Input.is_action_just_pressed(playerStrums.controls[data]):
		return

	var receptor:Receptor = playerStrums.get_child(data)
	var possible_notes:Array[Note] = []
	var pressNotes:Array[Note] = []
	for note in noteGroup.get_children().filter(func(note):
		return (note.dir == data && !note.tooLate && note.mustHit && note.canBeHit && !note.wasGoodHit)	
	): possible_notes.append(note)
	
	possible_notes.sort_custom(sortHitNotes)
	
	if (possible_notes.size() > 0):
		for epicNote in possible_notes:
			for doubleNote in pressNotes:
				if absf(doubleNote.pos - epicNote.pos) < 1:
					doubleNote._kill()
				else:
					notesStopped = true
			if (!notesStopped):
				goodNoteHit(epicNote)
				pressNotes.append(epicNote)
		
func sortHitNotes(a:Note, b:Note):
	return a.pos < b.pos
