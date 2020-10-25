extends "res://src/Scripts/Misc/TriggerBase.gd"

export var call_function: String;
export var call_args: Array = [];
export var show_message: bool = true;
var player_inside: bool = false;

func update_trigger_data():
	.update_trigger_data();
	if call_function.length() > 1:
		if has_node_type(Game.Player, PhysicsBody2D): #activated only by player
			self.connect("body_entered", self,  "on_body_entered");
			self.connect("body_exited", self, "on_body_exited")
		else:
			self.connect("area_entered", self,  "on_area_entered");
			self.connect("area_exited", self,  "on_area_exited");

func on_body_entered(body):
	if Game.Player == body:
		on_player_entered();

func on_body_exited(body):
	if Game.Player == body:
		on_player_exited();

func on_area_entered(area):
	if Game.Player == area:
		on_player_entered();

func on_area_exited(area):
	if Game.Player == area:
		on_player_exited();
		
func on_player_entered():
	if trigger_enabled && show_message:
		$UseMessage/AnimationPlayer.stop();
		$UseMessage/AnimationPlayer.play("show");
	player_inside = true;

func on_player_exited():
	if trigger_enabled && show_message:
		$UseMessage/AnimationPlayer.stop();
		$UseMessage/AnimationPlayer.play("hide");
	player_inside = false;

func trigger_activated():
	if show_message && (!trigger_enabled || trigger_once) :
		$UseMessage/AnimationPlayer.stop();
		$UseMessage/AnimationPlayer.play("hide");
	
	if trigger_once:
		disconnect_all_methods();

func enable_trigger():
	.enable_trigger();
	if player_inside && show_message:
		$UseMessage/AnimationPlayer.stop();
		$UseMessage/AnimationPlayer.play("show");

func _input(event):
	if !player_inside:
		return;
	if Input.is_action_just_pressed("use"):
		node_call_function(call_function, call_args, delay);

