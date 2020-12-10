extends KinematicBody2D

export(Array, Vector2) var positions: Array;
export var speed: float = 100.0;
export var time: float = 0.0; #if used, it uses time by secs instead of speed
export var acel_time: float = 1.0;
export var start_on: bool = true;

var current_pos_index: int = 0;
var next_pos_index: int = 0;
var current_velocity: Vector2;

var Util = Game.Util_Object.new(self);

#Netcode stuff start
var netid: int = -1;
var node_id: int = -1
var NetBoop = Game.Boop_Object.new(self);
enum NET_EVENTS {
	MOVE_TO_POS,
	MAX_EVENTS 
};
#Netcode stuff ends

func _ready():
	Game.Network.register_synced_node(self);
	Util._ready();
	positions.push_front(position);
	current_velocity = Vector2(0.0, 0.0);
	if start_on:
		start();

func _physics_process(delta):
	if Game.Network.is_client():
		self.position += current_velocity*delta;
		return; #by now let's let the server do ALL the physics and shit.
	var old_pos = self.position;
	if (current_pos_index != next_pos_index):
		if (time <= 0.0):
			Util.move_with_initial_acceleration(delta, speed, acel_time, positions[current_pos_index], positions[next_pos_index]);
		else:
			Util.move_with_initial_accel_and_time(delta, time, acel_time, positions[current_pos_index], positions[next_pos_index]);
		if Util.vectorsAreNearEqual(position, positions[next_pos_index]):
			next_pos_reached();
	
	current_velocity = (self.position - old_pos)/delta;

func move_to_pos(new_pos_index: int):
	if Game.Network.is_client():
		Game.Network.client_send_event(self.node_id, NET_EVENTS.MOVE_TO_POS, new_pos_index);
		return;
	if new_pos_index < 0 || new_pos_index >= positions.size(): 
		new_pos_index = 0;
	if (new_pos_index == current_pos_index && next_pos_index != new_pos_index):
		current_pos_index = next_pos_index;
	next_pos_index = new_pos_index;

func next_pos_reached():
	if Game.Network.is_client():
		return; #by now let's let the server do ALL the physics and shit.
	current_pos_index = next_pos_index;
	move_to_pos(current_pos_index+1);

func start():
	if Game.Network.is_client():
		return; #by now let's let the server do ALL the physics and shit.
	move_to_pos(current_pos_index+1);

#############################
# NETCODE SPECIFIC RELATED ##
############################

func server_send_boop() -> void:
	# todo: some pre-check to see if sending the boop is really necessary
	var boopData = {
		 velocity = Vector2(),
		 position = Vector2(),
		 rotation = Vector2(),
		 current_pos = self.current_pos_index
	};
	 #stepify iis important to avoid that an insignificant varition of data can lead to a new boop/snapshot
	boopData.velocity = Util.stepify_vec2(self.current_velocity, 0.01);
	boopData.position = Util.stepify_vec2(self.position, 0.01);
	boopData.rotation = stepify(self.rotation, 0.01);
	if NetBoop.delta_boop_changed(boopData):
		Game.Network.send_rpc_unreliable("client_process_boop", [self.node_id, boopData]);

func client_process_boop(boopData) -> void:
	if !get_tree():
		return;
	self.current_velocity = boopData.velocity;
	self.position = boopData.position;
	self.rotation = boopData.rotation;
	self.current_pos_index = boopData.current_pos;

func server_process_event(eventId : int, eventData) -> void:
	match eventId:
		NET_EVENTS.MOVE_TO_POS:
			move_to_pos(eventData);
		_:
			print("Warning: Received unkwown event");
