extends Node2D
class_name Song
class SongEvent:
	var strumTime:float
	var eventName:String
	var param1:String
	var param2:String
	var active:bool = true
	func _init(strumTimee,eventNamee,param11,param22):
		strumTime = strumTimee
		eventName = eventNamee
		param1 = param11
		param2 = param22
var events:Array[SongEvent]
var songName:String = 'test'
var bpm:float = 100
var speed:float = 1.0
var notes:Array[Section]
var player_2:String
var player_1:String
var needsVoices:bool = true
var diff = 'NORMAl'
var stage = 'stage'

func parse_chart(song,diff):
	var filePath = "res://assets/songs/"+song+'/'+song
	var eventsPath = "res://assets/songs/"+song+'/events.json'
	if diff.to_upper() != 'NORMAL':
		filePath += '-' + diff.to_lower() + '.json'
	else:
		filePath += '.json'
	self.diff = diff
	var file = FileAccess.open(filePath, FileAccess.READ)
	var content = JSON.parse_string(file.get_as_text()).song
	var shit:Dictionary = {}
	if FileAccess.file_exists(eventsPath):
		shit = JSON.parse_string(FileAccess.open(eventsPath, FileAccess.READ).get_as_text()).song
	songName = content['song']
	needsVoices = content['needsVoices']
	bpm = content['bpm']
	speed = content['speed']
	player_2 = content['player2']
	player_1 = content['player1']
	if content.has('stage'):
		stage = content['stage']
	if content.has('events'):
		for event in content["events"]:
			for i in event[1].size():
				var newEventNote = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]]
				events.push_back(SongEvent.new(newEventNote[0],newEventNote[1],newEventNote[2],newEventNote[3]))
	for i in range(content['notes'].size()):
		var tempSec = Section.new()
		var sectionData = content['notes'][i]
		tempSec.mustHitSection = sectionData['mustHitSection']
		var tempNoteArr:Array[NoteData]
		for a in range(sectionData['sectionNotes'].size()):
			if sectionData['sectionNotes'][a][1] != -1:
				var tempNote = NoteData.new()
				var noteData = sectionData['sectionNotes'][a]
				tempNote.StrumTime = float(noteData[0])
				tempNote.NoteDir = int(noteData[1]) % int(4)
				tempNote.susLength = noteData[2]
				tempNote.playedByBf = sectionData['mustHitSection']
				if noteData[1] > 3: tempNote.playedByBf = !sectionData['mustHitSection']
				tempNoteArr.append(tempNote)
			else:
				var eventData = sectionData['sectionNotes'][a]
				var tempEvent = SongEvent.new(eventData[0],eventData[2],eventData[3],eventData[4])
		tempSec.notes = tempNoteArr
		notes.append(tempSec)
	if shit != {}:
		if shit.has('events'):
			for event in shit["events"]:
				for i in event[1].size():
					var newEventNote = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]]
					events.push_back(SongEvent.new(newEventNote[0],newEventNote[1],newEventNote[2],newEventNote[3]))
		if shit['notes'].size() != 0:
			for i in range(shit['notes'].size()):
				var sectionData = shit['notes'][i]
				for a in range(sectionData['sectionNotes'].size()):
						var eventData = sectionData['sectionNotes'][a]
						if eventData.size() > 3:
							var tempEvent = SongEvent.new(eventData[0],eventData[2],eventData[3],eventData[4])
							events.append(tempEvent)
func sortEvents(a, b):
	return a.strumTime > b.strumTime
