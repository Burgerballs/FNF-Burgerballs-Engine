extends Label
var fps = ''
var tps = ''
var mem = 0
func _process(float):
	fps = str(floor(1/float))
	mem = str(OS.get_static_memory_usage()/1000/1000)
	text = 'FPS: '+fps+'\nTPS: '+tps+'\nMEM: '+mem+'MB'
func _physics_process(delta):
	tps = str(floor(1/delta))
