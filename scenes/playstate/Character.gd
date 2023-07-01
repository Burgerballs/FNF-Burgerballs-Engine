extends AnimatedSprite2D
class_name Character
class CharAnimConfig:
	extends Node
	var offsets:Vector2
	var loops:bool
	var fps:int
	var anim:String
	var animName:String
	func _init(fpss,animm,animname,offsets,loops):
		fps = fpss
		anim = animm
		animName = animname
		self.offsets = offsets
		self.loops = loops
class CharacterData:
	extends Node
	var charAnims:Array[CharAnimConfig]
	var antiAiliasing = true
	var flipX = true
	var healthBarColor:Color
	var scale:float
	var position:Vector2
	var camOffset
	func _init(charName):
		var file = FileAccess.open("res://assets/images/characters/"+charName+'/'+charName+'.json', FileAccess.READ)
		if !FileAccess.file_exists("res://assets/images/characters/"+charName+'/'+charName+'.json'):
			file = FileAccess.open("res://assets/images/characters/dad/dad.json", FileAccess.READ)
		var content = JSON.parse_string(file.get_as_text())
		for animm in range(content['animations'].size()):
			var anim = content['animations'][animm]
			charAnims.append(CharAnimConfig.new(anim['fps'], anim['anim'], anim['name'],Vector2(anim['offsets'][0],anim['offsets'][1]), anim['loop']))
		antiAiliasing = !content["no_antialiasing"]
		flipX = content["flip_x"]
		healthBarColor = Color(content["healthbar_colors"][0]/256.0,
		content["healthbar_colors"][1]/256.0,
		content["healthbar_colors"][2]/256.0)
		position = Vector2(content["position"][0],content["position"][1])
		camOffset = Vector2(content["camera_position"][0],content["camera_position"][1])
		scale = content["scale"]

var charName:String = 'bf'
var charData:CharacterData
var curAnim = ''
var isBf = false
var cameraPos:Vector2

func _loadChar(charName = 'bf', isBf = false):
	self.charName = charName
	charData = CharacterData.new(charName)
	print(charData.charAnims[0].animName)
	self.isBf = isBf
	centered = false
	flip_h = charData.flipX
	if isBf:
		flip_h = !flip_h
	if !FileAccess.file_exists("res://assets/images/characters/"+charName+'/'+charName+'.res'):
		set_sprite_frames(load("res://assets/images/characters/dad/dad.res"))
	else:
		set_sprite_frames(load("res://assets/images/characters/"+charName+'/'+charName+'.res'))
	position+=charData.position
	cameraPos = charData.camOffset
	_playAnim('idle')
	connect("animation_finished", _animFinished)
func _dance():
	if !curAnim.begins_with('sing'):
		_playAnim('idle')
func _playAnim(animName):
	pause()
	for anim in charData.charAnims:
		if anim.anim == animName:
			if curAnim != animName:
				doTheAnim(anim.animName, anim.offsets)
				curAnim = anim.anim
			elif curAnim.begins_with('sing'):
				frame = 0
				play('',1)
			else:
				doTheAnim(anim.animName, anim.offsets)
				curAnim = anim.anim
			break
			
func doTheAnim(animName, offsets):
	play(animName.replace('0', ''))
	if !flip_h:
		set_offset(-offsets)
	else:
		set_offset(offsets)
func _animFinished():
	if curAnim != 'idle':
		_playAnim('idle')
