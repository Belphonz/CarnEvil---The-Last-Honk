extends "res://scripts/Enemy/BaseEnemy.gd"

var Bullet:Node2D
@export
var attackSpeed:float=0.07
@export var BOMB_DAMAGE:float = 3
@export var PHYSICAL_DAMAGE:float = 3
@export
var firingTime:float=2.5
@export 
var cooldownTime:float = 4.0
@export
var _moveSpeed:float = 120
@export
var fireCone:float = 35 
@export
var fireChangeRate:float = 16.0

@export
var firingRange:float=120.0
@export
var rangeRange:float=80.0

var offset:float=0
var fireChange=fireChangeRate
var weaponActive:bool=true
var movingToRange:bool=true
var takeAim:bool=true

var attackTimer:float=0 		#Time between shots, time shooting continuously, time with weapon cooling down
var attackingTimer:float=0
var cooldownTimer:float=0

var bulletID = 0

var playerPos:Vector2 = Vector2(0,0)

@export var BULLET_BOUNCE_COUNT:int = 1
@export var BULLET_SPEED:float = 450.0

var animTimer:float = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
	if HP <= 0:
		onDeath()
	
	
	



func start(_Player, _maxHealth):
	super.start(_Player,_maxHealth)
	var animation = get_child(0) as AnimatedSprite2D
	animation.play("Idle",0,false)
	moveSpeed=_moveSpeed
	fireCone *= PI/180
	fireChange = 1/fireChangeRate * PI
	
func attack(delta):	#Function called every frame
	var shootPoint = get_child(1) as Node2D
	var aimAudio = get_child(2) as AudioStreamPlayer2D
	var shootAudio = get_child(3) as AudioStreamPlayer2D
	var animation = get_child(0) as AnimatedSprite2D
	var distFromPlayer:float=(Player.get_global_position().distance_to(get_global_position()))
	
	if(!weaponActive):	#If weapon is cooling down, handle cooldown timer, done before checking range as weapon will cooldown when 
		
		cooldownTimer+=delta
		if(cooldownTimer>cooldownTime):
			cooldownTimer=0
			attackingTimer=0
			weaponActive=true
			
	if(abs(distFromPlayer-firingRange)>rangeRange):	#
		attackTimer=0
		attackingTimer=0
		movingToRange=true
		takeAim=true
		animation.play("Idle",0,false)	
	else:
		movingToRange=false
		print(weaponActive)
			
	
	attackTimer+=delta	#Update timers
	attackingTimer+=delta;
	
	if (attackTimer >= attackSpeed && weaponActive && !movingToRange && aimAudio.playing == false && takeAim == true):
		aimAudio.play()
		animation.play("Aim",0,false)
		await aimAudio.finished
		
		playerPos = playerDirection
		takeAim = false
		shootAudio.play()
			
	
	animTimer += delta
	if animTimer >= attackSpeed && takeAim == false:
		if animation.animation == "Aim":
			animation.play("Fire",0,false)
		elif animation.animation == "Fire":
			animation.play("Aim",0,false)
		animTimer = 0
	
	if(attackTimer>=attackSpeed && weaponActive && !movingToRange && takeAim == false):
		var cosOffset:float=cos(offset)	#Get fire direction with offset
		var sinOffset:float=sin(offset)
		var attackDirection:Vector2=Vector2(cosOffset*playerPos.x-sinOffset*playerPos.y,sinOffset*playerPos.x+cosOffset*playerPos.y)
		shootPoint.rotation = attackDirection.angle()
		offset+=fireChange#Adjust offset
		
		if(abs(offset)>fireCone):	#Flip direction of bullet movement
			fireChange*=-1
			offset+=fireChange
		
		attackTimer=0
		var bulletInstance:CharacterBody2D = preload("res://elements/bullets/bullet.tscn").instantiate()
		bulletInstance.speed = BULLET_SPEED
		bulletInstance.direction = attackDirection
		bulletInstance.isPlayerBullet = false
		bulletInstance.rotation_degrees = shootPoint.rotation_degrees-90
		bulletInstance.damage=BOMB_DAMAGE
			
		bulletInstance.maxBounceCount = BULLET_BOUNCE_COUNT
		
		bulletID += 1
		bulletInstance.name = "EnBullet " + str(bulletID)
		
		bulletInstance.global_position = shootPoint.global_position + (attackDirection * 30)
		get_node("../../BulletObject").add_child(bulletInstance)	#Does same as before, but gets BulletObject
		#get_parent().get_parent().add_child(bulletInstance)
		
	if(attackingTimer>=firingTime):	#Weapon deactivates after firing for too long
		weaponActive = false
		takeAim = true
		animation.play("Idle",0,false)		

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

func move(delta):
	var sprite = get_child(0) as Node2D
	var distFromPlayer:float=(Player.get_global_position().distance_to(get_global_position()))
	var facingDirection = ((Player.global_position - global_position).normalized())
	if (sprite as AnimatedSprite2D).animation == "Idle":
		(sprite as AnimatedSprite2D).frame = EnemySpin(facingDirection) 
		if EnemySpin(facingDirection) in leftDirection:
			(sprite as AnimatedSprite2D).flip_h = true
		else:
			(sprite as AnimatedSprite2D).flip_h = false
	
	var direction:int=sign(distFromPlayer-firingRange)
	if weaponActive == false || movingToRange:
		if(abs(distFromPlayer-firingRange)<rangeRange):	##Enemy is at optimal range, don't move
			sprite.rotation = 0
			return
		velocity=playerDirection * moveSpeed * direction
		move_and_slide()
		bounce()
	if weaponActive == true:
		sprite.rotation = 0
		
func onDeath():
	var Blood : Node2D = BloodSplat.instantiate()
	Blood.global_position = global_position
	get_parent().get_parent().get_node("BloodsplatterNode").add_child(Blood)
	queue_free()




func _on_area_2d_area_entered(area):
	if "PlBullet" in area.owner.name:
		var Bullet:Node2D=area.get_parent()
		Bullet.death()
		HP -= Bullet.damage
		

