extends KinematicBody2D


export var speed: float = 12.5
export var jump: float = 35
export var animationLenth: int = 32


var move: Vector2 = Vector2.ZERO
var gravity: float = 0
var antdelta: float = 960
var hitVect: Vector2 = Vector2.ZERO
var hitPwr: float = 0
var hitDecrece: float = 0
var hit: bool = false
var push: float = 0
var actif: bool = false
var entring: bool = true
var exiting: bool = false
var offsetDoor: Vector2 = Vector2(-8, 0)

signal end_lvl()

func _ready() -> void:
	position = get_node("/root/Level/Lvl/DoorEnter").position + offsetDoor
	$CollisionShape2D.disabled = true
	gravity = get_node('/root/Level/Gravity').gravity
	get_node('/root/Level/Play').connect("pressed", self, "Play")

func _process(delta: float) -> void:
	if entring:
		move_and_slide(Vector2(20,0), Vector2.UP)
		if position.x > get_node("/root/Level/Lvl/DoorEnter").position.x + animationLenth + offsetDoor.x:
			position = get_node("/root/Level/Lvl/DoorEnter").position + offsetDoor + Vector2(animationLenth, 0)
			entring = false
			$CollisionShape2D.disabled = false
	elif exiting:
		move_and_slide(Vector2(25,0))
		if position.x > get_node("/root/Level/Lvl/DoorExit").position.x + animationLenth + offsetDoor.x:
			exiting = false
			get_node('/root/Level/CardsEffect').queue_free()
			get_tree().paused = false
			get_node("/root/Level").pause_mode = Node.PAUSE_MODE_INHERIT
			emit_signal("end_lvl")
			queue_free()
	elif actif:
		Move(delta)
		move.x += push
	Animate()
	Life()
	move_and_slide(move * delta * antdelta, Vector2.UP)
	if position.y > 450:
		get_tree().change_scene("res://Scenes/GameOver.tscn")


func _input(event: InputEvent) -> void:
	pass

func Life():
	if Settings.GameSave.Health > 3:
		Settings.GameSave.Health = 3
	if Settings.GameSave.Health == 3:
		$Jacket.visible = true
		$Hat.visible = true
	if Settings.GameSave.Health == 2:
		$Jacket.visible = false
		$Hat.visible = true
	if Settings.GameSave.Health == 1:
		$Jacket.visible = false
		$Hat.visible = false
	if Settings.GameSave.Health < 1:
		get_tree().change_scene("res://Scenes/GameOver.tscn")

func Animate() -> void:
	if move.x > 0:
		$MainSprite.flip_h = false
		$Hat.flip_h = false
		$Jacket.flip_h = false
	elif move.x < 0:
		$MainSprite.flip_h = true
		$Hat.flip_h = true
		$Jacket.flip_h = true
	if !is_on_floor() and actif:
		PlayAnim("Jump")
	elif move.x != 0 or entring or exiting:
		if is_on_wall():
			PlayAnim('Sprotch')
		else:
			PlayAnim("Run")
	else:
		PlayAnim("Idle")


func PlayAnim(type: String) -> void:
	$MainSprite.play(type)
	$Hat.play(type)
	$Jacket.play(type)
	if type == 'Sprotch':
		if move.x > 0:
			$MainSprite.offset.x = 8
			$Hat.offset.x = 8
			$Jacket.offset.x = 8
		else:
			$MainSprite.offset.x = -8
			$Hat.offset.x = -8
			$Jacket.offset.x = -8
	else:
		$MainSprite.offset.x = 0
		$Hat.offset.x = 0
		$Jacket.offset.x = 0

func Gravitation(moveY: float) -> float:
	if is_on_floor() and moveY > 10:
		moveY = 10
	else:
		moveY += gravity
	if is_on_ceiling():
		moveY = gravity
	return moveY

func Move(delta) -> void:
	move.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	move.x *= speed
	if is_on_floor():
		if Input.is_action_just_pressed("ui_up"):
			move.y = -jump
	move.x += hitVect.x * hitPwr
	if hitPwr > 0:
		hitPwr -= hitDecrece * delta * antdelta
		if hitPwr < 0:
			hitPwr = 0
	move.y = Gravitation(move.y)

func Play():
	actif = true

func Contact(area: Area2D) -> void:
	if area.name == "HitArea":
		hitVect = (position - area.get_parent().position).normalized()
		hitPwr = area.get_parent().hitStr
		hitDecrece = area.get_parent().hitDecrece
		move.y = hitVect.y * hitPwr / 1.5
		Settings.GameSave.Health -= 1
	elif area.name == "DoorExit":
		position = get_node("/root/Level/Lvl/DoorExit").position + offsetDoor
		get_node("/root/Level/Lvl/DoorExit/DoorExitSpriteFront").play('Exit')
		get_node("/root/Level/Lvl/DoorExit/DoorExitSpriteBack").play('Exit')
		$CollisionShape2D.disabled = true
		$HitBox.monitorable = false
		$HitBox.monitoring = false
		move = Vector2.ZERO
		exiting = true
		actif = false
		get_node("/root/Level").pause_mode = Node.PAUSE_MODE_PROCESS
		get_node("/root/Level/CardsEffect").pause_mode = Node.PAUSE_MODE_STOP
		get_tree().paused = true


func Contact_node(body: Node) -> void:
	if body.filename == "res://prefabs/CardEffect/PF_MV_3.tscn":
		push += body.speed

func Exit_Contact_node(body: Node):
	if body.filename == "res://prefabs/CardEffect/PF_MV_3.tscn":
		push -= body.speed
		
