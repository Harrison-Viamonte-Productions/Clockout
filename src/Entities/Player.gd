class_name Player
extends KinematicBody2D

const MOVE_SPEED = 150.0
const FLOOR_DETECT_DISTANCE = 20.0

onready var floor_detector := $FloorDetector
onready var sprite := $Sprite
onready var camera := $Camera

var current_velocity := Vector2.ZERO

func _ready():
	pass

func _process(delta):
	var is_on_floor = floor_detector.is_colliding()
	var direction = (Input.is_action_pressed("move_right") as int - Input.is_action_pressed("move_left") as int)
	if direction != 0:
		sprite.scale.x = direction
	current_velocity = move_and_slide_with_snap(
		Vector2(direction * MOVE_SPEED, 0),
		Vector2.DOWN * FLOOR_DETECT_DISTANCE,
		Vector2.UP,
		floor_detector.is_colliding(),
		4,
		0.9,
		false)
