extends Control

var isPaused : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = isPaused


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("pause"):
		isPaused = !isPaused
		visible = isPaused
		get_tree().paused = isPaused


func _on_resume_mouse_entered():
	get_node("Resume").scale *= 1.2


func _on_resume_mouse_exited():
	get_node("Resume").scale /= 1.2


func _on_menu_mouse_entered():
	get_node("Menu").scale *= 1.2


func _on_menu_mouse_exited():
	get_node("Menu").scale /= 1.2


func _on_resume_pressed():
	isPaused = !isPaused
	visible = isPaused
	get_tree().paused = isPaused

func _on_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
	
