class_name Player
extends KinematicBody2D

const ACCELERATION: int = 8
const MOVE_SPEED: float = 200.0
const JUMP_SPEED: float = -450.0
const MAX_JUMPS: int = 2
const JUMP_DELAY_MS: int = 250
const JUMP_ADD_DURATION_MS: int = 750
const DAMAGE_PROTECTION_SEC: float = 1.5; #Seconds of damage protection

var jump_count : int = 0
var jump_add_time_ms : int = 0
var next_jump_time : int = 0
var velocity : Vector2  = Vector2.ZERO
var is_crouched: bool = false;
var damage_protection: bool = false;

export var health: int = 3;
var initial_health: int = 3;

onready var stand_collision_box: CollisionPolygon2D = $CollisionNormal
onready var crouch_collision_box: CollisionPolygon2D = $CollisionCrouch
onready var up_raycast: RayCast2D = $UpRayCast;
onready var up_raycast2: RayCast2D = $UpRayCast2;


var Spawn: Node2D = null;

func _enter_tree():
	Game.Player = self;

func _ready() -> void:
	initial_health = health;
	var mapLimits = Game.CurrentMap.get_world_limits();
	$Camera.update_limits(mapLimits.start, mapLimits.end);
	Game.set_active_camera($Camera);
	Engine.set_target_fps(Engine.get_iterations_per_second())
	update_gui()

func _physics_process(delta: float) -> void:
	update_velocity(delta)
	update_collision_box()
	move_and_slide(velocity, Vector2.UP)

func update_velocity(delta: float ) -> void:
	var time = OS.get_ticks_msec()
	jump(time, delta)
	fall(delta)
	run()
	crouch()
	$Sprite.update_animation(velocity, is_crouched);

func update_collision_box():
	if is_crouched && !stand_collision_box.disabled:
		stand_collision_box.disabled = true
		crouch_collision_box.disabled = false
	elif !is_crouched && stand_collision_box.disabled:
		stand_collision_box.disabled = false
		crouch_collision_box.disabled = true

func fall(delta: float) -> void:
	velocity.y += Game.GRAVITY*delta

func jump(time: int, delta: float) -> void:
	if is_on_floor() or is_on_ceiling():
		if is_on_floor():
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
		velocity.y += JUMP_SPEED*delta

func run() -> void:
	velocity.x = 0;
	if Input.is_action_pressed("move_right"):
		velocity.x += MOVE_SPEED;
	if Input.is_action_pressed("move_left"):
		velocity.x -= MOVE_SPEED;

func crouch() -> void:
	if Input.is_action_pressed("crouch"):
		is_crouched = true
		up_raycast.enabled = true
		up_raycast2.enabled = true;
	elif !up_raycast.is_colliding() && !up_raycast2.is_colliding():
		is_crouched = false
		up_raycast.enabled = false;
		up_raycast2.enabled = false;

func get_camera():
	return $Camera;

func respawn():
	self.global_position = Spawn.global_position;
	self.velocity = Vector2.ZERO;

func hurt_effect():
	velocity.y = JUMP_SPEED;
	move_and_slide(velocity, Vector2.UP);
	$AnimationPlayer.play("hurt");

func hurt(attacker: Node2D, damage: int):
	if damage_protection:
		return;
	health-= damage;
	update_gui();
	hurt_effect();
	enable_damage_protection();
	if health <= 0:
		killed(attacker);

func enable_damage_protection():
	damage_protection = true; #Protect the player from receiving damage for a moment
	var tween: Tween = $Tween;
	if tween.is_active():
		tween.remove(self, "disable_damage_protection");
	tween.interpolate_callback(self, DAMAGE_PROTECTION_SEC, "disable_damage_protection");
	tween.start();

func disable_damage_protection():
	$AnimationPlayer.play("idle");
	damage_protection = false;

func killed(attacker: Node2D):
	Game.GUI.info_message(attacker.DEATH_MESSAGE % "Player_name");
	respawn();
	health = initial_health;
	update_gui();

func update_gui():
	Game.GUI.update_health(health);
