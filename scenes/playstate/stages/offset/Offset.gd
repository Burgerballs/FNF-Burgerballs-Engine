extends Stage
@onready var mslabel = $"ParallaxBackground/ParallaxLayer4/Label"
var msMean = 0
var diffs = []
func _ready():
	dad.visible = false
	gf.visible = false
	$'../CamHUD/HealthBar'.visible = false
	$'../CamHUD/TimeDisplay'.visible = false
	$'../CamHUD/ScoreTxt'.visible = false
	game.dadStrums.visible = false
	$'../CamHUD/RatingSpr'.visible = false
	game.connect("noteHit", onNoteHit)
	game.connect("songEnd", onSongEnd)
	
func onNoteHit(note):
	var diff = (Conductor.songPos - note.pos) / Preferences.getPreference('songspd')
	diffs.append(diff)
	calcMean()
	mslabel.text = str(msMean) + 'ms'
func onSongEnd():
	Preferences.setPreference('offset', Preferences.getPreference('offset') + msMean)
	Preferences.saveData()
func calcMean():
	var numSize = diffs.size()
	var diffsamnt = 0
	for i in diffs:
		diffsamnt+=i
	msMean = floor(diffsamnt / numSize)
func _process(f):
	game.health = 1
