extends Sprite2D

class_name MenuItem

var targetY:float = 0
var flashingInt:int = 0
func _init(x,y,weekName:String = 'week1'):
	position.x=640
	position.y=y
	texture = load('res://assets/weeks/'+weekName+'/week.png')

var isFlashing:bool = false
func startFlashing():
	isFlashing = true
	
func _process(delta):
	var fakeFramerate = int(round((1/(delta)/10)))
	position.y = lerp(position.y,(targetY*120)+480,CoolUtil.boundTo(delta*10.2,0,1))
	if isFlashing:
		flashingInt += 1
	if flashingInt % fakeFramerate >= floor(fakeFramerate/2):
		modulate = Color('33ffff')
	else:
		modulate = Color.WHITE
