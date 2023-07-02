extends Node
var defaultSave:Dictionary = {
	"downscroll": false,
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
		playerSave = JSON.parse_string(playerSaveFile.get_as_text()).result
func saveData():
	pass
