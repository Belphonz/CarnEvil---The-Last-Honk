extends Node2D


func _on_quit_pressed():
	get_tree().quit()


func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ScoreScreen.tscn")




func _on_button_mouse_entered():
	get_node("Button").scale *= 1.05


func _on_button_mouse_exited():
	get_node("Button").scale /= 1.05
