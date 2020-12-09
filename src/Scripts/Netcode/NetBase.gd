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
	clear();
	Game.get_tree().connect("network_peer_connected", self, "_on_player_connected");
	Game.get_tree().connect("network_peer_disconnected", self, "_on_player_disconnect");
	Game.get_tree().connect("connected_to_server", self, "_cutie_joined_ok");
	
	var timer = Timer.new();
	timer.set_wait_time(SNAPSHOT_DELAY);
	timer.set_one_shot(false)
	timer.connect("timeout", self, "write_boop")
	Game.add_child(timer)
	timer.start()

func clear():
	clients_connected.clear();
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
	add_client(id);
	if is_server():
		var PlayerToSpawn: Node2D = Game.add_player(id);
		Game.spawn_player(PlayerToSpawn);

#Jim from ID please on_cutie_leave
func _on_player_disconnect(id):
	clients_connected.remove(find_client_number_by_netid(id));
	player_count-=1;

func add_client(netid: int):
	print("Adding client with at position %d with netid %d" % [clients_connected.size(), netid]);
	clients_connected.append({netId = netid, ingame = false})
	player_count+=1;
	
func find_client_number_by_netid(netid: int):
	for i in range(clients_connected.size()):
		if clients_connected[i].netId == netid:
			return i;
	
	return -1;

func find_player_number_by_netid(netid: int):
	for i in range(Game.Players.size()):
		if Game.Players[i] and Game.Players[i].netid == netid:
			return i;
	return -1;

func server_process_client_question(id_client: int):
	Game.rpc_id(id_client, "game_process_rpc", "client_receive_answer", [{map_name = "res://src/Levels/DemoLevel.tscn", player_number = find_player_number_by_netid(id_client)}]);

func client_receive_answer(receive_data: Dictionary):
	print("player number: %d, uniqueid: %d" % [receive_data.player_number, Game.get_tree().get_network_unique_id()]);
	#spawn the player in-game in the local machine :3
	Game.get_tree().change_scene(receive_data.map_name);
	Game.add_player(Game.get_tree().get_network_unique_id(), receive_data.player_number);

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
	add_client(SERVER_NETID); #adding server as friend client always
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
func write_boop() -> void:
	if !Game.get_tree().has_network_peer():
		return;

	if Game.get_tree().is_network_server():
		server_send_boop();
	else:
		client_send_boop();

func server_send_boop() -> void:
	if player_count <= 0:
		return;
	for entity in netentities:
		if entity && entity.has_method("server_send_boop"):
			entity.server_send_boop();
	
func client_send_boop() -> void:
	for entity in netentities:
		if entity && entity.has_method("client_send_boop"):
			entity.client_send_boop();

remote func client_process_boop(entityId, message) -> void:
	if entityId < netentities.size() && netentities[entityId]:
		if netentities[entityId].has_method("client_process_boop"):
			netentities[entityId].client_process_boop(message);
	#else: #Entity exists in server but not in client, lets spawn it
	#	register_sycned_node_by_typenum(nodeNum, entityId);

remote func server_process_boop(entityId, message) -> void:
	if entityId < netentities.size() && netentities[entityId]:
		if netentities[entityId].has_method("server_process_boop"):
			netentities[entityId].server_process_boop(message);

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
