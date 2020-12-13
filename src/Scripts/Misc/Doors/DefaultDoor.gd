class_name Door
extends Node2D

export var manual: bool = true;

#Netcode stuff start
var netid: int = -1;
var node_id: int = -1
enum NET_EVENTS {
	ATTACK,
	OPENED,
	CLOSED 
};
#Netcode stuff ends

func _ready():
	if manual:
		$TriggerAutomatic.call_deferred("queue_free");
		Game.Network.register_synced_node(self);
	else:
		$TriggerManual.call_deferred("queue_free");

func toggle():
	if $Closed.visible:
		open(true);
	else:
		close(true);

func open(send_net_event: bool = false):
	if manual && send_net_event:
		Game.Network.net_send_event(self.node_id, NET_EVENTS.OPENED, null);
	$Closed.hide();
	$Open.show();
	$Closed/StaticEntity.disable_collisions();

func close(send_net_event: bool = false):
	if manual && send_net_event:
		Game.Network.net_send_event(self.node_id, NET_EVENTS.CLOSED, null);
	$Closed.show();
	$Open.hide();
	$Closed/StaticEntity.enable_collisions();

func server_process_event(eventId : int, eventData) -> void:
	match eventId:
		NET_EVENTS.OPENED:
			open();
		NET_EVENTS.CLOSED:
			close();
		_:
			print("Warning: Received unkwown event");

func client_process_event(eventId : int, eventData) -> void:
	match eventId:
		NET_EVENTS.OPENED:
			open();
		NET_EVENTS.CLOSED:
			close();
		_:
			print("Warning: Received unkwown event");

# TO AVOID CRASH IN RELEASE BUILD!
func _exit_tree():
	Game.Network.unregister_synced_node(self); #solve problem by now
