extends Area2D

export var call_function_enter: String;
export var call_args_enter: Array = [];
export var call_function_exit: String;
export var call_args_exit: Array = [];
export var node_caller: String = "$CurrentMap";
export var activated_by: String = "$Player" ;
export var trigger_once: bool = false;
export var wait_time: float = 0.0; #Time until the trigger can be called again
export var delay: float = 0.0; #Time until the trigger can be called again

var activatedBy: Node;
var nodeCaller: Node;
var trigger_enabled: bool = true;

onready var tween = $Tween;

func get_node_by_string(node_string: String) -> Node:
	
	var nodeReturn: Node;
	
	match(node_string):
		#shorthands first
		"$CurrentMap": 
			nodeReturn = Game.CurrentMap;
		"$Player":
			nodeReturn = Game.Player;
		"$Self":
			nodeReturn = self;
		"$Parent":
			nodeReturn = self.get_parent();
		_:
			nodeReturn = get_tree().get_node(NodePath(node_string));
	return nodeReturn;

func _ready():
	if call_function_enter.length() > 1 || call_function_exit.length() > 1:
		nodeCaller = get_node_by_string(node_caller); # By default
		activatedBy = get_node_by_string(activated_by); # By default

		if call_function_enter.length() > 1:
			if has_node_type(activatedBy, PhysicsBody2D):
				self.connect("body_entered", self,  "on_body_entered");
			else:
				self.connect("area_entered", self,  "on_area_entered");
				
		if call_function_exit.length() > 1:
			if has_node_type(activatedBy, PhysicsBody2D):
				self.connect("body_exited", self, "on_body_exited");
			else:
				self.connect("area_exited", self,  "on_area_exited");

func has_node_type(nodeEntity: Node, nodeType):
	if nodeEntity is nodeType:
		return true;
	
	var children_of_node = nodeEntity.get_children();
	for child in children_of_node:
		if has_node_type(child, nodeType):
			return true;
		
	return false;

func disconnect_method(action_name: String):
	if self.is_connected(action_name, self, "on_" + action_name):
		self.disconnect(action_name, self, "on_" + action_name);

func on_body_entered(body):
	if body == activatedBy :
		node_call_function(call_function_enter, call_args_enter, delay);
		if trigger_once:
			disconnect_method("body_entered");
		
func on_area_entered(area):
	if area == activatedBy:
		node_call_function(call_function_enter, call_args_enter, delay);
		if trigger_once:
			disconnect_method("area_entered");

func on_body_exited(body):
	if body == activatedBy:
		node_call_function(call_function_exit, call_args_exit, delay);
		if trigger_once:
			disconnect_method("body_exited");
		
func on_area_exited(area):
	if area == activatedBy:
		node_call_function(call_function_exit, call_args_exit, delay);
		if trigger_once:
			disconnect_method("area_exited");

func node_call_function(call_function: String, call_args: Array, call_delay: float):
	if !trigger_enabled:
		return;
	
	if wait_time > 0.0:
		trigger_enabled = false;
		if tween.is_active():
			tween.remove(self, "enable_trigger");
		tween.interpolate_callback(self, wait_time, "enable_trigger");
		tween.start();

	if call_delay > 0.0:
		var array_data: Array = convert_array_args_to_tween_args(call_args);
		if tween.is_active():
			tween.remove(nodeCaller, call_function);
		tween.interpolate_callback(nodeCaller, call_delay, call_function, array_data[0], array_data[1], array_data[2], array_data[3], array_data[4]);
		tween.start();
	else:
		nodeCaller.callv(call_function, call_args);

func enable_trigger():
	trigger_enabled = true; 

func convert_array_args_to_tween_args(array_args: Array) -> Array:
	var tween_array: Array = [];
	for i in range(5):
		tween_array.append(null);
		
	for i in range(array_args.size()):
		if i >= 5:
			break;
		tween_array[i] = array_args[i];
	return tween_array;
