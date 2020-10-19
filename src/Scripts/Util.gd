extends Object

#Features shared for MOST of the entities

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
