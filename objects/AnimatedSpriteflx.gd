extends AnimatedSprite2D
class_name AnimatedSpriteflx
var frames:SpriteFrames
func _ready():
	sprite_frames = SpriteFrames.new()
func addAnimFromName(animname,resname,fps,loop):
	sprite_frames.add_animation(animname)
	for i in frames.get_frame_count(resname.replace('0', '')):
		sprite_frames.add_frame(animname, frames.get_frame_texture(resname.replace('0', ''), i), 1, i)
		sprite_frames.set_animation_speed(animname, fps)
		sprite_frames.set_animation_loop(animname, loop)
