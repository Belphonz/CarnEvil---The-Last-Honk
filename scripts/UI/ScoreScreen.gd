extends Node2D

var FinalArray
var page = 0
var _currentText : Label
var liner : LineEdit
var _forwardButton : TextureButton
var _backButton : TextureButton
var _mainButton : TextureButton

func _on_line_edit_ready():
	get_tree().root.remove_child(get_tree().root.get_child(1))
	_forwardButton = get_node("Forward")
	_backButton = get_node("Back")
	liner = get_child(2)
	_mainButton = get_node("Mainbutton")
	$LineEdit.grab_focus()
	_currentText = get_child(1)
	_forwardButton.visible = false
	_backButton.visible = false
	_currentText.text = "Score: " + str(Highscore.runscore) + "\nEnter Name"



func _on_line_edit_text_submitted(nam):
	if nam.length() == 3:
		nam = nam.to_upper()
		FinalArray = Highscore.fileArray
		FinalArray.push_back([Highscore.ID + 1, nam, Highscore.runscore])
		Highscore.ID = FinalArray[-1][0]
		Highscore.save(FinalArray)
		FinalArray.sort_custom(func(a, b): return a[2] > b[2])
		displayPage()
		liner.visible = false
		
	
func _on_forward_pressed():
	if FinalArray :
		page += 1
		displayPage()

func _on_back_pressed():
	if FinalArray :
		page -= 1
		displayPage()

func _on_mainbutton_pressed():
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")

func displayPage():
	_currentText.text = ""
	if page == 0:
		_backButton.visible = false
	else:
		_backButton.visible = true
	if page < floor((FinalArray.size() - 1) / 4):
		_forwardButton.visible = true
	else:
		_forwardButton.visible = false
	for i in 4:
		#if FinalArray[page * 4 + i]:
		if (4 * page) + i <= FinalArray.size() - 1:
			_currentText.text += str(FinalArray[page * 4 + i][1]) + "      " +str(FinalArray[page * 4 + i][2]) + "\n"
		else:
			_currentText.text += "---      ---- \n"



func _on_forward_mouse_entered():
	_forwardButton.scale *= 1.07

func _on_forward_mouse_exited():
	_forwardButton.scale /= 1.07

func _on_back_mouse_entered():
	_backButton.scale *= 1.07
	
func _on_back_mouse_exited():
	_backButton.scale /= 1.07


func _on_mainbutton_mouse_entered():
	_mainButton.scale *= 1.07

func _on_mainbutton_mouse_exited():
	_mainButton.scale /= 1.07
