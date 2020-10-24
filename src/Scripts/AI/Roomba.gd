extends KinematicBody2D

const NAME: String = "Roomba";
const DEATH_MESSAGE: String = "#str1003";
const ATTACK_DAMAGE: int = 1;
const RUN_MULTIPLIER: float = 4.0;
const MOVE_SPEED: float = 75.0
const RAYCAST_CHECK_DELAY: float = 50.0; #msec
const CHECKATTACK_DELAY: float = 350.0; #msec
const ATTACK_DURATION: float = 2000.0; #msec
const VIEW_ENEMY_DISTANCE: Vector2 = Vector2(350.0, 300.0);
const RAYCAST_LENGTH: float = 35.0;
const JUMP_SPEED: float = -400.0;
const ACTIVE_OUTSIDE_SCREEN_TIME: float = 15.0#sec
const SIZE: Vector2 = Vector2(32.0, 32.0); #Useful for jump detection

export var walk_direction: float = 1.0;
export var never_dormant: bool = false;

var raycast_check_countdown = RAYCAST_CHECK_DELAY;
var attack_check_countdown = CHECKATTACK_DELAY;
var attacking_countdown = ATTACK_DURATION;
var outside_screen_countdown = ACTIVE_OUTSIDE_SCREEN_TIME;

var attacking: bool = false;
var player_inside_area: bool = false;
var Util = Game.Util_Object.new(self);
var active: bool = false;
var is_on_screen: bool = false;

var motion: Vector2 = Vector2.ZERO;

func _ready():
	$PlayerDetection.connect("body_entered", self, "_on_body_entered");
	$PlayerDetection.connect("body_exited", self, "_on_body_exited");
	$VisibilityNotifier2D.connect("screen_entered", self, "_on_enter_screen");
	$VisibilityNotifier2D.connect("screen_exited", self, "_on_exit_screen");
	Util._ready();
	update_sprite();
	$Sprite.play("walk");

func _physics_process(delta):
	if !active && !never_dormant:
		return;
	check_dormant(delta);
	check_collisions(delta);
	check_attacks(delta);
	check_damage(delta);
	fall(delta);
	move(delta);

func _on_enter_screen():
	active = true;
	is_on_screen = true;

func _on_exit_screen():
	is_on_screen = false;

func reset_countdowns():
	#raycast_check_countdown = RAYCAST_CHECK_DELAY;
	attack_check_countdown = CHECKATTACK_DELAY;
	attacking_countdown = ATTACK_DURATION;
	outside_screen_countdown = ACTIVE_OUTSIDE_SCREEN_TIME;

func check_dormant(delta):
	if never_dormant || is_on_screen:
		outside_screen_countdown = ACTIVE_OUTSIDE_SCREEN_TIME;
		return;
	outside_screen_countdown -= delta;
	if (outside_screen_countdown <= 0):
		set_inactive();

func set_inactive():
	$Sprite/RunParticles.emitting = false;
	reset_countdowns(); 
	active = false;

func fall(delta):
	if !self.is_on_floor():
		motion.y += Game.GRAVITY*delta;
	elif motion.y > 0.0:
		motion.y = 0.0;
		

func move(delta):
	motion.x = MOVE_SPEED*RUN_MULTIPLIER if attacking else MOVE_SPEED;
	motion.x *= walk_direction;
	self.move_and_slide(motion, Vector2.UP);

func check_collisions(delta):
	raycast_check_countdown-=delta*1000.0;
	if raycast_check_countdown <= 0:
		var current_global_position: Vector2 = global_position;
		current_global_position.y += (SIZE.y/2.0)-4.0; #4.0 for a margin
		var space_state = get_world_2d().direct_space_state;
		var result = space_state.intersect_ray(current_global_position, current_global_position+walk_direction*Vector2(RAYCAST_LENGTH, 0), [self], collision_mask);
		if result:
			#check if can jump
			if (can_jump_over(delta, current_global_position+walk_direction*Vector2(RAYCAST_LENGTH, 0))):
				motion.y = JUMP_SPEED;
			else:
				walk_direction = -walk_direction;
				update_sprite();
		 #Random in order to reduce the chances of all checks being called at the same frame, to improve performance
		raycast_check_countdown = rand_range(RAYCAST_CHECK_DELAY-20.0, RAYCAST_CHECK_DELAY+20.0);

func check_attacks(delta):
	if attacking:
		attacking_countdown-= delta*1000.0;
		if (attacking_countdown <= 0):
			attacking = false;
			$Sprite/RunParticles.emitting = false;
			update_sprite();
		return;

	attack_check_countdown-= delta*1000.0;
	if (attack_check_countdown <= 0):
		var vector_to_player: Vector2 = Game.Player.global_position - self.global_position;
		if (abs(vector_to_player.x) <= VIEW_ENEMY_DISTANCE.x && abs(vector_to_player.y) <= VIEW_ENEMY_DISTANCE.y && Util.player_can_be_reached()):
			if vector_to_player.x < 0:
				walk_direction = -1.0;
			else:
				walk_direction = 1.0;
			#motion.y = JUMP_SPEED;
			attacking_countdown = ATTACK_DURATION;
			attacking = true;
			update_sprite();
			$Sprite/RunParticles.emitting = true;
		#Random in order to reduce the chances of all checks being called at the same frame, to improve performance
		attack_check_countdown = rand_range(CHECKATTACK_DELAY-20.0, CHECKATTACK_DELAY+20.0);

func check_damage(delta):
	
	if !player_inside_area:
		return;
	Game.Player.hurt(self, ATTACK_DAMAGE);

func update_sprite():
	if attacking && $Sprite.animation != "attack":
		$Sprite.play("attack");
	elif !attacking && $Sprite.animation != "walk":
		$Sprite.play("walk");
	if walk_direction < 0.0 && $Sprite.scale.x < 0.0:
		$Sprite.scale.x = -$Sprite.scale.x;
	elif walk_direction > 0.0 && $Sprite.scale.x > 0.0:
		$Sprite.scale.x = -$Sprite.scale.x;

func _on_body_entered(body):
	if Game.Player == body:
		player_inside_area = true;
		_on_player_entered();
		
func _on_body_exited(body):
	if Game.Player == body:
		player_inside_area = false;
		_on_player_exited();

func _on_player_entered():
	pass;

func _on_player_exited():
	pass;

func can_jump_over(delta, pos: Vector2) -> bool:
	var max_jump_time: float = -JUMP_SPEED/(2*Game.GRAVITY);
	if (max_jump_time <= 0.0):
		return false; #negative time... should never happen.

	var current_global_position: Vector2 = global_position;
	var size_offset: Vector2 = Vector2((SIZE.x/2.0 - 4.0), (SIZE.y/2.0)-4.0); #4.0 added as a margin-error avoider
	var get_max_jump_height: float = 0.5*Game.GRAVITY*pow(max_jump_time, 2.0)+JUMP_SPEED*max_jump_time;
	var new_pos = Vector2(pos.x, pos.y+get_max_jump_height-size_offset.y);
	current_global_position.y = new_pos.y;
	#current_global_position += Vector2(-walk_direction*size_offset.x, -size_offset.y);

	var space_state = get_world_2d().direct_space_state;
	var result = space_state.intersect_ray(current_global_position, new_pos, [self], collision_mask);
	if result:
		return false;
	else:
		return true;
