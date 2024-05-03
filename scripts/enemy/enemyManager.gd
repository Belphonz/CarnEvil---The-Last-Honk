extends Node

var Player: Node2D


var jester
var cAK47
var rm
var lionTamer
var clown

var EnemyID = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	cAK47 = preload("res://elements/enemies/ClownWithAK47.tscn")
	rm = preload("res://elements/enemies/ringmaster.tscn")
	jester=preload("res://elements/enemies/jester.tscn")
	lionTamer=preload("res://elements/enemies/LionTamer.tscn")
	clown=preload("res://elements/enemies/Clown.tscn")
	Player=get_node("../Player")

	#spawnClownAK47(Vector2(100,100))
	#spawnRingmaster(Vector2(100,100))
	#spawnJester(Vector2(100,100))
	spawnLionTamer(Vector2(100,100))
	#spawnClown(Vector2(100,100))

func getEnemyCount():
	return get_child_count()
	
func spawnClownAK47(position:Vector2):
	var enemyInstanceNode:CharacterBody2D = cAK47.instantiate()
	enemyInstanceNode.set_global_position(position)
	enemyInstanceNode.start(Player,1)
	EnemyID += 1
	enemyInstanceNode.name = "Enemy ClownAK47" + str(EnemyID)
	add_child(enemyInstanceNode)
	
func spawnRingmaster(position:Vector2):
	var enemyInstanceNode:CharacterBody2D = rm.instantiate()
	enemyInstanceNode.set_global_position(position)
	EnemyID += 1
	enemyInstanceNode.Start(Player,1, EnemyID)
	enemyInstanceNode.name = "Enemy Ringmaster" + str(EnemyID)
	add_child(enemyInstanceNode)

func spawnJester(position:Vector2):
	var enemyInstanceNode=jester.instantiate()
	enemyInstanceNode.set_global_position(position)
	EnemyID+=1
	enemyInstanceNode.start(Player,1)
	enemyInstanceNode.name="Enemy Jester" + str(EnemyID)
	add_child(enemyInstanceNode)
	
func spawnLionTamer(position:Vector2):
	var enemyInstanceNode=lionTamer.instantiate()
	enemyInstanceNode.set_global_position(position)
	EnemyID+=1	#One for the tamer
	enemyInstanceNode.Start(Player,1,EnemyID)
	enemyInstanceNode.name="Enemy Lion Tamer" + str(EnemyID)
	EnemyID+=1	#One for the lion
	add_child(enemyInstanceNode)
	enemyInstanceNode.addLion(EnemyID)

func spawnClown(position:Vector2):
	var enemyInstanceNode=clown.instantiate()
	enemyInstanceNode.set_global_position(position)
	EnemyID+=1
	enemyInstanceNode.start(Player,1)
	enemyInstanceNode.name="Enemy Clown" + str(EnemyID)
	add_child(enemyInstanceNode)

