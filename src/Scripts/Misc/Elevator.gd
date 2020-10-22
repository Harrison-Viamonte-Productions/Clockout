extends "res://src/Scripts/Misc/Platform.gd"

export var automatic: bool = true;
export var lights: bool = false;

func _ready():
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

func _on_player_enter():
	if automatic:
		$Trigger.trigger_enabled = false;
		move_to_pos(current_pos_index+1);

func next_pos_reached():
	#Something odd about godot. All functions that are not built-in 
	# are required to be called like this from the father if you want to.
	# But that is done automatically with built-in functions, like
	# _ready, _process, _physics_process, _init, etc...
	.next_pos_reached(); 
	
	$Trigger.trigger_enabled = true;

func _on_player_leave():
	pass;
