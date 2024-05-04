extends Node2D

const _leftDirection = [0,1,7]

var _player:Node2D = null		#Node2D
var _bloodSplat = preload("res://elements/Enemies/Bloodsplatter.tscn")
var _playerDirection: Vector2
var _health:float
var _maxHealth:float	
var _moveSpeed:float

var _movementBounceStrength:float
var _movementBounceAngle:float
var _movementBounceMaxHeight:float
var _movementBounceBounceYAxis:float

func Start(player, maxHealth):	 # Constructor
	_player = player
	_maxHealth = maxHealth
	_health = maxHealth
	
	
func Move(delta):	# Virtual Movement Function
	pass
	
func Attack(delta):	 # Virtual Attack Function
	pass
	
func _process(delta):
	_playerDirection =(_player.get_global_position()-get_global_position()).normalized()
	Attack(delta)
	Move(delta)

# Function which converts the angle the Enemy is Facing
# Into A Number which can be used to Animate the Enemies	
func EnemySpin(facingDirection : Vector2): 
	var rotationFrame : int = roundi(((facingDirection.angle() + PI) * 4)/ PI);
	if rotationFrame > 7:
		rotationFrame -= 8
	return rotationFrame

func GetHurt(damage:int): # Virtual Damage Function
	pass

func OnDeath(): # Virtual Death Function
	var BloodSplat : Node2D = _bloodSplat.instantiate()
	BloodSplat.global_position = global_position
	get_parent().get_parent().get_node("FloorDebris").add_child(BloodSplat)
	queue_free()
	
func Bounce():
	var sprite = get_child(0) as Node2D
	# rotates only sprite and flips if over the limit
	sprite.rotate(_movementBounceStrength * (PI/180))
	if sprite.rotation_degrees >= _movementBounceAngle or sprite.rotation_degrees <= -_movementBounceAngle:
		_movementBounceStrength = _movementBounceStrength * -1
		rotate(_movementBounceStrength * (PI/180))
	sprite.move_local_y(_movementBounceBounceYAxis, false)
	if sprite.position.y >= _movementBounceMaxHeight or sprite.position.y <= -_movementBounceMaxHeight:
		_movementBounceBounceYAxis = _movementBounceBounceYAxis * -1
		sprite.move_local_y(_movementBounceBounceYAxis, false)	
		
func _on_enemy_collider_area_entered(area):
	if "PlBullet" in area.name:
		area.Destruction()
		_health -= area._damage



