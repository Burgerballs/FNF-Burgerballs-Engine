extends AnimatedSprite2D
class_name Character
class CharAnimConfig:
	extends Node
	var offsets:Vector2
	var loops:bool
	var fps:int
	var anim:String
	var animName:String
	var indices = []
	func _init(fpss,animm,animname,offsets,loops, indices):
		fps = fpss
		anim = animm
		animName = animname
		self.offsets = offsets
		self.loops = loops
		self.indices = indices
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
			charAnims.append(CharAnimConfig.new(anim['fps'], anim['anim'], anim['name'],Vector2(anim['offsets'][0],anim['offsets'][1]), anim['loop'],anim['indices']))
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
var charFrames:SpriteFrames
var charAnimFrames:SpriteFrames
func _loadChar(charName = 'bf', isBf = false):
	self.charName = charName
	charData = CharacterData.new(charName)
	self.isBf = isBf
	centered = false
	flip_h = charData.flipX
	if isBf:
		flip_h = !flip_h
	if !FileAccess.file_exists("res://assets/images/characters/"+charName+'/'+charName+'.res'):
		charFrames=load("res://assets/images/characters/dad/dad.res")
		self.charName = 'dad'
	else:
		charFrames = load("res://assets/images/characters/"+charName+'/'+charName+'.res')
	charAnimFrames = SpriteFrames.new()
	for anim in charData.charAnims:
		if anim.indices == []:
			addAnimFromName(anim.anim, anim.animName, anim.fps, anim.loops)
		else:
			addAnimFromIndices(anim.anim, anim.animName, anim.fps, anim.loops,anim.indices)
	set_sprite_frames(charAnimFrames)
	position+=charData.position
	if !flip_h:
		cameraPos = charData.camOffset
	else:
		cameraPos = !charData.camOffset
	_dance()
	connect("animation_finished", _animFinished)
func get_midpoint():
	if findAnim('idle'):
		return Vector2(sprite_frames.get_frame_texture('idle',0).region.size.x/2,sprite_frames.get_frame_texture('idle',0).region.size.y/2)
	else:
		return Vector2(sprite_frames.get_frame_texture('danceLeft',0).region.size.x/2,sprite_frames.get_frame_texture('danceLeft',0).region.size.y/2)
func addAnimFromName(name,resname,fps,loop):
	charAnimFrames.add_animation(name)
	for i in charFrames.get_frame_count(resname.replace('0', '')):
		charAnimFrames.add_frame(name, charFrames.get_frame_texture(resname.replace('0', ''), i), 1, i)
		charAnimFrames.set_animation_speed(name, fps)
		charAnimFrames.set_animation_loop(name, loop)
func addAnimFromIndices(name,resname,fps,loop,indices):
	charAnimFrames.add_animation(name)
	for i in indices.size():
		var animnumber = indices[i]
		if animnumber > charFrames.get_frame_count(resname.replace('0', ''))-1:
			animnumber = charFrames.get_frame_count(resname.replace('0', ''))-1
		charAnimFrames.add_frame(name, charFrames.get_frame_texture(resname.replace('0', ''), animnumber), 1, i)
		charAnimFrames.set_animation_speed(name, fps)
		charAnimFrames.set_animation_loop(name, loop)

var danced = false
func _dance():
	if !curAnim.begins_with('sing'):
		if findAnim('idle'):
			_playAnim('idle')
		elif findAnim('danceLeft'):
			_playAnim('dance' + ('Left' if !danced else 'Right'))
			danced = !danced
func findAnim(anim):
	for i in charData.charAnims.size():
		if charData.charAnims[i].anim == anim:
			return true
	return false
func _playAnim(animName):
	play(animName)
	if animName != 'idle' && !animName.begins_with('dance'):
		set_frame_and_progress(0,0)
	curAnim = animName
	var offsets = Vector2(0,0)
	for i in charData.charAnims.size():
		if charData.charAnims[i].anim == animName:
			offsets = charData.charAnims[i].offsets
			break
	if !flip_h:
		set_offset(-offsets)
	else:
		set_offset(offsets)
func _animFinished():
	if (curAnim != 'idle') && not curAnim.begins_with('dance'):
		if !findAnim('idle'):
			_playAnim('dance' + ('Left' if !danced else 'Right'))
			danced = !danced
		else:
			_playAnim('idle')
