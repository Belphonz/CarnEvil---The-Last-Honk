extends CharacterBody2D

var Player:Node2D=null		#Node2D
var playerDirection: Vector2
var leftDirection = [0,1,7]
var BloodSplat = preload("res://elements/Enemies/Bloodsplatter.tscn")
var HP:float
var maxHealth:float	

var moveSpeed: float

func start(_Player, _maxHealth):	#When enemy is created, add all 
	Player=_Player
	maxHealth=_maxHealth
	HP = maxHealth
	
	
func move(delta):	#Overwrite to add specific enemy movement
	pass
	
func attack(delta):	 #Acts as shooting
	pass
	
func _process(delta):
	playerDirection=(Player.get_global_position()-get_global_position()).normalized()
	
	attack(delta)
	move(delta)
	
func EnemySpin(facingDirection : Vector2):
	var rotationFrame : int = roundi(((facingDirection.angle() + PI) * 4)/ PI);
	if rotationFrame > 7:
		rotationFrame -= 8
	return rotationFrame
	

func GetHurt(damage:int):
	pass

func onDeath():
	queue_free()



