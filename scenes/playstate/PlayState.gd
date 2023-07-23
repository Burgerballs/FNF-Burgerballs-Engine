extends Node2D

@onready var playerStrums = $"CamHUD/BFStrums"
@onready var dadStrums = $"CamHUD/DadStrums"
@onready var Inst = $InstStream
@onready var Voices = $VoiceStream
@onready var noteGroup = $"CamHUD/NoteGroup"
@onready var SongProgress = $"CamHUD/TimeDisplay/SongProgress"
@onready var HealthBar = $"CamHUD/HealthBar/HealthBarBar (lol)"
@onready var boyfriend = $"BF"
@onready var dad = $"DAD"
@onready var gf = $"GF"
@onready var sound = $"/root/Globals/SoundStream"
@onready var ratingSpr = $"CamHUD/RatingSpr"
var SONG = Song.new();
var difficulty = 'Normal'
var speed = 1.0
var curSong:String
var camFollow:Vector2
var defaultCamZoom = 1.0
var camZooming = true
var songNoteData:Array
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
var gfSpeed = 2
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
	"stage" = preload('res://scenes/playstate/stages/Default.tscn'),
	'offset' = preload('res://scenes/playstate/stages/Offset.tscn')
}
var Stage
var events
var pauseMenu = preload("res://scenes/playstate/PauseMenu.tscn")
var gameOver = preload("res://scenes/playstate/GameOverScreen.tscn")

signal noteHit(note:Note)
signal songEnd()

func _ready():
	Conductor.songPos = 0
	Conductor.songPos -= Conductor.crotchet*5
	SONG = Globals.song
	events = Globals.song.events
	Conductor.bpm = SONG.bpm
	Conductor.connect("beatHit", beatHit)
	generateSong()
	Stage = findStage(SONG.stage).instantiate()
	add_child(Stage)
	defaultCamZoom = Stage.defaultCamZoom
	Stage.z_index = -3
	playerStrums.playing = true
	boyfriend.position = Stage.bfPos.position
	dad.position = Stage.dadPos.position
	gf.position = Stage.gfPos.position
	boyfriend._loadChar(SONG.player_1, true)
	dad._loadChar(SONG.player_2)
	gf._loadChar('gf')
	if dad.charName == gf.charName:
		dad.position = gf.position
		gf.visible = false
	doThing(curSong)
	ratingSpr.modulate.a = 0
	Icons.find_child('BFIcon').texture = load("res://assets/images/characters/"+boyfriend.charName+'/icon.png')
	Icons.find_child('DADIcon').texture = load("res://assets/images/characters/"+dad.charName+'/icon.png')
	if Preferences.getPreference('downscroll'):
		playerStrums.position.y = 620
		dadStrums.position.y = 620
	Inst.connect('finished', endSong)
	funnyAss(dadStrums)
	funnyAss(playerStrums)
	playerStrums.position.x = 470 if Preferences.getPreference('middlescroll') else 800
	$"CamHUD/TimeDisplay".position.x+=350 if Preferences.getPreference('middlescroll') else 0
	dadStrums.scale = Vector2(0.5,0.5) if Preferences.getPreference('middlescroll') else Vector2.ONE
func endSong():
	songEnd.emit()
	Highscore.saveHighscore(Globals.curSong, Globals.curDiff, score, snapped(accuracy*100, 0.1))
	Globals.fromPlaystate()
func findStage(a):
	match a:
		'offset':
			return stages['offset']
		_:
			return stages['stage']
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
			match countDownAmnt:
				3:
					var obj3:Sprite2D = Sprite2D.new()
					obj3.texture = load("res://assets/images/countdown/"+countDownThings2[countDownAmnt]+".png")
					obj3.position = Vector2(640,360)
					$CamHUD.add_child(obj3)
					var tween3 = create_tween()
					tween3.tween_property(obj3, "modulate", Color.TRANSPARENT, Conductor.crotchet/1000)
					tween3.connect('finished', func(): obj3.queue_free())
					beatHit(-5)
				2:
					var obj2:Sprite2D = Sprite2D.new()
					obj2.texture = load("res://assets/images/countdown/"+countDownThings2[countDownAmnt]+".png")
					obj2.position = Vector2(640,360)
					$CamHUD.add_child(obj2)
					var tween2 = create_tween()
					tween2.tween_property(obj2, "modulate", Color.TRANSPARENT, Conductor.crotchet/1000)
					tween2.connect('finished', func(): obj2.queue_free())
					beatHit(-4)
				1:
					beatHit(-3)
				0:
					beatHit(-2)
					var obj1:Sprite2D = Sprite2D.new()
					obj1.texture = load("res://assets/images/countdown/"+countDownThings2[countDownAmnt]+".png")
					obj1.position = Vector2(640,360)
					$CamHUD.add_child(obj1)
					var tween1 = create_tween()
					tween1.tween_property(obj1, "modulate", Color.TRANSPARENT, Conductor.crotchet/1000)
					tween1.connect('finished', func(): obj1.queue_free())
		else:
			beatHit(-1)
			countDownTimer.stop()
			startSong()
	)
	
func songSpdChange():
	Inst.pitch_scale = Preferences.getPreference('songspd')
	Voices.pitch_scale = Preferences.getPreference('songspd')
func startSong():
	Conductor.playMusic('songs/' + str(curSong).to_lower().replace(' ', '-') + '/Inst', Inst)
	if SONG.needsVoices:
		Conductor.playMusic('songs/' + str(curSong).to_lower().replace(' ', '-') + '/Voices', Voices)
	Conductor.linkStream(Inst)
	startedSong = true
	songSpdChange()
	var tween1 = create_tween()
	tween1.tween_property($'CamHUD/TimeDisplay', "modulate", Color.WHITE, Conductor.crotchet/1000)
	Globals.creditShow(curSong.to_lower().replace(' ', '-'))
	
func funnyAss(ssdsdsddsds):
	var tween1 = create_tween()
	tween1.tween_property(ssdsdsddsds, "modulate", Color.WHITE, Conductor.crotchet/1000)
var camSpeed = 1
func scoreString():
	var ret = ''
	match(Preferences.getPreference('SDT')):
		'Standard':
			if !(totalLooseHits == 0):
				var curRating = findRating(accuracy*100)
				ret = 'Score: ' + str(int(score)) + ' // Accuracy: ' + str(snapped(accuracy*100, 0.1)) + '% ['+curRating+'] // Combo Breaks: ' + str(misses)
			else:
				ret = 'Score: ' + str(int(score))  + ' // Combo Breaks: ' + str(misses)
		'Simplified':
			ret = 'Score: ' + str(int(score)) + " // Combo Breaks: " + str(misses)
		'Score Only':
			ret = 'Score: ' + str(int(score))
	return ret
@onready var Icons = $"CamHUD/HealthBar/Icons"
func _process(delta):
	accuracy = (totalLooseHits / totalHitNotes)
	$"CamHUD/ScoreTxt".text = scoreString()
	
	if health > 2.02:
		health = 2
	elif health <= 0:
		kill()
		health = 0
		
	Icons.position.x = (-health+2) * (HealthBar.size.x / 2) + HealthBar.position.x
	
	HealthBar.value = -health + 2
	
	if (-health+2)*50 <= 20:
		Icons.find_child("BFIcon").find_child("AnimationPlayer").play('live')
		Icons.find_child("DADIcon").find_child("AnimationPlayer").play('kill')
	elif (-health+2)*50 >= 80:
		Icons.find_child("DADIcon").find_child("AnimationPlayer").play('live')
		Icons.find_child("BFIcon").find_child("AnimationPlayer").play('kill')
	else:
		Icons.find_child("DADIcon").find_child("AnimationPlayer").play('live')
		Icons.find_child("BFIcon").find_child("AnimationPlayer").play('live')
		
	
	for note in noteGroup.get_children():
		if note.tooLate && note.mustHit && !note.canBeHit:
			miss(note)
	if startedSong:
		for i in events.size():
			if events[i].strumTime <= Conductor.songPos + Preferences.getPreference('offset') + AudioServer.get_output_latency() && events[i].active:
				doEvent(events[i].eventName,events[i].param1,events[i].param2)
				events[i].active = false
		if not floor(Conductor.curStep/16) >= SONG.notes.size():
			isCurSecBF = SONG.notes[floor(Conductor.curStep/16)].mustHitSection
		var length = ((Inst.stream.packet_sequence.get_length()) - Conductor.songPos/1000)
		SongProgress.value = (-(length) / Inst.stream.packet_sequence.get_length() + 1) * 100
		$"CamHUD/TimeDisplay".text = convertToTimeString(length) + ' / ' + convertToTimeString(-(length) + Inst.stream.packet_sequence.get_length())
	else:
		Conductor.songPos += delta*1000
		isCurSecBF = SONG.notes[0].mustHitSection
	moveCam()
	positionHud()
	if Input.is_action_just_pressed('uienter'):
		pause()
	if Input.is_action_just_pressed('reset'):
		kill()
func doEvent(ename,p1,p2):
	match ename:
		'Hey!':
			if int(p1) == 0:
				boyfriend._playAnim('hey',true)
			elif int(p1)==3:
				gf._playAnim('cheer',true)
			else:
				boyfriend._playAnim('hey',true)
				gf._playAnim('cheer',true)
		'Set GF Speed':
			gfSpeed = int(p1)
			print(gfSpeed,'is gfspeed!')
		'Add Camera Zoom':
			$Camera2D.zoom += Vector2(0.015,0.015) if p1 == '' else Vector2(float(p1),float(p1))
			$CamHUD.scale += Vector2(0.03,0.03) if p2 == '' else Vector2(float(p2),float(p2))
func pause():
	var mnu = pauseMenu.instantiate()
	self.add_child(mnu)
func positionHud():
	$CamHUD.offset = ($CamHUD.scale - Vector2(1.0,1.0)) * -(Vector2(1280,720)/Vector2(2.0,2.0))
func moveCam():
	if isCurSecBF:
		camFollow = boyfriend.position + Vector2(-100,-100) + boyfriend.get_midpoint() + boyfriend.cameraPos
	else:
		camFollow = dad.position + Vector2(150,-100) + dad.get_midpoint() + dad.cameraPos
	
func kill():
	BunchoFucko.deathCharPos = boyfriend.position
	BunchoFucko.deathCameraPos = $Camera2D.position
	BunchoFucko.deathZoom = $Camera2D.zoom
	get_tree().change_scene_to_packed(gameOver)

func findRating(acc):
	for i in ratingList.size():
		if ratingList[i][1] <= acc:
			return ratingList[i][0]
			break
func convertToTimeString(time):
	var minutes = floor(time / 60 / Preferences.getPreference('songspd'))
	var seconds = int(time / Preferences.getPreference('songspd')) % 60
	if seconds > 9:
		return str(minutes) + ':' + str(seconds)
	else:
		return str(minutes) + ':0' + str(seconds)
	
func miss(note):
	misses = misses + 1 # it is always doubling for some reason
	note.queue_free()
	totalHitNotes += 1
	score -= 150 + (150*(note.holdLength / Conductor.stepCrotchet)) * Preferences.get_modifier_mult()
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
		
func processNotes():
	for notes in songNoteData:
		var prevNote:Note
		if notes.StrumTime > Conductor.songPos + (2500/(speed)):
			if songNoteData.find(notes) == 0:
				prevNote = null
			var NoteDir = notes.NoteDir
			var StrumTime = notes.StrumTime + Preferences.getPreference('offset') + AudioServer.get_output_latency()
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
			songNoteData.erase(notes)
func cameraMove(d):
	var lerpVal:float = CoolUtil.boundTo(d * 2.4 * camSpeed, 0, 1)
	if camZooming:
		$Camera2D.zoom = lerp($Camera2D.zoom, Vector2(defaultCamZoom,defaultCamZoom), lerpVal)
		$CamHUD.scale = lerp($CamHUD.scale, Vector2.ONE, lerpVal)
	$Camera2D.position = Vector2(lerp($Camera2D.position.x, camFollow.x, lerpVal), lerp($Camera2D.position.y, camFollow.y, lerpVal))
func _physics_process(delta):
	call_deferred_thread_group('processNotes')
	call_deferred_thread_group('cameraMove', delta)

func generateSong():
	speed = SONG.speed * Preferences.getPreference('scrollspd') / Preferences.getPreference('songspd')
	for sec in SONG.notes:
		var prevNote:Note
		for notes in sec.notes:
			songNoteData.append(notes)
		curSong = SONG.songName
		$"CamHUD/TimeDisplay/SongDisplay".text = SONG.songName.to_upper() + '\n[' + difficulty.to_upper() + ']'
		$"CamHUD/ScoreTxt/Label".text = str(Preferences.getPreference('songspd'))+'x Speed / '+str(Preferences.getPreference('msdmg'))+'x Miss Damage / '+str(Preferences.getPreference('hthp'))+'x Note Hit Health / '+str(Preferences.get_modifier_mult())+'x Score Multiplier'

var camBumping = false
func beatHit(cr):
	if SONG.needsVoices:
		syncSong()
	if camBumping and cr % 4 == 0:
		$Camera2D.zoom += Vector2(0.015,0.015)
		$CamHUD.scale += Vector2(0.03,0.03)
	if cr % 2 == 0:
		dad._dance()
		boyfriend._dance()
	if cr % gfSpeed == 0:
		gf._dance(true)
	Icons.scale = Vector2(1.1,1.1)
	var tween1 = create_tween()
	tween1.tween_property(Icons, "scale", Vector2(1,1), Conductor.crotchet/6000)
	

func syncSong():
	if (Inst != null):
		if ((Inst.get_playback_position() - Voices.get_playback_position()) * 1000) >= 20:
			Voices.seek(Inst.get_playback_position())
func opponentNote(note):
	if !camBumping:
		camBumping = true
	pass
func goodNoteHit(note):
	if !note.wasGoodHit:
		var diff = absf(Conductor.songPos - note.pos) / Preferences.getPreference('songspd')
		noteHit.emit(note)
		totalHitNotes += 1.0
		$"CamHUD/ScoreTxt".find_child("AnimationPlayer").stop()
		$"CamHUD/ScoreTxt".find_child("AnimationPlayer").play('boing')
		resolveRatings(diff)
		health += 0.08
		note.wasGoodHit = true
		Voices.volume_db = 0
		combo+=1
@onready var ComboShits = $"CamHUD/RatingSpr/ComboShits"
@onready var DiffLabel = $"CamHUD/RatingSpr/Label"
@onready var wtffff = [ComboShits.find_child('c1000'),ComboShits.find_child('c100'),ComboShits.find_child('c10'),ComboShits.find_child('c1')]
func resolveRatings(diff):
	for i in judgements:
		if i.accNeed >= diff:
			totalLooseHits += i.accWorth
			score += i.scoreGiven * Preferences.get_modifier_mult()
			dispCombo(i, diff)
			break
			
func dispCombo(e_ = null, diff_=null):
	if e_:
		ratingSpr.self_modulate.a = 1
		ratingSpr.texture = load("res://assets/images/ratings/" + e_.name.to_lower() + '.png')
	else:
		ratingSpr.self_modulate.a = 0
	ratingSpr.find_child("AnimationPlayer").stop()
	ratingSpr.find_child("AnimationPlayer").play('Show')
	for i in wtffff.size():
		wtffff[i].texture = load("res://assets/images/combo/num" + str(int(combo / pow(10,i)) % 10) + '.png')
		if combo == 0:
			wtffff[i].modulate = Color("be0027")
		else:
			wtffff[i].modulate = Color("ffffff")
	if diff_:
		DiffLabel.visible = true
		DiffLabel.text = str(floor(diff_)) + 'ms'
	else:
		DiffLabel.visible = false
	
func key_from_event(event):
	#from swordcube's nova engine !
	var data:int = -1
	for i in playerStrums.controls.size():
		if event.is_action_pressed(playerStrums.controls[i]) or event.is_action_released(playerStrums.controls[i]) && event == InputEventKey:
			data = i
			break
	return data
var curKeyEvent:InputEventKey
var pressed:Array[bool] = [false,false,false,false]
func _input(key_event):
	var data:int = key_from_event(key_event)
	var notesStopped:bool = false
	if key_event == InputEventKey:
		curKeyEvent = key_event
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
