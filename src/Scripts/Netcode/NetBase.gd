extends Node

#player: cuties

const SNAPSHOT_DELAY = 1.0/30.0; #Msec to Sec
const MAX_PLAYERS:int = 4;
const SERVER_PORT:int = 27666;
const SERVER_NETID: int = 1;
var clients_connected: Array;
var player_count: int = 1;
const MAX_CLIENT_LATENCY: float = 0.4; #350ms
const MAX_MESSAGE_PING_BUFFER: int = 8; #Average from ammount
const NODENUM_NULL = -1;

var pings: Array; 
var client_latency: float = 0.0;
var ping_counter = 0.0;
var LevelScene: Node = null;
var local_player_id = NODENUM_NULL; # 0 = Server

func ready():
	clients_connected.clear();
	Game.get_tree().connect("network_peer_connected", self, "_on_player_connected");
	Game.get_tree().connect("network_peer_disconnected", self, "_on_player_disconnect");
	Game.get_tree().connect("connected_to_server", self, "_cutie_joined_ok");
	
	var timer = Timer.new();
	timer.set_wait_time(SNAPSHOT_DELAY);
	timer.set_one_shot(false)
	timer.connect("timeout", self, "write_snapshot")
	Game.add_child(timer)
	timer.start()

func _cutie_joined_ok():
	print("connected okidoki");
	if !Game.is_network_master():
		Game.rpc_id(SERVER_NETID, "game_process_rpc", "server_process_client_question", Game.get_tree().get_network_unique_id());

func _process(delta):
	if Game.get_tree().has_network_peer() && !Game.is_network_master():
		if ping_counter <=  0.0 || ping_counter > 2.0:
			client_send_ping(); #resend, just in case.
		ping_counter+=delta;

#Jim from ID please implement on_cutie_joined
func _on_player_connected(id):
	# Called on both clients and server when a peer connects. Send my info to it.
	clients_connected.append({netId = id, ingame = false})
	player_count+=1;

#Jim from ID please on_cutie_leave
func _on_player_disconnect(id):
	clients_connected.remove(id);

func server_process_client_question(id_client: int):
	print("ruaruarua");
	Game.rpc_id(id_client, "game_process_rpc", "client_receive_answer", {map_name = "res://src/Levels/DemoLevel.tscn"});

func client_receive_answer(receive_data: Dictionary):
	Game.get_tree().change_scene(receive_data.map_name);

func clear_players():
	var is_server: bool = false;
	for info in clients_connected:
		info.ingame = false;
		if info.netId == 1:
			is_server = true;
	if !is_server:
		clients_connected.append({netId = 1, ingame = false})

func client_send_ping():
	ping_counter = 0.0;
	Game.rpc_unreliable_id(SERVER_NETID, "server_receive_ping", Game.get_tree().get_network_unique_id());

remote func server_receive_ping(id_client):
	Game.rpc_unreliable_id(id_client, "client_receive_ping");

remote func client_receive_ping():
	pings.append(ping_counter);
	if pings.size() >= MAX_MESSAGE_PING_BUFFER:
		pings.pop_front();
	ping_counter = 0.0;
	var sum_pings: float = 0.0;
	for ping in pings:
		sum_pings+=ping;
	client_latency = sum_pings / float(pings.size());
	if typeof(LevelScene) != TYPE_NIL:
		LevelScene.update_latency();

func host_server(maxPlayers: int, mapName: String, serverPort: int = SERVER_PORT):
	Game.get_tree().set_network_peer(null); #Destoy any previous networking session
	var host = NetworkedMultiplayerENet.new();
	print(host.create_server(serverPort, maxPlayers));
	Game.get_tree().set_network_peer(host);
	Game.get_tree().change_scene(mapName);
	#Game.get_tree().set_network_master(SERVER_NETID);

func join_server(ip: String):
	ip = ip.replace(" ", "");
	Game.get_tree().set_network_peer(null); #Destoy any previous networking session
	var host = NetworkedMultiplayerENet.new();
	print(host.create_client(ip, SERVER_PORT));
	Game.get_tree().set_network_peer(host);
	#Game.get_tree().set_network_master(SERVER_NETID);

# Some util funcs
func is_client() -> bool:
	if !Game.get_tree().has_network_peer() || Game.get_tree().is_network_server():
		return false;
	return true;
	
func is_server() -> bool:
	if !Game.get_tree().is_network_server():
		return false;
	return true;
	
func is_local_player(playerEntity: Node) -> bool:
	if Game.get_tree().has_network_peer() && playerEntity.player_id != local_player_id:
		return false;
	return true;
	
# Snapshot stuff basic
func write_snapshot() -> void:
	if !Game.get_tree().has_network_peer():
		return;
		
	if Game.get_tree().is_network_server():
		server_send_snapshot();
	else:
		client_send_snapshot();

func server_send_snapshot() -> void:
	pass;
	
func client_send_snapshot() -> void:
	pass;
