extends "res://scripts/enemy/BaseEnemy.gd"

@export
var MOVE_SPEED :float=100

@export var BOMB_DAMAGE:float = 3
@export var PHYSICAL_DAMAGE:float = 3
@export 
var attackSpeed:float=2.0

@export
var throwDistance:float=64.0

@export
var changeDirectionTime:float=4

@export
var maxAngleChange:float=15.0

var grenade
var velocity

var attackTimer:float=0

var changeDirectionTimer:float=0
var moveDirection:Vector2
var attackanim : float = 0
var attacking : bool = false
var rng=RandomNumberGenerator.new()

func start(_Player, _maxHealth):
	super.Start(_Player,_maxHealth)
	_moveSpeed= MOVE_SPEED
	grenade=preload("res://elements/bullets/grenade.tscn")
	maxAngleChange*=PI / 180	#Convert angle to radians
	
	var startAngle=rng.randf()*2*PI	#Get move direction
	moveDirection=Vector2(cos(startAngle),sin(startAngle))
	
func _process(delta):
	super._process(delta)
	if attacking:
		attackanim += delta
	if _health <= 0:
		OnDeath()
	
	
func move(delta):
	changeDirectionTimer+=delta
	if(changeDirectionTimer>changeDirectionTime):
		changeDirectionTimer=0
		var startAngle=rng.randf()*2*PI	#Get move direction
		var cosAngle=cos(startAngle)
		var sinAngle=sin(startAngle)
		
		moveDirection=Vector2(cosAngle*moveDirection.x-sinAngle*moveDirection.y,sinAngle*moveDirection.x+cosAngle*moveDirection.y)	#Rotate move direction
	
	velocity = moveDirection * _moveSpeed
	var animation = get_child(0) as AnimatedSprite2D
	if(attacking and attackanim > 0.2):
		animation.frame = EnemySpin(moveDirection) 
		if EnemySpin(moveDirection) in _leftDirection:
			animation .flip_h = true
		else:
			animation.flip_h = false
		animation.play("Idle",0,false)
		attacking = false
		attackanim = 0
	bounce()
	global_position += velocity * delta
	super.Move(delta)
	
func attack(delta):
	var animation = get_child(0) as AnimatedSprite2D
	attackTimer+=delta
	if(attackTimer>attackSpeed):
		attackTimer=0
		var throwAngle:float=rng.randf()*2*PI	#Get throw direction
		var throwDirection:Vector2=Vector2(cos(throwAngle),sin(throwAngle))
		
		var grenadeI:Node2D=grenade.instantiate()
		grenadeI.damage = BOMB_DAMAGE
		grenadeI.throw(get_global_position(),get_global_position()+throwDirection*throwDistance)
		get_node("../../BulletObject").add_child(grenadeI)
		animation.play("Attack",0,false)
		attacking = true
		
@export var BOUNCEPOWER = 0.5
@export var DEGREES = 10
@export var BOUNCEHEIGHT = 1.5
@export var BOUNCEY = 0.2

func bounce():
	var sprite = get_child(0) as Node2D
	# rotates only sprite and flips if over the limit
	sprite.rotate(BOUNCEPOWER * (PI/180))
	if sprite.rotation_degrees >= DEGREES or sprite.rotation_degrees <= -DEGREES:
		BOUNCEPOWER = BOUNCEPOWER * -1
		rotate(BOUNCEPOWER * (PI/180))
	sprite.move_local_y(BOUNCEY, false)
	if sprite.position.y >= BOUNCEHEIGHT or sprite.position.y <= -BOUNCEHEIGHT:
		BOUNCEY = BOUNCEY * -1
		sprite.move_local_y(BOUNCEY, false)


func _on_enemy_collider_area_entered(area):
	if "PlBullet" in area.owner.name:
		_health -= 1
		var Bullet:Node2D=area.get_parent()
		Bullet.death()
