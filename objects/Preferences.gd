extends Node
var defaultSave:Dictionary = {
	"downscroll": false,
	"offset": 0,
	"controls": {
		"left": 'left'
	}
}
var playerSave:Dictionary = {}
var playerSaveFile
var jsonInstance:JSON = JSON.new() # WHYYYYYYYY
func _ready():
	if FileAccess.file_exists("user://Preferences.json"):
		playerSaveFile = FileAccess.open("user://Preferences.json", FileAccess.READ)
		playerSave = JSON.parse_string(playerSaveFile.get_as_text())
	else:
		playerSave = defaultSave
		saveData()
func saveData():
	var file = FileAccess.open("user://Preferences.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(playerSave))
func getPreference(string): return playerSave[string]
func setPreference(str, thing): playerSave[str] = thing
