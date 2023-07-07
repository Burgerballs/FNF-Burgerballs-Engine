extends Node2D

@onready var AlphabetLayer = $CanvasLayer
@onready var IconLayer = $CanvasLayer2
class SongMetadata:
	var icon = 'res://assets/images/characters/bf/icon.png'
	var songName = 'bopeebo'
	var songColor = Color(1,1,1,1)
	var weekItComesFrom = 'week1'
	func _init(songName, icon, songColor, weekItComesFrom):
		self.songName = songName
		self.icon = icon
		self.songColor = songColor
		self.weekItComesFrom = weekItComesFrom

var weekpars = WeekParser.new() ## makes new weekparser instance
var songList:Array[SongMetadata]
var diffList = CoolUtil.new().difficulties
# Called when the node enters the scene tree for the first time.
var curSel = 0
var curDiff = 1
func _ready():
	weekpars.burgerBITCH()
	addSongsToList()
	for s in songList.size():
		var alphaChar = $AlphabetTemplate.duplicate()
		alphaChar.visible = true
		alphaChar.text = songList[s].songName
		alphaChar.is_menu_item = true
		alphaChar.target_y = s
		AlphabetLayer.add_child(alphaChar)
		var Icon = $IconTemplate.duplicate()
		Icon.texture = load(songList[s].icon)
		IconLayer.add_child(Icon)
	changeSel(0)
	
func _process(delta):
	if Input.is_action_just_pressed('uiup'):
		changeSel(-1)
	elif Input.is_action_just_pressed('uidown'):
		changeSel(1)
	elif Input.is_action_just_pressed('uileft'):
		changeDiff(-1)
	elif Input.is_action_just_pressed('uiright'):
		changeDiff(1)
	elif Input.is_action_just_pressed('ui_accept'):
		Globals.play_song(songList[curSel].songName.to_lower().replace(' ', '-'),diffList[curDiff])
	for i in IconLayer.get_children().size():
		IconLayer.get_child(i).position.x = AlphabetLayer.get_child(i).position.x + AlphabetLayer.get_child(i).size.x + 60
		IconLayer.get_child(i).position.y = AlphabetLayer.get_child(i).position.y + (AlphabetLayer.get_child(i).size.y / 2)
func changeDiff(fucker):
	curDiff += fucker
	if curDiff > diffList.size()-1:
		curDiff = 0
	elif curDiff < 0:
		curDiff = diffList.size()-1
	$"SongInfo/Text".text = 'SONG NAME: ' + songList[curSel].songName.to_upper() + '\n['+diffList[curDiff]+']'
func changeSel(fucker):
	curSel += fucker
	if curSel > songList.size()-1:
		curSel = 0
	elif curSel < 0:
		curSel = songList.size()-1
	for i in AlphabetLayer.get_children().size():
		var alphabet = AlphabetLayer.get_child(i)
		if i == curSel:
			alphabet.modulate.a = 1
		else:
			alphabet.modulate.a = 0.6
		alphabet.target_y = i - curSel
	$"SongInfo/Text".text = 'SONG NAME: ' + songList[curSel].songName.to_upper() + '\n['+diffList[curDiff]+']'
	var tweenr = create_tween()
	tweenr.set_ease(Tween.EASE_OUT)
	tweenr.set_trans(Tween.TRANS_QUAD)
	tweenr.tween_property($bg, "modulate", songList[curSel].songColor, 0.2)


func addSongsToList():
	for weekName in weekpars.weekList:
		for song in weekpars.loadedWeeks[weekName].songs:
			var tempMeta = SongMetadata.new(song[0], "res://assets/images/characters/" + song[1] + '/icon.png', Color(song[2][0]/255,song[2][1]/255,song[2][2]/255, 1), weekName)
			songList.append(tempMeta)
