extends Node
var defaultSave:Dictionary = {
	"downscroll": false,
	"offset": 0,
	"multithreading": false,
	"fps": 60,
	"transitionspd": 1.0,
	'antialiasing': true,
	"controls": {
		"left": 'LEFT',
		'down': 'DOWN',
		'up': 'UP',
		'right': 'RIGHT',
		"uileft": 'LEFT',
		'uidown': 'DOWN',
		'uiup': 'UP',
		'uiright': 'RIGHT',
		'uienter': 'ENTER',
		'uiback': 'ESCAPE'
	},
	'scrollspd':1.0
}
var playerSaveFile
func _ready():
	var json:Dictionary = {}
	
	if not FileAccess.file_exists("user://Preferences.json"):
		playerSaveFile = FileAccess.open("user://Preferences.json", FileAccess.WRITE)
		playerSaveFile.store_string('{}')
	playerSaveFile = FileAccess.open("user://Preferences.json", FileAccess.READ_WRITE)
	json = JSON.parse_string(playerSaveFile.get_as_text())
	for key in defaultSave:
		if key in json:
			defaultSave[key] = json[key]
		else:
			json[key] = defaultSave[key]
			
	for key in defaultSave["controls"]:
		if not (key in json["controls"]):
			json["controls"][key] = defaultSave["controls"][key]
	saveData()
	actUpon()
func set_binds():
	var binds = ['left', 'down', 'up', 'right',
				'uileft', 'uidown', 'uiup', 'uiright',
				'uienter', 'uiback']
	for i in binds:
		Input.set_use_accumulated_input(false)
		var key = InputMap.action_get_events(i)
		var bind = InputEventKey.new()
		bind.set_keycode(OS.find_keycode_from_string(defaultSave["controls"][i].to_lower()))
		InputMap.action_add_event(i, bind)
func actUpon():
	set_binds()
	Engine.max_fps = getPreference("fps")
	get_tree().current_scene.texture_filter = (2 if getPreference('antialiasing') else 1)
	ProjectSettings.set_setting('rendering/driver/threads/threadmodel', 'Multi-Threaded' if getPreference('multithreading') else "single-safe")
func saveData():
	var file = FileAccess.open("user://Preferences.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(defaultSave))
func getPreference(string): return defaultSave[string]
func getControl(string): return defaultSave["controls"][string]
func setControl(string, thing): 
	defaultSave["controls"][string] = thing
	actUpon()
	saveData()
func setPreference(str, thing): 
	defaultSave[str] = thing
	saveData()
