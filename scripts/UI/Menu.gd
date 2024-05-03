extends Node2D


func _on_controls_pressed():
	get_tree().change_scene_to_file("res://scenes/ControlsMenu.tscn")


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MainScene.tscn")


func _on_quit_button_pressed():
	get_tree().quit()
