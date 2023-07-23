extends Node2D

var optionTexts:Array
var optionTexts2:Array
var isNotMenu = false

@onready var options = $"Container/Options"
@onready var optionl = $"Container/OptionL"
@onready var optionsbar = $"Container/VBoxContainer"
@onready var descLabel = $"Container/ColorRect2/Magic"
@onready var descLabelBG = $"Container/ColorRect2"
@onready var keybindlayer = $"KEYBINDLAYER"
@onready var keybindpanel = $"KEYBINDLAYER/Panel/Setting"
var sideBarState = true
var thing

var fuck:Dictionary = {
	'gameplay' = [
		['DOWNSCROLL', 'downscroll', 'bool', 'Notes scroll down if activated.'],
		['MIDDLESCROLL', 'middlescroll', 'bool', 'The player strumline is centered horizontally, and the opponent strumline is scaled down.'],
		['OFFSET', 'offset', 'float', 'Note positions are incremented by the amount given by you. (Positive amounts = later)', [1,-100,100]],
	],
	'graphics' = [
		['FRAMERATE', 'fps', 'float', 'No description given or needed.', [1, 60, 300]],
		['TICKRATE', 'npfps', 'float', 'Notes and other things are processed every tick, the amount of time a tick takes is decided by this option.', [1, 30, 1200]],
		['MULTITHREADED RENDERING', 'multithreading', 'bool'],
		['ANTI-ALIASING', 'antialiasing', 'bool', 'Pixels get smoothed out if this option is set to "True"']
	],
	'preferences' = [
		['SCORE DISPLAY TYPE', 'SDT', 'strchoose', 'The score will be displayed in certain ways depending on your current selection.', ['Standard','Simplified','Score Only']],
		['SCROLL SPEED MULTIPLIER', 'scrollspd', 'float', 'The scroll speed is multiplied by your set number.', [0.1,1,3]],
		['OPPONENT NOTE GLOW', 'oppglow', 'bool', 'If true, the notes belonging to the opponent side shall glow, unlike the vanilla engine.'],
		['TRANSITION SPEED MULTIPLIER', 'transitionspd', 'float', 'The animation that plays when you enter something will be increased in speed depending on the number you set.', [0.25,1,5]]
	],
	'modifiers' = [
		['HIT HEALTH MULTIPLIER', 'hthp', 'float', 'The health given by hitting a note is multiplied by your set number.', [0.1,0,10]],
		['MISS DAMAGE MULTIPLIER', 'msdmg', 'float', 'The damage dealt by missing is multiplied by your set number.', [0.1,0.1,10]],
		['SONG PLAYBACK SPEED MULTIPLIER', 'songspd', 'float', 'The song speed is multiplied by your set number. Nightcore?????', [0.1,1,3]],
	],
	'controls' = [
		['LEFT', 'left', 'control'],
		['DOWN', 'down', 'control'],
		['UP', 'up', 'control'],
		['RIGHT', 'right', 'control'],
		
		['UI LEFT', 'uileft', 'control'],
		['UI RIGHT', 'uiright', 'control'],

		['UI UP', 'uiup', 'control'],
		['UI DOWN', 'uidown', 'control'],
		
		['ACCEPT', 'uienter', 'control'],
		['BACK', 'uiback', 'control'],
		
		['RESET', 'reset', 'control', 'This button is used to kill the player upon being pressed.']
	]
}

func _ready():
	optionTexts = optionsbar.get_children()
	changeSelSideBar(0)
	coolBoxSizeThing(optionsbar)
	$MenuBgBlue.visible = !isNotMenu
	$magenta.visible = !isNotMenu
	if isNotMenu:
		process_mode = 3
		if thing == false:
			get_tree().paused = true
		else:
			$warninglabel.visible = true
	else:
		Conductor.playMusic('music/peebutter', Globals.BGMStream, true, true)

func coolBoxSizeThing(box):
	var thing = $"Container/ColorRect3"
	var boxproperties = [box.global_position, box.size]
	var postween = create_tween()
	postween.set_ease(Tween.EASE_OUT)
	postween.set_trans(Tween.TRANS_QUAD)
	postween.tween_property(thing, 'global_position', boxproperties[0], 0.4)
	var sizeween = create_tween()
	sizeween.set_ease(Tween.EASE_OUT)
	sizeween.set_trans(Tween.TRANS_QUAD)
	sizeween.tween_property(thing, 'size', boxproperties[1], 0.4)
var waitTime = 0
func _process(delta):
	if waitTime <= 0:
		if Input.is_key_pressed(KEY_SHIFT) && Input.is_key_pressed(KEY_F1):
			Preferences.defaultSave = Preferences.defaultSaveRef
			Preferences.saveData()
		if Input.is_action_just_pressed('uiup') && keybindlayer.visible == false:
			if sideBarState:
				changeSelSideBar(-1)
			else:
				changeSel(-1)
		elif Input.is_action_just_pressed('uidown') && keybindlayer.visible == false:
			if sideBarState:
				changeSelSideBar(1)
			else:
				changeSel(1)
		elif Input.is_action_just_pressed('uileft'):
			if !sideBarState && keybindlayer.visible == false:
				modifySetting(-1)
		elif Input.is_action_just_pressed('uiright'):
			if !sideBarState && keybindlayer.visible == false:
				modifySetting(1)
		elif Input.is_action_just_pressed('uienter'):
			if sideBarState && keybindlayer.visible == false:
				sideBarState = false
				curSelOption = 0
				changeSel(0)
				coolBoxSizeThing(options)
				optionl.visible = true
				descLabelBG.visible = true
			elif curOptionSel[2] == 'control' && keybindlayer.visible == false:
				controlTim()
			elif curOptionSel[1] == 'offset' && keybindlayer.visible == false:
				Globals.fromWhere = 'options'
				Globals.play_song('offset', 'normal')
		elif Input.is_action_just_pressed('uiback'):
			if !sideBarState && keybindlayer.visible == false:
				sideBarState = true
				for i in optionTexts2.size():
					optionTexts2[i].modulate.a = 1
					descLabelBG.visible = false
				coolBoxSizeThing(optionsbar)
				optionl.visible = false
			elif sideBarState && keybindlayer.visible == false:
				if !isNotMenu:
					waitTime = 1
					Globals.switchTo('mainmenu/MainMenuState')
				else:
					if thing == true:
						$'../'.process_mode = 3
					else:
						get_tree().paused = false
					queue_free()
	if waitTime > 0:
		waitTime -= delta
func _input(event):
	if keybindlayer.visible == true && event.is_pressed() && event is InputEventKey:
		var key = OS.get_keycode_string(event.keycode)
		if (curOptionSel[1] == 'uienter') or (curOptionSel[1] != 'uienter' && !Input.is_action_just_pressed('uienter')):
			Preferences.setControl(curOptionSel[1], key)
			waitTime = 0.1
			keybindlayer.visible = false
		drawOptionThing()
		Preferences.actUpon()
func controlTim():
	keybindlayer.visible = true
	keybindpanel.text = '> '+Preferences.getControl(curOptionSel[1]).to_upper()+' <'
	pass
func modifySetting(num):
	match curOptionSel[2]:
		"bool":
			Preferences.setPreference(curOptionSel[1], !Preferences.getPreference(curOptionSel[1]))
		"float":
			var prefNum = Preferences.getPreference(curOptionSel[1])
			prefNum += (num * curOptionSel[4][0]*(5 if Input.is_key_pressed(KEY_SHIFT) else 1))
			if prefNum > curOptionSel[4][2]:
				
				prefNum = curOptionSel[4][2]
			elif prefNum < curOptionSel[4][1]:
				prefNum = curOptionSel[4][1]
			
			Preferences.setPreference(curOptionSel[1],prefNum)
		"strchoose":
			var curStr = curStrSel + num
			if curStr > curOptionSel[4].size()-1:
				curStr = 0
			elif curStr < 0:
				curStr = curOptionSel[4].size()-1
			curStrSel = curStr
			Preferences.setPreference(curOptionSel[1],curOptionSel[4][curStr])
	Preferences.actUpon()
	drawOptionThing()
	Preferences.saveData()
	
var curOptionSel
var curSelOption = 0
var curStrSel = 0
func changeSel(fucker):
	curSelOption += fucker
	if curSelOption > optionTexts2.size()-1:
		curSelOption = 0
	elif curSelOption < 0:
		curSelOption = optionTexts2.size()-1
	for i in optionTexts2.size():
		if i == curSelOption && optionTexts2[i] != null:
			optionTexts2[i].modulate.a = 1
			curOptionSel = fuck[optionTexts[curSel].name][curSelOption]
			drawOptionThing()
		elif optionTexts2[i] != null:
			optionTexts2[i].modulate.a = 0.5
			
func drawOptionThing():
	for i in optionl.get_children():
		optionl.remove_child(i)
		i.free()
	if curOptionSel[2] == 'bool':
		var trueLabel = Label.new()
		trueLabel.text = '> '+str(Preferences.getPreference(curOptionSel[1]))+' <'
		trueLabel.label_settings = optionTexts[curSel].label_settings
		trueLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		optionl.add_child(trueLabel)
	if curOptionSel[2] == 'float':
		var trueLabel = Label.new()
		trueLabel.text = '> '+str(Preferences.getPreference(curOptionSel[1]))+getOptionMeasure()+' <'
		trueLabel.label_settings = optionTexts[curSel].label_settings
		trueLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		optionl.add_child(trueLabel)
		if curOptionSel[1] == 'offset':
			var nulabel = Label.new()
			nulabel.text = 'Too lazy to set your own?\nYou are able to make the game set it for you after playing a 50 second song,\nby pressing ACCEPT.'
			nulabel.label_settings = optionTexts[curSel].label_settings.duplicate()
			nulabel.label_settings.font_size = 12
			nulabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			optionl.add_child(nulabel)
	if curOptionSel[2] == 'control':
		var promptLabel = Label.new()
		promptLabel.text = 'PRESS ENTER TO CHANGE BINDS'
		promptLabel.label_settings = optionTexts[curSel].label_settings
		promptLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		optionl.add_child(promptLabel)
		var divLabel = Label.new()
		divLabel.text = ' // '
		divLabel.label_settings = optionTexts[curSel].label_settings
		divLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		optionl.add_child(divLabel)
		var trueLabel = Label.new()
		trueLabel.text = str(Preferences.getControl(curOptionSel[1])).to_upper()
		trueLabel.label_settings = optionTexts[curSel].label_settings
		trueLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		optionl.add_child(trueLabel)
	if curOptionSel[2] == 'strchoose':
		curStrSel = curOptionSel[4].find(Preferences.getPreference(curOptionSel[1]))
		for i in curOptionSel[4].size():
			var promptLabel = Label.new()
			promptLabel.label_settings = optionTexts[curSel].label_settings
			promptLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			optionl.add_child(promptLabel)
			if i == curStrSel:
				promptLabel.text = '> '+curOptionSel[4][i]+' <'
			else:
				promptLabel.text = curOptionSel[4][i]
	if curOptionSel.size() != 3:
		descLabel.text = curOptionSel[3]
	else:
		descLabel.text = 'No description given or needed.'
func getOptionMeasure():
	match curOptionSel[0]:
		'OFFSET':
			return 'ms'
		'FRAMERATE':
			return ' FPS'
		'TICKRATE':
			return ' TPS'
		_:
			if curOptionSel[0].ends_with("MULTIPLIER"):
				return 'x'
			else:
				return ''
var curSel = 0
func changeSelSideBar(fucker):
	curSel += fucker
	if curSel > optionTexts.size()-1:
		curSel = 0
	elif curSel < 0:
		curSel = optionTexts.size()-1
	
	for i in optionTexts.size():
		if i == curSel:
			optionTexts[i].modulate.a = 1
		else:
			optionTexts[i].modulate.a = 0.5
	drawSelThing()

func drawSelThing():
	for i in options.get_children():
		options.remove_child(i)
		i.free()
	var optionArr = fuck.get(optionTexts[curSel].name)
	for e in optionArr:
		var label = Label.new()
		label.text = e[0]
		label.label_settings = optionTexts[curSel].label_settings
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		options.add_child(label)
	optionTexts2 = []
	for i in $"Container/Options".get_children().size():
		var thing = $"Container/Options".get_child(i)
		if thing.is_queued_for_deletion() != true || !(i >= fuck.get(optionTexts[curSel].name).size()) || i != null:
			optionTexts2.append(thing)
