extends Label

func _process(float):
	text = 'FPS: ' + str(floor(1/float)) +'\nMEM: ' + str(OS.get_static_memory_usage()/1000/1000) + 'MB'
