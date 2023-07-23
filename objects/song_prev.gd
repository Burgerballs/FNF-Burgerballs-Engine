extends Panel
@onready var prev = $'../'
@onready var noteGroup = $"SongPrevNoteGroup"
@onready var Inst = $InstStream
@onready var Voices = $VoiceStream
var speed = 1.0
var SONG:Song
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
var curSong:String = ''
var startedSong:bool = false
func generateSong():
	var startAt = 0
	Inst.stop()
	Voices.stop()
	for i in range(noteGroup.get_child_count()-1,-1,-1):
		var note:Note = noteGroup.get_child(i)
		note.queue_free()
	SONG = prev.songCheck
	curSong = SONG.songName
	speed = SONG.speed * Preferences.getPreference('scrollspd')
	for sec in SONG.notes:
		var prevNote:Note
		for notes in sec.notes:
			var NoteDir = notes.NoteDir
			var StrumTime = notes.StrumTime + Preferences.getPreference('offset') + AudioServer.get_output_latency()
			var PlayedByBf = notes.playedByBf
			var suslength = notes.susLength
			if sec.notes.find(notes) == 0 && SONG.notes.find(sec) == 0:
				prevNote = null
			if PlayedByBf:
				var newNote:Note = Note.new(StrumTime,NoteDir,false)
				newNote.holdLength = suslength
				newNote.game = self
				newNote.isOnGame = false
				newNote.reloadSprites()
				newNote.strumLine = $Strumline
				noteGroup.add_child(newNote)
				prevNote = newNote
	Globals.BGMStream.stop()
	startAt = noteGroup.get_child(0).pos
	Conductor.songPos = 0
	Inst.seek(startAt/1000)
	Voices.seek(startAt/1000)
	Conductor.playMusic('songs/' + str(curSong.to_lower().replace(' ', '-')).to_lower().replace(' ', '-') + '/Inst',Inst,false,false,startAt/1000)
	if SONG.needsVoices:
		Conductor.playMusic('songs/' + str(curSong.to_lower().replace(' ', '-')).to_lower().replace(' ', '-') + '/Voices',Voices,false,false,startAt/1000)
	Conductor.linkStream(Inst)
	if !Preferences.getPreference('downscroll'): $StrumLine.position.y = 40
var downscroll_mult:int = -1
func _process(delta:float) -> void:
	downscroll_mult = (1 if !Preferences.getPreference('downscroll') else -1)
	for i in range(noteGroup.get_child_count()-1,-1,-1):
		var note:Note = noteGroup.get_child(i)
		var strum_pos:Vector2 = note.strumLine.get_child(note.dir).global_position
		if !note.wasGoodHit:
				note.global_position.y = strum_pos.y - ((0.45 * downscroll_mult) * (Conductor.songPos - note.pos) * (speed * note.strumLine.scale.y))
				note.global_position.x = strum_pos.x
				note.scale = Vector2.ONE * note.strumLine.scale
