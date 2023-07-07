extends Node2D
class_name Note
@onready var strumLine:StrumLine
var arrows = preload("res://assets/images/NOTE_assets.res")
var pos:float = 0.0
var dir:int = 0
var mustHit:bool = false
var dirNames = ['purple', 'blue', 'green', 'red']
var tooLate:bool = false
var canBeHit = false;
var wasGoodHit = false;
var holdLength:float = 0.0
var game
var char
var noteSkins = {
	"Default" = preload('res://objects/noteShit/NoteSkins/Basic.tscn').instantiate()
}
var noteSkin:Node2D
var sprite:AnimatedSprite2D
var susRect:ColorRect
var susLine:Line2D
var susEnd:AnimatedSprite2D
var hasHold:bool = false
func _init(strumTime, noteData, mustHitt):
	pos = strumTime
	dir = noteData
	mustHit = mustHitt
	add_child(noteSkins['Default'])
	noteSkin = get_child(0)
	sprite = noteSkin.find_child('AnimatedSprite2D')
	susRect = noteSkin.find_child('ColorRect')
	susLine = susRect.find_child('susLine')
	susEnd = susRect.find_child('susEnd')
	position.y = 2000
	
func reloadSprites():
	sprite.play(dirNames[dir]) 
	if holdLength >= Conductor.stepCrotchet/8:
		hasHold = true
		sprite.set_sprite_frames(arrows)
		susEnd.set_sprite_frames(arrows)
		susLine.texture = load("res://assets/"+dirNames[dir]+" hold0000.png")
		susLine.width = 50 / self.scale.x
		susEnd.play(dirNames[dir] + ' hold end')
		susRect.size.y = 720/scale.y
	else:
		holdLength = 0
		susRect.visible = false
		susLine.visible = false
		susEnd.visible = false
		
var downscrollMult = -1
func _process(d):
	downscrollMult = (1 if !Preferences.getPreference('downscroll') else -1)
	if mustHit:
		canBeHit = (absf(Conductor.songPos - pos) <= (Conductor.safeZoneOffset))
		tooLate = (pos < Conductor.songPos - Conductor.safeZoneOffset && !wasGoodHit)
	else:
		canBeHit = false
		wasGoodHit = (pos < Conductor.songPos + (Conductor.safeZoneOffset/8))
	var scrollSpeed = game.speed
	if tooLate:
		modulate.a = 0.3
	if wasGoodHit:
		sprite.visible = false
		strumLine.get_child(dir).playAnim("confirm")
		holdLength -= (d * 1000.0 * (scrollSpeed/1.75))
		game.Voices.volume_db = 0
		game.playDirectionAnim(dir, '', char)
		if holdLength <= 10:
			if not mustHit:
				game.opponentNote(self)
			queue_free()
		elif holdLength > 10 && mustHit:
			game.score += int(3000 / float(d*10000))
		if mustHit && holdLength >= 80.0 and !Input.is_action_pressed(strumLine.controls[dir]):
			game.miss(self)
		
	if game != null && hasHold:
		var lastpoint = susLine.points.size() - 1
		var endPoint = ((((holdLength / 2.5) * scrollSpeed) / scale.y) * downscrollMult)
		susLine.points[lastpoint].y = endPoint
		susEnd.position.y = susLine.position.y + endPoint + (((susLine.texture.get_height() * 0.7) - 4) * downscrollMult)
		susEnd.flip_v = downscrollMult < 0
		if downscrollMult<0:
			susRect.position.y = -susRect.size.y
			susLine.position.y = susRect.size.y
		else:
			susRect.position.y = 0
			susLine.position.y = 0
		
func swap(vec2array):
	return [vec2array[vec2array.size() - 1], vec2array[0]]
func _kill():
	self.queue_free()
