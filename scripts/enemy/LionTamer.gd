extends "res://scripts/Enemy/BaseEnemy.gd"

@export var MAX_HEALTH:float = 1
@export var MOVE_SPEED:float = 40
@export var PHYSICAL_ATTACK_POWER:float = 3

@export var MOVEMENTBOUNCE_STRENGTH = 0.5
@export var MOVEMENTBOUNCE_ANGLE = 10
@export var MOVEMENTBOUNCE_MAX_HEIGHT = 1.5
@export var MOVEMENTBOUNCE_BOUNCEY = 0.2

var _lionAlive:bool = true
var Lion:Node2D = null

func Start(player,enemyID):
	super.Start(player,MAX_HEALTH)
	_moveSpeed = MOVE_SPEED
	_movementBounceStrength = MOVEMENTBOUNCE_STRENGTH
	_movementBounceAngle = MOVEMENTBOUNCE_ANGLE
	_movementBounceMaxHeight = MOVEMENTBOUNCE_MAX_HEIGHT
	_movementBounceBouncey = MOVEMENTBOUNCE_BOUNCEY
	AddLion(enemyID)


func AddLion(enemyID):
	Lion = preload("res://elements/Enemies/Lion.tscn").instantiate()
	Lion.set_global_position(get_global_position() - Vector2(50,0))
	Lion.start(_player)
	Lion.setTamer(self)
	Lion.name = "Enemy Lion" + str(enemyID)
	get_parent().add_child(Lion)	#Add Lion to enemy manager

func FreeTamer():	#Lion has died, do separate things for the tamer
	Lion = null
	_lionAlive = false

func _process(delta):
	super._process(delta)
	if _health <= 0:
		OnDeath()
	
	
func Move(delta):
	var sprite = get_child(0) as Node2D
	velocity += _moveSpeed * _playerDirection
	Animate()
	(sprite as AnimatedSprite2D).play("Idle",0,false)
	if(!_lionAlive):
		return
	move_and_slide()
	velocity = Vector2(0,0)
	
func Animate():
	var sprite = get_child(0) as Node2D
	if(!_lionAlive):
		(sprite as AnimatedSprite2D).play("Sad",0,false)
		return

	Bounce()
	var facingDirection = ((_player.global_position - global_position).normalized())
	if (sprite as AnimatedSprite2D).animation == "Idle":
		(sprite as AnimatedSprite2D).frame = EnemySpin(facingDirection) 
		if EnemySpin(facingDirection) in _leftDirection:
			(sprite as AnimatedSprite2D).flip_h = true
		else:
			(sprite as AnimatedSprite2D).flip_h = false
	
func Attack(delta): # Lion Tamer doesn't attack
	pass



func OnDeath():
	if Lion: 
		Lion.freeLion()
	super.OnDeath()	


func _on_enemy_collider_area_entered(area):
	if "PlBullet" in area.owner.name:
		var Bullet:Node2D=area.get_parent()
		Bullet.death()
		_health -= Bullet.damage
