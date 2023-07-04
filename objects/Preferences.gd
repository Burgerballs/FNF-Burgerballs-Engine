extends Node
var defaultSave:Dictionary = {
	"downscroll": false,
	"offset": 0,
	"multithreading": false,
	"fps": 60,
	"controls": {
		"left": 'left'
	}
}
var playerSaveFile
func _ready():
	var json:Dictionary = {}
	
	if not FileAccess.file_exists("user://Preferences.json"):
		playerSaveFile = FileAccess.open("user://Preferences.json", FileAccess.WRITE)
		playerSaveFile.store_string('{}')
	else:
		playerSaveFile = FileAccess.open("user://Preferences.json", FileAccess.READ_WRITE)
		json = JSON.parse_string(playerSaveFile.get_as_text())
		saveData()
	for key in defaultSave:
		if key in json:
			defaultSave[key] = json[key]
		else:
			json[key] = defaultSave[key]
	saveData()
	actUpon()
	
func actUpon():
	Engine.max_fps = getPreference("fps")
	ProjectSettings.set_setting('rendering/driver/threads/threadmodel', 'Multi-Threaded' if getPreference('multithreading') else "single-safe")
func saveData():
	var file = FileAccess.open("user://Preferences.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(defaultSave))
func getPreference(string): return defaultSave[string]
func setPreference(str, thing): 
	defaultSave[str] = thing
	saveData()
