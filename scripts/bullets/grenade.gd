extends Area2D

var _damage : float
var _explosionRadiusMultiplier:float
var _canDamageEnemies:bool
var _canDamageSelf:bool 
var _airTime:float
var _maxCurveHeight:float
var _fuseTime:float
var _explosionLifeTime:float

var _startThrow:Vector2
var _endThrow:Vector2

var _fuseTimer:float = 0
var _timeInAir:float = 0
var _explosionTimer:float=0
var _currentBombState = _bombStates.throw

var explosionArea:Area2D

enum _bombStates{
	throw,
	fuse,
	explode
}

var explosionSound:AudioStreamPlayer2D

func Throw(start:Vector2, end:Vector2):
	_startThrow = start
	_endThrow = end
	_currentBombState = _bombStates.throw
	global_position = start

# Called when the node enters the scene tree for the first time.
func _ready():
	explosionSound = get_node("Explosion")
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(_currentBombState == _bombStates.throw):	#Bomb has been thrown and is flying through the air
		_timeInAir += delta
		if(_timeInAir > _airTime):
			_currentBombState = _bombStates.fuse
			set_global_position(_endThrow)
		ArcThroughAir()
	elif(_currentBombState == _bombStates.fuse):	#Bomb is on the floor and is ticking down
		_fuseTimer += delta
		if(_fuseTimer > _fuseTime):
			_currentBombState = _bombStates.explode
			#Set the Explosion Size
			scale = scale * _explosionRadiusMultiplier
	elif(_currentBombState == _bombStates.explode):
		explosionSound.play()
		_explosionTimer += delta
		Explode()
		SetCollision()

		if(_explosionTimer >= _explosionLifeTime):
			queue_free()
	Animate()
			
func ArcThroughAir():
	var pointInCurve:float = _timeInAir/_airTime
	var position:Vector2 = lerp(_startThrow,_endThrow,pointInCurve)
	#Calculate y offset to add for curve	
	var yOffset:float = pointInCurve *- 4.0 * _maxCurveHeight * (1.0 - pointInCurve)	
	position.y += yOffset
	set_global_position(position)
	
func SetCollision():
	for Collider in get_children():
		if "ExplosionColliderFrame" in Collider.name:
			var explosionSprite : Node2D = get_node("GrenadeSprite")
			if str((explosionSprite as AnimatedSprite2D).frame) in Collider.name:
				Collider.visible = true
			else:
				Collider.visible = false
func Animate():
	var sprite = get_node("GrenadeSprite") as Node2D
	if _currentBombState == _bombStates.throw or _currentBombState == _bombStates.fuse:
		(sprite as AnimatedSprite2D).play("Idle",0,false)
	elif _currentBombState == _bombStates.explode:
		if not (sprite as AnimatedSprite2D).frame == 6:
			(sprite as AnimatedSprite2D).play("Attack", (1 / _explosionLifeTime ), false)
		else:
			(sprite as AnimatedSprite2D).pause()
		
	
func Explode():
	var allArea2Ds:Array = get_overlapping_areas()
	for area in allArea2Ds:
		if(area.name == "EnemyCollider" && _canDamageEnemies):	#Hit enemy
			if ("Clown" in area.get_parent().name && _canDamageSelf) or ("Clown" not in area.get_parent().name):
				area.get_parent()._health-= _damage
		if(area.name == "PlayerCollider"):	#Hit player
			if(!area.get_parent()._iFramesActive):
				var Player = area.get_parent()
				Player._health -= _damage
				Player._iFramesActive = true
				Player.LastHitBy = "Grenade"
				
				Player._inKnockBack = bool(int(true) * int(Player.EXPLOSION_DO_KNOCKBACK))
				var _playerDirection = (Player.get_global_position() - get_global_position()).normalized()
				Player.velocity = (_playerDirection * Player.EXPLOSION_KNOCKBACK_STRENGTH) * int(Player.EXPLOSION_DO_KNOCKBACK)
				Player._enemyKnockbackTimer = Player.EXPLOSION_KNOCKBACK_DURATION  * int(Player.EXPLOSION_DO_KNOCKBACK)
				Player._currentKnockBackFriction = Player.EXPLOSION_KNOCKBACK_FRICTION
	
