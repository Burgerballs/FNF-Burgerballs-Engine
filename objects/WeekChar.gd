extends AnimatedSprite2D
class_name WeekChar
class WeekCharData:
	var position:Vector2
	var scale:float
	var idle_anim:String
	var confirm_anim:String
	var img:String # shoutout to the real one img27realest
	func _init(thingName):
		var file
		var path = "res://assets/images/weekchars/"+thingName+"/"+thingName+".json"
		if !FileAccess.file_exists(path):
			path = "res://assets/images/weekchars/bf/bf.json"
		file = FileAccess.open(path, FileAccess.READ)
		var content = JSON.parse_string(file.get_as_text())
		position = Vector2(content["position"][0],content["position"][1])
		scale = content["scale"]
		idle_anim = content["idle_anim"]
		confirm_anim = content["confirm_anim"]
		img = path.replace('json','res')
var data:WeekCharData
var frames:SpriteFrames
var charAnimFUCK:SpriteFrames
@export var charName:String = 'bf':
	set(v):
		if v != '':
			data = WeekCharData.new(v)
			frames = load(data.img)
			doAnims()
			set_sprite_frames(charAnimFUCK)
			play('idle')
func _init(name):
	charAnimFUCK = SpriteFrames.new()
	charName = name
func addAnimFromName(name,resname,fps,loop):
	charAnimFUCK.add_animation(name)
	for i in frames.get_frame_count(resname.replace('0', '')):
		charAnimFUCK.add_frame(name, frames.get_frame_texture(resname.replace('0', ''), i), 1, i)
		charAnimFUCK.set_animation_speed(name, fps)
		charAnimFUCK.set_animation_loop(name, loop)
func doAnims():
	addAnimFromName('idle',data.idle_anim,24,true)
	addAnimFromName('confirm',data.confirm_anim,24,true)
