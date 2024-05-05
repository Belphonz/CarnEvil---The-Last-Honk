extends Node2D


func _on_controls_pressed():
	get_tree().change_scene_to_file("res://scenes/ControlsMenu.tscn")


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MainScene.tscn")


func _on_quit_button_pressed():
	get_tree().quit()


func _on_controls_mouse_entered():
	get_node("Controls").scale *= 1.2


func _on_controls_mouse_exited():
	get_node("Controls").scale /= 1.2


func _on_start_button_mouse_entered():
	get_node("StartButton").scale *= 1.4


func _on_start_button_mouse_exited():
	get_node("StartButton").scale /= 1.4


func _on_quit_button_mouse_entered():
	get_node("QuitButton").scale *= 1.2


func _on_quit_button_mouse_exited():
	get_node("QuitButton").scale /= 1.2
