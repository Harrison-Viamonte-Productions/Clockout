extends Sprite

export var solid: bool = true;

var layer_mask = 0
var collision_mask = 0

func enable_collisions():
	$StaticBody2D.collision_mask = collision_mask;
	$StaticBody2D.collision_layer = layer_mask;
func disable_collisions():
	$StaticBody2D.collision_mask = 0;
	$StaticBody2D.collision_layer = 0;

func _ready():
	
	collision_mask = $StaticBody2D.collision_mask;
	layer_mask = $StaticBody2D.collision_layer;
	
	if !solid:
		disable_collisions();
