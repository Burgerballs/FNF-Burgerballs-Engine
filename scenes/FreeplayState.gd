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
var optionsState = preload("res://scenes/OptionsMenu.tscn")
var songCheck:Song
var scoreDictionary = {
	"score":0,
	"accuracy":100
}
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
var actualScore = 0
var actualAccuracy = 0
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
	elif Input.is_key_pressed(KEY_TAB):
		var OptionsThing = optionsState.instantiate()
		OptionsThing.isNotMenu = true
		OptionsThing.thing = false
		$CanvasLayer3.add_child(OptionsThing)
	for i in IconLayer.get_children().size():
		IconLayer.get_child(i).position.x = AlphabetLayer.get_child(i).position.x + AlphabetLayer.get_child(i).size.x + 60
		IconLayer.get_child(i).position.y = AlphabetLayer.get_child(i).position.y + (AlphabetLayer.get_child(i).size.y / 2)
	var lerpVal:float = CoolUtil.boundTo(delta * 2.4, 0, 1)
	actualScore = lerp(float(actualScore), float(scoreDictionary['score']), lerpVal)
	actualAccuracy = lerp(float(actualAccuracy), float(scoreDictionary['accuracy']), lerpVal)
	$'ScoreText/Text'.text = 'SCORE: ' + str(actualScore) +'\nACCURACY: ' + str(actualAccuracy)
func changeDiff(fucker):
	curDiff += fucker
	if curDiff > diffList.size()-1:
		curDiff = 0
	elif curDiff < 0:
		curDiff = diffList.size()-1
	songCheck = Song.new()
	songCheck.parse_chart(songList[curSel].songName.to_lower().replace(' ', '-'),diffList[curDiff])
	scoreDictionary = Highscore.getHighscore(songList[curSel].songName.to_lower().replace(' ', '-'),diffList[curDiff])
	var noteCount =0
	
	for i in songCheck.notes:
		for s in i.notes:
			if s.playedByBf:
				noteCount+=1
	$"SongInfo/Text".text = 'SONG NAME: ' + songList[curSel].songName.to_upper() + '\n['+diffList[curDiff]+']'
	$"SongInfo/Text2".text = 'NOTES:' + str(noteCount)
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
			songCheck = Song.new()
			songCheck.parse_chart(songList[curSel].songName.to_lower().replace(' ', '-'),diffList[curDiff])
		else:
			alphabet.modulate.a = 0.6
		alphabet.target_y = i - curSel
	var noteCount =0
	
	for i in songCheck.notes:
		for s in i.notes:
			if s.playedByBf:
				noteCount+=1
	if FileAccess.file_exists('res://assets/weeks/'+songList[curSel].weekItComesFrom+'/week.png'):
		$"WeekPanel/Label".visible = false
		$"WeekPanel/Week".visible = true;
		$"WeekPanel/Week".texture = load('res://assets/weeks/'+songList[curSel].weekItComesFrom+'/week.png')
	else:
		$"WeekPanel/Label".visible = true
		$"WeekPanel/Week".visible = false
	
	$"SongInfo/Text".text = 'SONG NAME: ' + songList[curSel].songName.to_upper() + '\n['+diffList[curDiff]+']'
	$"SongInfo/Text2".text = 'NOTES:' + str(noteCount)
	scoreDictionary = Highscore.getHighscore(songList[curSel].songName.to_lower().replace(' ', '-'),diffList[curDiff])
	var tweenr = create_tween()
	tweenr.set_ease(Tween.EASE_OUT)
	tweenr.set_trans(Tween.TRANS_QUAD)
	tweenr.tween_property($bg, "modulate", songList[curSel].songColor, 0.2)


func addSongsToList():
	for weekName in weekpars.weekList:
		for song in weekpars.loadedWeeks[weekName].songs:
			var tempMeta = SongMetadata.new(song[0], "res://assets/images/characters/" + song[1] + '/icon.png', Color(song[2][0]/255,song[2][1]/255,song[2][2]/255, 1), weekName)
			songList.append(tempMeta)
