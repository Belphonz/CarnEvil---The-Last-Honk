extends Node2D

var file_data
var ID : int
var data_received
var runscore = 0
var Player : Node2D
var currentScene
var fileArray

func _ready():
	
	

	loadScores()
	var newscore = [1, "ADL", 1921]
	var json_string = JSON.stringify(file_data)
	var json = JSON.new()
	
	#var scorelist = json.parse()
	
	var error = json.parse(json_string)
	if error == OK:
		data_received = json.data
		if typeof(data_received) == TYPE_ARRAY:
			fileArray = data_received
			ID = data_received[-1][0]
		else:
			print("uh oh not array")
			print(data_received)
	else:
		print("Parse error")
	
func save(fileh):
	var file = FileAccess.open("res://highscores.json", FileAccess.WRITE)
	file.flush()
	file.store_line(JSON.stringify(fileh))

func loadScores():
	var file
	if not FileAccess.file_exists("res://highscores.json"):
		save(file_data)
		return
	file = FileAccess.open("res://highscores.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file_data = data

func Savescore(nam):
	var json = JSON.new()
	var json_string = JSON.stringify(file_data)
	fileArray = json.data
	#fileArray.push_back([ID + 1, nam, runscore])

func sortScores(a, b):
	if a[2] < b[2]:
		return true
	return false
