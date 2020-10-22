extends Object

#Features shared for MOST of the entities

const FLOAT_TOLERANCE: float = 0.005; #near insignificant error for float

var father_node: Node2D;
var init_pos: Vector2;
var init_global_pos: Vector2;
var init_rotation: float; #Radians
var init_global_rotation: float; # Radians

func _init(node: Node2D):
	father_node = node;

func _ready():
	init_pos = father_node.position;
	init_global_pos = father_node.global_position;
	init_rotation = father_node.rotation;
	init_global_rotation = father_node.global_rotation;

func position_can_be_reached(pos: Vector2, exclude_nodes: Array) -> bool:
	var self_global_position: Vector2 = father_node.global_position;
	var vector_to_point: Vector2 = pos - self_global_position;
	var space_state = father_node.get_world_2d().direct_space_state;
	var result = space_state.intersect_ray(self_global_position, self_global_position+vector_to_point, exclude_nodes, father_node.collision_mask);
	if result:
		return false;
	else:
		return true;

func node_can_be_reached(node: Node2D, exclude_nodes: Array) -> bool:
	return position_can_be_reached(node.global_position, exclude_nodes);

func player_can_be_reached(exclude_nodes: Array = [father_node, Game.Player]) -> bool:
	return node_can_be_reached(Game.Player, exclude_nodes);

func floatsAreNearEqual(f1: float, f2: float):
	if abs(f1-f2) <= FLOAT_TOLERANCE:
		return true;
	else:
		return false;

func vectorsAreNearEqual(v1: Vector2, v2: Vector2):
	return (v1-v2).length_squared() <= FLOAT_TOLERANCE;

func move_with_initial_acceleration(delta: float, max_speed: float, accel_time: float, start: Vector2, end:Vector2) -> void:
	var speed_mult_vec: Vector2 = (end-start).normalized();
	var move_velocity: Vector2;
	var current: Vector2 = father_node.position;
	
	#Get movement velocity
	if accel_time <= 0.0:
		move_velocity = max_speed*speed_mult_vec;
	else:
		var hmid: float = (end-start).length()/2.0;
		var h: float = hmid - abs(hmid -(end-current).length());
		var v: float = sqrt(abs(2.0*h*max_speed))/accel_time;
		v = clamp(v, 1.0, max_speed); #clamp is vital because this function is based on velocity and not time!! 
		move_velocity = v*speed_mult_vec;
	
	#Normalize position to avoid bugs
	var new_pos: Vector2 = current + move_velocity*delta;
	var normalized_pos: Vector2 = new_pos;
	if ((current.x <= end.x) && (new_pos.x > end.x)) || ((current.x >= end.x) && (new_pos.x < end.x)):
		normalized_pos.x = end.x;
	if ((current.y <= end.y) && (new_pos.y > end.y)) || ((current.y >= end.y) && (new_pos.y < end.y)):
		normalized_pos.y = end.y;
	
	# do the movement
	father_node.position = normalized_pos;
