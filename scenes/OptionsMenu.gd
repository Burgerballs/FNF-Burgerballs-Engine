extends Node2D

var optionTexts:Array
var optionTexts2:Array
@onready var options = $"Container/Options"
@onready var optionl = $"Container/OptionL"
@onready var optionsbar = $"Container/VBoxContainer"
@onready var descLabel = $"Container/ColorRect2/Magic"
@onready var descLabelBG = $"Container/ColorRect2"
var sideBarState = true

var fuck:Dictionary = {
	'gameplay' = [
		['DOWNSCROLL', 'downscroll', 'bool', 'Notes scroll down if activated.'],
		['OFFSET', 'offset', 'float', 'Note positions are incremented by the amount given by you. (Positive amounts = later)', [1,-100,100]]
	],
	'graphics' = [
		['FPS LIMIT', 'fps', 'float', 'No description given or needed.', [1, 60, 300]],
		['MULTITHREADED RENDERING', 'multithreading', 'bool']
	],
	'controls' = [
		['LEFT', 'left', 'control']
	]
}

func _ready():
	optionTexts = optionsbar.get_children()
	changeSelSideBar(0)
	Conductor.playMusic('music/peebutter', Globals.BGMStream, true, true)
	coolBoxSizeThing(optionsbar)

func coolBoxSizeThing(box):
	var thing = $"Container/ColorRect3"
	var boxproperties = [box.global_position, box.size]
	var postween = create_tween()
	postween.set_ease(Tween.EASE_IN_OUT)
	postween.set_trans(Tween.TRANS_QUAD)
	postween.tween_property(thing, 'global_position', boxproperties[0], 0.4)
	var sizeween = create_tween()
	sizeween.set_ease(Tween.EASE_IN_OUT)
	sizeween.set_trans(Tween.TRANS_QUAD)
	sizeween.tween_property(thing, 'size', boxproperties[1], 0.4)
func _process(delta):
	if Input.is_action_just_pressed('uiup'):
		if sideBarState:
			changeSelSideBar(-1)
		else:
			changeSel(-1)
	elif Input.is_action_just_pressed('uidown'):
		if sideBarState:
			changeSelSideBar(1)
		else:
			changeSel(1)
	elif Input.is_action_just_pressed('uileft'):
		if !sideBarState:
			modifySetting(-1)
	elif Input.is_action_just_pressed('uiright'):
		if !sideBarState:
			modifySetting(1)
	elif Input.is_action_just_pressed('uienter'):
		if sideBarState:
			sideBarState = false
			curSelOption = 0
			changeSel(0)
			coolBoxSizeThing(options)
			optionl.visible = true
			descLabelBG.visible = true
	elif Input.is_action_just_pressed('uiback'):
		if !sideBarState:
			sideBarState = true
			for i in optionTexts2.size():
				optionTexts2[i].modulate.a = 1
				descLabelBG.visible = false
			coolBoxSizeThing(optionsbar)
			optionl.visible = false
			
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
	Preferences.actUpon()
	drawOptionThing()
	Preferences.saveData()
	
var curOptionSel
var curSelOption = 0
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
	if curOptionSel.size() != 3:
		descLabel.text = curOptionSel[3]
	else:
		descLabel.text = 'No description given or needed.'
func getOptionMeasure():
	match curOptionSel[0]:
		'OFFSET':
			return 'ms'
		'FPS LIMIT':
			return ' FPS'
		_:
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
	print(optionTexts2.size()-1)
