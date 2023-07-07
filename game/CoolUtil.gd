extends Node
class_name CoolUtil
var difficulties = ["EASY", 'NORMAL', 'HARD']
	
static func boundTo(v,mn,mx):
	return max(mn, min(mx,v))
static func listDirs(path:String):
	var files:PackedStringArray = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		while true:
			var file = dir.get_next()
			if file == "": break
			else: files.append(file)
		dir.list_dir_end()
	return files
