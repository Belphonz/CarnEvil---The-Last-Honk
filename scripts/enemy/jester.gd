extends "res://scripts/Enemy/BaseEnemy.gd"

var nailHazard = preload("res://elements/hazards/nailHazard.tscn")
var bellBullet = preload("res://elements/bullets/jesterBell.tscn")

@export var MOVE_SPEED:float = 60
var velocity

@export var NAIL_DAMAGE:float = 3
@export var BELL_DAMAGE:float = 3
@export var PHYSICAL_DAMAGE:float = 3


@export
var zigzagAngle:float=1.0/6.0 * PI  	#1/6PI radians (30 degrees)
@export 
var zigTime:float=1	#How often it swaps between zig zag direction

@export
var attackSpeed:float=0.2
@export_range (0,1)
var nailChance:float=0.15

@export
var nailThrowDistance:float=128
@export
var bellThrowDistance:float=128


var zigLeft:bool=false	#Jester moves in a zig zag, are they zigging or zagging

var zigzagTimer:float=0.5	#Track how often zigLeft should swap

var attackTimer:float=0

var rng=RandomNumberGenerator.new()

func Start(_Player, _maxHealth):
	super.Start(_Player,_maxHealth)
	_moveSpeed = MOVE_SPEED

func _process(delta):
	super._process(delta)
	
	if(_health<=0):
		OnDeath()

func attack(delta):
	super.Attack(delta)
	attackTimer+=delta
	if(attackTimer>attackSpeed):
		attackTimer=0
		var throwAngle:float=rng.randf()*2*PI
		var throwDirection:Vector2=Vector2(cos(throwAngle),sin(throwAngle))
		if(rng.randf()<0.15):
			#Throw trap
			var NailHazard =nailHazard.instantiate()
			NailHazard.damage = NAIL_DAMAGE
			NailHazard.throw(get_global_position(),get_global_position()+throwDirection*nailThrowDistance)
			get_node("../../SpikeNode").add_child(NailHazard)
		else:
			
			#Throw bell
			var Bell=bellBullet.instantiate()
			Bell.damage = BELL_DAMAGE
			Bell.throw(get_global_position(),get_global_position()+throwDirection*bellThrowDistance)
			get_node("../../BulletObject").add_child(Bell)
			#get_parent().get_parent().get_child("BulletObject").add_child(Bell)
	
	
func move(delta):
	super.Move(delta)
	var sprite = get_child(0) as Node2D
	
	var angle:float=zigzagAngle * (-1 if zigLeft else 1)
	
	var cosAngle:float=cos(angle)
	var sinAngle:float=sin(angle)
	
	var moveDirection=Vector2(cosAngle*_playerDirection.x-sinAngle*_playerDirection.y,sinAngle*_playerDirection.x+cosAngle*_playerDirection.y)
	
	velocity = moveDirection * _moveSpeed
	global_position += velocity * delta
	
	var facingDirection = ((_player.global_position - global_position).normalized())
	if (sprite as AnimatedSprite2D).animation == "Default":
		(sprite as AnimatedSprite2D).frame = EnemySpin(facingDirection) 
		if EnemySpin(facingDirection) in _leftDirection:
			(sprite as AnimatedSprite2D).flip_h = false
		else:
			(sprite as AnimatedSprite2D).flip_h = true
	
	
	zigzagTimer+=delta	#Swa
	if(zigzagTimer>zigTime):
		zigLeft=!zigLeft
		zigzagTimer=0
	
	


func _on_enemy_collider_area_entered(area):
	if "PlBullet" in area.owner.name:
		var Bullet:Node2D=area.get_parent()
		Bullet.death()
		_health -= Bullet.damage
