extends KinematicBody2D

export(Array, Vector2) var positions: Array;
export var speed: float = 100.0;
export var acel_time: float = 1.0;

var current_pos_index: int = 0;
var next_pos_index: int = 0;
var Util = Game.Util_Object.new(self);

func _ready():
	Util._ready();
	positions.push_front(position);

func _physics_process(delta):
	if (current_pos_index != next_pos_index):
		Util.move_with_initial_acceleration(delta, speed, acel_time, positions[current_pos_index], positions[next_pos_index]);
		if Util.vectorsAreNearEqual(position, positions[next_pos_index]):
			next_pos_reached();

func move_to_pos(new_pos_index: int):
	if new_pos_index < 0 || new_pos_index >= positions.size(): 
		new_pos_index = 0;
	next_pos_index = new_pos_index;

func next_pos_reached():
	current_pos_index = next_pos_index;
