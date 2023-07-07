extends Node

#this contains an dictionary of dictionaries of dictionaries, like this
#'song': {
#	"diff": {
#		'score': 5000,
#		'accuracy': 100
#	}
#}
var scoreArray:Dictionary
var scoreFile
func _ready():
	var json:Dictionary = {}
	if not FileAccess.file_exists("user://Highscores.json"):
		scoreFile = FileAccess.open("user://Highscores.json", FileAccess.WRITE)
		scoreFile.store_string('{}')
	scoreFile = FileAccess.open("user://Highscores.json", FileAccess.READ_WRITE)
	json = JSON.parse_string(scoreFile.get_as_text())
	scoreArray = json
func saveData():
	var file = FileAccess.open("user://Highscores.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(scoreArray))
func getHighscore(song,diff):
	var ret
	if !scoreArray.find_key(song):
		ret = {
			"score":0,
			"accuracy":0
		}
	else:
		ret = scoreArray[song][diff]
	return ret
func saveHighscore(song,diff,score,acc):
	scoreArray[song][diff] ={'score':score,'accuracy':acc}
	saveData()
