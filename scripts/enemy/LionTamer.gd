extends "res://scripts/enemy/BaseEnemy.gd"

@export
var _moveSpeed:float=40


@export var PHYSICAL_DAMAGE:float = 3

@export
var lionMaxHealth=1

var lionAlive:bool=true

var Lion:Node2D=null #TODO:When lion dies, find a way to signal lion, and de-reference Lion

func Start(_Player,_maxHealth,enemyID):
	super.start(_Player,_maxHealth)
	moveSpeed=_moveSpeed


func addLion(enemyID):
	Lion = preload("res://elements/enemies/Lion.tscn").instantiate()
	Lion.set_global_position(get_global_position()-Vector2(50,0))
	Lion.start(Player,lionMaxHealth)
	Lion.setTamer(self)
	Lion.name="Enemy Lion"+str(enemyID)
	get_parent().add_child(Lion)	#Add Lion to enemy manager

func freeTamer():	#Lion has died, do separate things for the tamer
	Lion=null
	lionAlive=false

func _process(delta):
	super._process(delta)
	if HP <= 0:
		onDeath()
	
	
func move(delta):
	var sprite = get_child(0) as Node2D
	if(!lionAlive):
		(sprite as AnimatedSprite2D).play("Sad",0,false)
		return
	bounce()
	var facingDirection = ((Player.global_position - global_position).normalized())
	if (sprite as AnimatedSprite2D).animation == "Idle":
		(sprite as AnimatedSprite2D).frame = EnemySpin(facingDirection) 
		if EnemySpin(facingDirection) in leftDirection:
			(sprite as AnimatedSprite2D).flip_h = true
		else:
			(sprite as AnimatedSprite2D).flip_h = false
	velocity+=moveSpeed * playerDirection
	(sprite as AnimatedSprite2D).play("Idle",0,false)
	move_and_slide()
	velocity=Vector2(0,0)
	
func attack(delta):
	pass

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
func onDeath():
	if Lion: 
		Lion.freeLion()
	var Blood : Node2D = BloodSplat.instantiate()
	Blood.global_position = global_position
	get_parent().get_parent().get_node("BloodsplatterNode").add_child(Blood)
	queue_free()		


func _on_enemy_collider_area_entered(area):
	if "PlBullet" in area.owner.name:
		var Bullet:Node2D=area.get_parent()
		Bullet.death()
		HP -= Bullet.damage
