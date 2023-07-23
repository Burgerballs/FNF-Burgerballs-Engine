extends Node2D

var loadedWeeks:Dictionary
var weekpars = WeekParser.new() ## makes new weekparser instance
var curSel = 0
var curDiff = 1
var selected = false
var diffList = CoolUtil.new().difficulties
@onready var menuLabel = $"BACKGROUND/MenuTracks/Label"
@onready var weekLayer = $"BACKGROUND/weeks"
@onready var diffSpr = $"BACKGROUND/difficultySelector/difficulty"
@onready var chars = $"Chars"
# Called when the node enters the scene tree for the first time.
func _ready():
	weekpars.burgerBITCH()
	addWeeks()
	changeSel(0)
	changeDiff(0)
	var charArray = loadedWeeks.get(weekpars.weekList[0]).weekCharacters
	for char in 3:
		var funny = WeekChar.new(charArray[char])
		funny.position.x = (1280 * 0.25) * (1+char) - 150
		funny.position.y += 70
		chars.add_child(funny)
func addWeeks():
	var num = 0
	for i in weekpars.weekList.size():
		if !weekpars.loadedWeeks.get(weekpars.weekList[i]).hiddenWeek:
			var weekThing:MenuItem = MenuItem.new(0,56+396,weekpars.weekList[i])
			weekThing.position.y += 102*num
			weekThing.targetY = num
			loadedWeeks.merge({weekpars.weekList[i]: weekpars.loadedWeeks.get(weekpars.weekList[i])})
			$BACKGROUND/weeks.add_child(weekThing)
			num+=1
func _process(delta):
	if !selected:
		if Input.is_action_just_pressed('uiup'):
			changeSel(-1)
		elif Input.is_action_just_pressed('uidown'):
			changeSel(1)
		if Input.is_action_just_pressed('uileft'):
			changeDiff(-1)
		elif Input.is_action_just_pressed('uiright'):
			changeDiff(1)
		elif Input.is_action_just_pressed('uienter'):
			selected = true
			beginWeek()

func changeDiff(fucker):
	curDiff += fucker
	if curDiff > diffList.size()-1:
		curDiff = 0
	elif curDiff < 0:
		curDiff = diffList.size()-1
	diffSpr.texture = load('res://assets/images/difficulties/'+diffList[curDiff]+'.png')
	diffSpr.position.y =  $"BACKGROUND/difficultySelector/left".position.y-15
	diffSpr.modulate.a = 0
	quickTween(diffSpr, "modulate:a", 1,0.07)
	quickTween(diffSpr, "position:y", $"BACKGROUND/difficultySelector/left".position.y+15,0.07)
func quickTween(a,b,c,d):
	var tween = create_tween()
	tween.tween_property(a,b,c,d)
func beginWeek():
	var week = weekLayer.get_child(curSel)
	week.startFlashing()
func changeSel(fucker):
	curSel += fucker
	if curSel > weekpars.weekList.size()-1:
		curSel = 0
	elif curSel < 0:
		curSel = weekpars.weekList.size()-1
	for i in weekLayer.get_children().size():
		var week = weekLayer.get_child(i)
		if i == curSel:
			week.modulate.a = 1
		else:
			week.modulate.a = 0.7
		week.targetY = i - curSel
	var strthing = ''
	for i in weekpars.loadedWeeks.get(weekpars.weekList[curSel])['songs']:
		strthing+=i[0]+'\n'
	menuLabel.text = strthing.to_upper()
