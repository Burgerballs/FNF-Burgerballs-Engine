extends Node
class_name WeekParser

# what this does is turn psych engine formatted weeks into data that is useful to the game's Freeplay/Story Menu
class Week:
	var songs:Array
	var weekCharacters:Array
	var weekBefore:String
	var difficulties:String

var loadedWeeks:Dictionary
var weekList:Array[String]

var weekdir = 'res://assets/weeks/'
func burgerBITCH():
	for i in CoolUtil.listDirs(weekdir):
		var week = Week.new()
		var file = FileAccess.open(weekdir + i + '/week.json', FileAccess.READ)
		var content = JSON.parse_string(file.get_as_text())
		week.songs = content['songs']
		week.weekBefore = content['weekBefore']
		weekList.append(i)
		loadedWeeks.merge({i: week})
