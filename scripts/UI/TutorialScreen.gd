extends Node2D




func onReturnButtonPressed():
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")


func _on_controls_mouse_entered():
	get_node("Controls").scale *= 1.2


func _on_controls_mouse_exited():
	get_node("Controls").scale /= 1.2
