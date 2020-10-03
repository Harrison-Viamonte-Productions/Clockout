class_name Player
extends KinematicBody2D

const MOVE_SPEED = 150.0
const FALL_SPEED = 200.0
const JUMP_POWER = 500
const FLOOR_DETECT_DISTANCE = 20.0

onready var floor_detector := $FloorDetector
onready var sprite := $Sprite
onready var camera := $Camera

var current_jump_power := 0
var current_velocity := Vector2.ZERO

func _ready():
	pass

func _physics_process(delta):
	var is_on_floor = floor_detector.is_colliding()
	var move_direction = (Input.is_action_pressed("move_right") as int - Input.is_action_pressed("move_left") as int)
	if move_direction != 0: sprite.scale.x = move_direction

	var fall_direction = -1 if is_on_floor() and Input.is_action_just_pressed("jump") else 1

	var snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE if fall_direction == 1 else Vector2.ZERO

	current_velocity = move_and_slide_with_snap(
		Vector2(move_direction * MOVE_SPEED, fall_direction * MOVE_SPEED),
		snap_vector,
		Vector2.UP,
		not is_on_floor,
		4,
		0.9,
		false)
