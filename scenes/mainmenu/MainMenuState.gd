extends Node2D

var optionSprs:Array
var curSel:int = 0
func _ready():
	optionSprs = $Options.get_children()
	changeSel(0)
	Conductor.playMusic('music/freakyMenu', Globals.BGMStream)
	$Options.visible = true

var alreadyEntered = false
func changeSel(fuck):
	curSel += fuck
	if curSel > optionSprs.size()-1:
		curSel = 0
	elif curSel < 0:
		curSel = optionSprs.size()-1
	
	for i in optionSprs.size():
		if i == curSel:
			optionSprs[i].play(optionSprs[i].name+' white')
		else:
			optionSprs[i].play(optionSprs[i].name+' basic')
func goTo():
	match (optionSprs[curSel].name):
		'freeplay':
			Globals.switchTo('FreeplayState')
		'options':
			Globals.switchTo('OptionsMenu')
		
		_:
			print('notFound')
func _process(delta):
	if Input.is_action_just_pressed('uiup') && !alreadyEntered:
		changeSel(-1)
	elif Input.is_action_just_pressed('uidown') && !alreadyEntered:
		changeSel(1)
	elif Input.is_action_just_pressed('uienter') && !alreadyEntered:
		$"Magenta/AnimationPlayer".play('flicker')
		$"AnimationPlayer".root_node=optionSprs[curSel].get_path()
		$"AnimationPlayer".play('flicker')
		alreadyEntered = true
		Globals.playSound('confirmMenu')
		for i in optionSprs.size():
			if i != curSel:
				var tween = create_tween()
				tween.set_ease(Tween.EASE_OUT)
				tween.set_trans(Tween.TRANS_QUAD)
				tween.tween_property(optionSprs[i], "modulate:a", 0.0,0.4)
		var timer = Timer.new()
		add_child(timer)
		timer.connect('timeout', goTo)
		timer.start(0.45)
