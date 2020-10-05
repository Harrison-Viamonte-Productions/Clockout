class_name Player
extends KinematicBody2D

const GRAVITY = 400.0

const ACCELERATION = 8
const MOVE_SPEED = 300.0

const JUMP_SPEED = 950.0
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
	pass

func _physics_process(delta):
	var time = OS.get_ticks_msec()

	var direction = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		direction.x = 1
		sprite.scale.x = 1
	if Input.is_action_pressed("move_left"):
		direction.x = -1
		sprite.scale.x = -1

	var target = direction * MOVE_SPEED

	if is_on_floor():
		jump_count = 0
	elif jump_count == 0:
		jump_count = 1

	if Input.is_action_just_pressed("jump") and (is_on_floor() or jump_count < MAX_JUMPS) and time > next_jump_time:
		target.y -= JUMP_SPEED
		jump_count += 1
		next_jump_time = time + JUMP_DELAY_MS
		jump_add_time_ms = time + JUMP_ADD_DURATION_MS
	elif jump_count > 0 and time < jump_add_time_ms and Input.is_action_pressed("jump"):
		target.y -= JUMP_SPEED

	target.y += GRAVITY

	var new_velocity = velocity.linear_interpolate(target, ACCELERATION * delta)
	velocity = move_and_slide(new_velocity, Vector2.UP, not is_on_floor(), 4, 0.9, false)
