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
var netentities: Array;

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
	clear();

func clear():
	player_count = 0;
	for i in range(MAX_PLAYERS):
		netentities.append(null); 

func _cutie_joined_ok():
	if !Game.is_network_master():
		Game.rpc_id(SERVER_NETID, "game_process_rpc", "server_process_client_question", [Game.get_tree().get_network_unique_id()]);

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
	Game.rpc_id(id_client, "game_process_rpc", "client_receive_answer", [{map_name = "res://src/Levels/DemoLevel.tscn"}]);

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

func join_server(ip: String):
	ip = ip.replace(" ", "");
	Game.get_tree().set_network_peer(null); #Destoy any previous networking session
	var host = NetworkedMultiplayerENet.new();
	print(host.create_client(ip, SERVER_PORT));
	Game.get_tree().set_network_peer(host);

# Some util funcs
func is_multiplayer() -> bool:
	return Game.get_tree().has_network_peer();
	
func is_client() -> bool:
	if !Game.get_tree().has_network_peer() || Game.get_tree().is_network_server():
		return false;
	return true;
	
func is_server() -> bool:
	if Game.get_tree().has_network_peer() && !Game.get_tree().is_network_server():
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
	if player_count <= 0:
		return;
	for entity in netentities:
		if entity && entity.has_method("server_send_snapshot"):
			entity.server_send_snapshot();
	
func client_send_snapshot() -> void:
	for entity in netentities:
		if entity && entity.has_method("client_send_snapshot"):
			entity.client_send_snapshot();

remote func client_process_snapshot(entityId, message) -> void:
	if entityId < netentities.size() && netentities[entityId]:
		if netentities[entityId].has_method("client_process_snapshot"):
			netentities[entityId].client_process_snapshot(message);
	#else: #Entity exists in server but not in client, lets spawn it
	#	register_sycned_node_by_typenum(nodeNum, entityId);

remote func server_process_snapshot(entityId, message) -> void:
	if entityId < netentities.size() && netentities[entityId]:
		if netentities[entityId].has_method("server_process_snapshot"):
			netentities[entityId].server_process_snapshot(message);

func send_rpc_id(id: int, method_name: String, args: Array) -> void:
	Game.callv("rpc_id", [id, "game_process_rpc", method_name, args]);

func send_rpc_unreliable_id(id: int, method_name: String, args: Array) -> void:
	Game.callv("rpc_unreliable_id", [id, "game_process_rpc", method_name, args])
	
func send_rpc(method_name: String, args: Array) -> void:
	Game.callv("rpc", ["game_process_rpc", method_name, args]);

func send_rpc_unreliable(method_name: String, args: Array) -> void:
	Game.callv("rpc_unreliable", ["game_process_rpc", method_name, args])

func register_synced_node(nodeEntity: Node, forceId = NODENUM_NULL ) -> void:
	var freeIndex = MAX_PLAYERS;

	if forceId >= 0:
		freeIndex = forceId;
		print("Forcing id: " + str(freeIndex));
	else:
		while netentities[freeIndex]:
			freeIndex+=1;

	nodeEntity.node_id = freeIndex;
	netentities[nodeEntity.node_id] = nodeEntity;

	print("Registering entity [ID " + str(freeIndex) + "] : " + nodeEntity.get_class());
