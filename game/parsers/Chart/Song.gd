extends Node2D
class_name Song

var songName:String = 'test'
var bpm:float = 100
var speed:float = 1.0
var notes:Array[Section]
var player_2:String
var player_1:String
var needsVoices:bool = true
var diff = 'NORMAl'

func parse_chart(song,diff):
	var filePath = "res://assets/songs/"+song+'/'+song
	if diff != 'NORMAL':
		filePath += '-' + diff.to_lower() + '.json'
	else:
		filePath += '.json'
	self.diff = diff
	var file = FileAccess.open(filePath, FileAccess.READ)
	
	var content = JSON.parse_string(file.get_as_text()).song
	songName = content['song']
	needsVoices = content['needsVoices']
	bpm = content['bpm']
	speed = content['speed']
	player_2 = content['player2']
	player_1 = content['player1']
	for i in range(content['notes'].size()):
		var tempSec = Section.new()
		var sectionData = content['notes'][i]
		tempSec.mustHitSection = sectionData['mustHitSection']
		var tempNoteArr:Array[NoteData]
		for a in range(sectionData['sectionNotes'].size()):
			var tempNote = NoteData.new()
			var noteData = sectionData['sectionNotes'][a]
			tempNote.StrumTime = float(noteData[0])
			tempNote.NoteDir = int(noteData[1]) % int(4)
			tempNote.susLength = noteData[2]
			tempNote.playedByBf = sectionData['mustHitSection']
			if noteData[1] > 3: tempNote.playedByBf = !sectionData['mustHitSection']
			tempNoteArr.append(tempNote)
		tempSec.notes = tempNoteArr
		notes.append(tempSec)
