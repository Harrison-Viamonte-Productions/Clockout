extends "res://src/Scripts/Misc/TriggerBase.gd"

export var call_function_enter: String;
export var call_args_enter: Array = [];
export var call_function_exit: String;
export var call_args_exit: Array = [];
export var activated_by: String = "$Player" ;

var activatedBy: Node;

func update_trigger_data():
	.update_trigger_data();
	if call_function_enter.length() > 1 || call_function_exit.length() > 1:
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
