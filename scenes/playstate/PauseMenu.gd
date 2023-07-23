extends CanvasLayer

var curSel = 0
@onready var textArray = $Alphabets.get_children()
func _ready():
	get_tree().paused = true
	$Label/AnimationPlayer.play('animgoin')
	Conductor.playMusic('music/breakfast',Globals.BGMStream,true)
	Globals.BGMStream.volume_db = -15
	for i in textArray:
		if i.text == 'OPTIONS MENU' && Globals.fromWhere == 'options':
			$Alphabets.remove_child(i)
			textArray.remove_at(textArray.find(i))
			i.free()
	changeSel(0)
	$Panel.modulate.a = 0
	var tweenr = create_tween()
	tweenr.set_ease(Tween.EASE_OUT)
	tweenr.set_trans(Tween.TRANS_QUAD)
	tweenr.tween_property($Panel, "modulate:a", 1, 0.3)
	$Label.text = Globals.song.songName.to_upper()+'\n'+Globals.song.diff
	
var optionsState = preload("res://scenes/OptionsMenu.tscn")

func changeSel(fucker):
	curSel += fucker
	if curSel > textArray.size()-1:
		curSel = 0
	elif curSel < 0:
		curSel = textArray.size()-1
	for i in textArray.size():
		var alphabet = textArray[i]
		if i == curSel:
			alphabet.modulate.a = 1
		else:
			alphabet.modulate.a = 0.6
		alphabet.target_y = i - curSel
		
func _process(delta):
	if Input.is_action_just_pressed('uiup'):
		changeSel(-1)
	elif Input.is_action_just_pressed('uidown'):
		changeSel(1)
	elif Input.is_action_just_pressed('uienter'):
		match (textArray[curSel].name):
			'continue': 
				Globals.BGMStream.stop()
				Globals.BGMStream.volume_db = 0
				get_tree().paused = false
				self.queue_free()
			'restart':
				Globals.play_song(Globals.song.songName.to_lower().replace(' ','-'), Globals.song.diff)
			'options':
				var OptionsThing = optionsState.instantiate()
				OptionsThing.isNotMenu = true
				OptionsThing.thing = true
				add_child(OptionsThing)
				self.process_mode = 0
			'exit':
				Globals.fromPlaystate()
	elif Input.is_action_just_pressed('uiback'):
		Globals.BGMStream.stop()
		Globals.BGMStream.volume_db = 0
		get_tree().paused = false
		self.queue_free()
