class_name Player
extends KinematicBody2D

const GRAVITY = 900.0

const ACCELERATION = 8
const MOVE_SPEED = 300.0

const JUMP_SPEED = -400.0
const MAX_JUMPS = 3
const JUMP_DELAY_MS = 250
const JUMP_ADD_DURATION_MS = 250

onready var sprite := $Sprite
onready var camera := $Camera

var jump_count := 0
var jump_add_time_ms := 0
var next_jump_time := 0
var velocity := Vector2.ZERO

func _ready():
	Engine.set_target_fps(Engine.get_iterations_per_second())
	pass

func _physics_process(delta):
	update_velocity(delta)
	move_and_slide(velocity, Vector2.UP)

func update_velocity(delta):
	var time = OS.get_ticks_msec()
	jump(time)
	fall(delta)
	run()
	$Sprite.update_animation(velocity);

func fall(delta):
	velocity.y += GRAVITY*delta

func jump(time):
	if is_on_floor() or is_on_ceiling():
		jump_count = 0
		velocity.y = 0
	elif jump_count == 0:
		jump_count = 1
	
	if Input.is_action_just_pressed("jump") and (is_on_floor() or jump_count < MAX_JUMPS) and time > next_jump_time:
		velocity.y = JUMP_SPEED
		jump_count += 1
		next_jump_time = time + JUMP_DELAY_MS
		jump_add_time_ms = time + JUMP_ADD_DURATION_MS
	elif jump_count > 0 and time < jump_add_time_ms and Input.is_action_pressed("jump"):
		velocity.y = JUMP_SPEED

func run():
	velocity.x = 0;
	if Input.is_action_pressed("move_right"):
		velocity.x += MOVE_SPEED;
	if Input.is_action_pressed("move_left"):
		velocity.x -= MOVE_SPEED;
