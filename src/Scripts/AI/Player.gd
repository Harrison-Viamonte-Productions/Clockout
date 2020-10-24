class_name Player
extends KinematicBody2D

#Movement constants
const ACCELERATION: int = 8
const MOVE_SPEED: float = 200.0
const JUMP_SPEED: float = -450.0
const MAX_JUMPS: int = 2
const JUMP_DELAY_MS: int = 250
const JUMP_ADD_DURATION_MS: int = 750
const AIR_FRICTION: float = 25.0;
const FLOOR_FRICTION: float = 500.0;

# Other constants
const DAMAGE_PROTECTION_SEC: float = 1.5; #Seconds of damage protection
const SNAP_VECTOR: Vector2 = Vector2(0, 32.0);

var jump_count : int = 0
var jump_add_time_ms : int = 0
var next_jump_time : int = 0
var velocity : Vector2  = Vector2.ZERO
var is_crouched: bool = false;
var damage_protection: bool = false;
var is_jumping: bool = false;

#friction and impulse code
var was_on_floor: bool = false;
var velocity_impulse: Vector2 = Vector2.ZERO;
var last_floor_velocity: Vector2 = Vector2.ZERO;

onready var stand_collision_box: CollisionPolygon2D = $CollisionNormal
onready var crouch_collision_box: CollisionPolygon2D = $CollisionCrouch
onready var up_raycast: RayCast2D = $UpRayCast;
onready var up_raycast2: RayCast2D = $UpRayCast2;

#Export var
export var health: int = 3;
var initial_health: int = 3;

var Spawn: Node2D = null;

var Util = Game.Util_Object.new(self);

func _enter_tree():
	Game.Player = self;

func _ready() -> void:
	Util._ready();
	initial_health = health;
	var mapLimits = Game.CurrentMap.get_world_limits();
	$Camera.update_limits(mapLimits.start, mapLimits.end);
	Game.set_active_camera($Camera);
	Engine.set_target_fps(Engine.get_iterations_per_second())
	update_gui()

func _physics_process(delta: float) -> void:
	update_velocity(delta)
	update_collision_box()
	friction(delta)
	
	if !is_jumping:
		move_and_slide_with_snap(velocity + velocity_impulse, 32.0*Vector2.DOWN, 1*Vector2.UP);
	else:
		move_and_slide(velocity + velocity_impulse, Vector2.UP)

func friction(delta: float) -> void:
	if is_on_floor() || is_on_wall():
		velocity_impulse = Vector2.ZERO; #disable friction on floor and wall by now		
	
	if is_on_floor():
		last_floor_velocity = get_floor_velocity();
	elif was_on_floor && !is_on_floor():
		velocity_impulse = last_floor_velocity;
	was_on_floor = is_on_floor();

	var friction: float = FLOOR_FRICTION if (is_on_floor() || is_on_ceiling()) else AIR_FRICTION;
	if abs(velocity_impulse.x) <=  friction*delta:
		velocity_impulse.x = 0.0;
	elif velocity_impulse.x > 0.0:
		velocity_impulse.x -= friction*delta;
	elif  velocity_impulse.x < 0.0:
		velocity_impulse.x += friction*delta;
		
	if abs(velocity_impulse.y) <= friction*delta:
		velocity_impulse.y = 0.0;
	elif velocity_impulse.y > 0.0:
		velocity_impulse.y -= friction*delta;
	elif  velocity_impulse.y < 0.0:
		velocity_impulse.y += friction*delta;

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
	velocity.y += Game.GRAVITY*delta;


func jump(time: int, delta: float) -> void:
	if is_on_floor() or is_on_ceiling():
		if is_on_floor():
			jump_count = 0
		velocity.y = 0
		is_jumping = false;
	elif jump_count == 0:
		jump_count = 1
	
	if Input.is_action_just_pressed("jump") and (is_on_floor() or jump_count < MAX_JUMPS) and time > next_jump_time:
		is_jumping = true;

		velocity.y = JUMP_SPEED;
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
	Game.set_active_camera($Camera);
	
	if typeof(Spawn) != TYPE_NIL:
		self.global_position = Spawn.global_position;
	else:
		self.global_position = Util.init_global_pos;
		Game.print_warning("¡No PlayerSpawn found for respawning!");
		
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
	Game.GUI.info_message(Game.get_str(attacker.DEATH_MESSAGE) % ["Player_name", attacker.NAME]);
	respawn();
	health = initial_health;
	update_gui();

func update_gui():
	Game.GUI.update_health(health);
