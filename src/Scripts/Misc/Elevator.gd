extends KinematicBody2D

export(Array, Vector2) var floors_position: Array;
export var automatic: bool = true;
export var speed: float = 100.0;
export var acel_time: float = 1.0;
export var lights: bool = false;

var current_floor: int = 0;
var next_floor: int = 0;
var Util = Game.Util_Object.new(self);

func _ready():
	Util._ready();
	floors_position.push_front(position);
	update_lights();

func enable_lights():
	lights = true
	update_lights()

func disable_lights():
	lights = false;
	update_lights()
	
func update_lights():
	if lights:
		$Light.visible = true;
	else:
		$Light.visible = false;

func _physics_process(delta):
	if (current_floor != next_floor):
		move(delta);
		if Util.floatsAreNearEqual(position.x, floors_position[next_floor].x) && Util.floatsAreNearEqual(position.y, floors_position[next_floor].y):
			floor_reached();

func move_to_floor(new_floor: int):
	if new_floor < 0 || new_floor >= floors_position.size(): 
		new_floor = 0;
	next_floor = new_floor;
	
func move(delta):
	var move_velocity: Vector2 = get_velocity(delta);
	position = normalize_pos(position, position+move_velocity*delta);
	
func normalize_pos(old_pos: Vector2, new_pos: Vector2) -> Vector2:
	var normalized_pos: Vector2 = new_pos;
	if ((old_pos.x <= floors_position[next_floor].x) && (new_pos.x > floors_position[next_floor].x)) || ((old_pos.x >= floors_position[next_floor].x) && (new_pos.x < floors_position[next_floor].x)):
		normalized_pos.x = floors_position[next_floor].x;
	if ((old_pos.y <= floors_position[next_floor].y) && (new_pos.y > floors_position[next_floor].y)) || ((old_pos.y >= floors_position[next_floor].y) && (new_pos.y < floors_position[next_floor].y)):
		normalized_pos.y = floors_position[next_floor].y;
	return normalized_pos;

func get_velocity(delta) -> Vector2:
	var speed_mult_vec: Vector2 = (floors_position[next_floor]-floors_position[current_floor]).normalized();
	if acel_time <= 0.0:
		return speed*speed_mult_vec;
	else: #movement accelerated
		var hmid: float = distance_between_floors(next_floor, current_floor)/2.0;
		var h: float = hmid - abs(hmid - (floors_position[next_floor]-position).length());
		var v: float = sqrt(abs(2.0*h*speed))/acel_time;
		v = clamp(v, 1.0, speed); #clamp is vital because this function is based on velocity and not time!! 
		return v*speed_mult_vec;

func distance_between_floors(floor1: int, floor2: int):
	return (floors_position[floor1]-floors_position[floor2]).length();

func _on_player_enter():
	if automatic:
		$Trigger.trigger_enabled = false;
		move_to_floor(current_floor+1);

func floor_reached():
	current_floor = next_floor;
	$Trigger.trigger_enabled = true;

func _on_player_leave():
	pass;
