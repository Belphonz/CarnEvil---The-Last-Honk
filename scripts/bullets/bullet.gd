extends CharacterBody2D

var damage : float
var speed : float = 200
var maxBounceCount : int = 10
var bounceCount : int = 0
var isPlayerBullet : bool 
var direction
var allEntities = ["ClownAK47", "Player"]
var allHazards = ["NailHazard"]
var confettitimer : float = 0
var confettifrequency : float = 0.03

func _ready():
	velocity = direction * speed
	var PlayerSp = get_child(0) as Sprite2D
	var EnemySp = get_child(1) as Sprite2D
	var PlayerColl = get_child(2) as CollisionShape2D
	var EnemyColl = get_child(3) as CollisionShape2D
	var EnemyArea=get_node("Area2D/EnemyArea") as CollisionShape2D
	var PlayerArea=get_node("Area2D/PlayerArea") as CollisionShape2D
	PlayerSp.visible = isPlayerBullet
	EnemySp.visible = !isPlayerBullet
	PlayerColl.disabled = !isPlayerBullet
	EnemyColl.disabled = isPlayerBullet
	EnemyArea.disabled=isPlayerBullet
	PlayerArea.disabled=!isPlayerBullet
	
func death():	
	queue_free()
	
func bouncemethod(direction):
	velocity = velocity.bounce(direction)
	
func basicbounce(delta):
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		if isPlayerBullet :
			if "Enemy" in collision_info.get_collider().name or collision_info.get_collider().name in allEntities:
				death()
		else:
			if collision_info.get_collider().name == "Player":
				death()
		if "Bouncy" in collision_info.get_collider().name:
			bouncemethod(collision_info.get_normal())
		elif not "Bullet" in collision_info.get_collider().name and not "Enemy" in collision_info.get_collider().name:
			bounceCount += 1
			bouncemethod(collision_info.get_normal())
		else:
			global_position += velocity * delta
	if bounceCount == maxBounceCount:
		death()

func createtrail(delta):
	if confettitimer > confettifrequency and isPlayerBullet:
		var trail : Node2D = preload("res://elements/Player/ConfettiTrail.tscn").instantiate()
		trail.global_position = global_position
		get_parent().get_node("BloodsplatterNode").add_child(trail)
		confettitimer = 0

func _physics_process(delta):
	basicbounce(delta)
	createtrail(delta)
	confettitimer += delta
	


