extends Node2D

######################################################################################################################################
# IMPORTANT STUFF FFS: GODOT BUILD RELEASE IS GOING TO CRASH IF AN ENTITY WAS FREED (QUEUE_FREE)
# BUT STILL IS REFERENCED BY SOME ARRAY IN THE SINGLETONS, SO IMPORTANT TO USE _EXIT_FREE TO REMOVE ANY REFERENCE FROM THAT ENTITY
# FROM THE ARRAY'S SINGLETONS OR ANY OTHER REFERENCE...
# THANK YOU GODOT FOR NOT CRASHING IN DEBUG AND NOT EVEN THROWING A WARNING/ERROR FOR THIS, THANK YOU SO MUCH, REALLY.
######################################################################################################################################

const GRAVITY: float = 1200.0
const VERSION: String = "0.1.5"; #Major, Minor, build count
const LANG_FILES_FOLDER: String = "lang";
const CONFIG_FILE: String = "game_config.cfg";
const PLAYER_ATTACK_LAYER: int = 32;
const START_MAP: String = "res://src/Levels/DemoLevel.tscn";

var SpawnPoints: Array = [];
var Players: Array = [];
var CurrentMap: Node = null;
var GUI: Node = null;
var ActiveCamera: Camera2D = null;
var ViewportFX: Node = null; # Reference to the node that leads with transitions. Loaded per level
var MainMenu:Node = null;
var current_lang: String = "";

#Objects (to avoid using classes)
var Boop_Object = preload("res://src/Scripts/Netcode/Boop.gd");
var Util_Object = preload("res://src/Scripts/Util.gd");
var Lang = load("res://src/Scripts/Langs.gd").new();
var Config = load("res://src/Scripts/ConfigManager.gd").new();
var Network = load("res://src/Scripts/Netcode/NetBase.gd").new();
const PlayerNode = preload("res://src/Entities/Player.tscn");
# Game specific vars
var threatLevel: int = 0; # Maybe I want to move this into a different place later.

func _init():
	Lang.load_langs(LANG_FILES_FOLDER);
	Config.load_from_file(CONFIG_FILE);
	current_lang = Lang.get_langs()[0];
	self.call_deferred("update_settings");
	Players.resize(Network.MAX_PLAYERS);

func clear_players():
	Players.clear();
	Players.resize(Network.MAX_PLAYERS);

func _ready():
	Network.ready();

func _process(delta):
	self.pause_mode = Node.PAUSE_MODE_PROCESS; #So we can use functions
	
func set_active_camera(newCamera: Node):
	ActiveCamera = newCamera;
	ActiveCamera.current = true;
	print("set camera to: " + str(newCamera));

func print_warning(text: String):
	print("[WARNING] %s" % text);

func get_str(text: String) -> String:
	return Lang.get_str(text, current_lang);

func _input(event):
	if typeof(CurrentMap) == TYPE_NIL || typeof(MainMenu) == TYPE_NIL:
		return;
	
	if event is InputEventKey and Input.is_key_pressed(KEY_ESCAPE) && !event.is_echo():
		if MainMenu.is_inside_tree():
			close_menu();
		else:
			open_menu();

func pause() -> void:
	get_tree().paused = true;
	
func unpause() -> void:
	get_tree().paused = false;

func open_menu() -> void:
	if typeof(CurrentMap) != TYPE_NIL && typeof(MainMenu) != TYPE_NIL:
		CurrentMap.call_deferred("add_child", MainMenu);
	pause();

func close_menu() -> void:
	if typeof(CurrentMap) != TYPE_NIL && typeof(MainMenu) != TYPE_NIL:
		CurrentMap.call_deferred("remove_child", MainMenu);
	unpause();

func change_lang(new_lang: String):
	if Lang.lang_exists(new_lang):
		current_lang = new_lang;
		update_lang_strings();

func update_lang_strings():
	get_tree().call_group("has_lang_strings", "update_lang_strings");
	
func update_settings():
	OS.window_fullscreen = Config.get_value("fullscreen");
	OS.set_window_size(Config.get_value("resolution"));
	change_lang(Config.get_value("language"));

func save_settings():
	Config.save_to_file(CONFIG_FILE);

func get_closest_player_to(node: Node2D) -> Node2D:
	var closestPlayer: Node2D = null;
	var current_dist: float = float(Util_Object.BIG_INT); #Big number
	for Player in Players:
		if !Player:
			continue;
		var test_dist: float = node.global_position.distance_to(Player.global_position);
		if current_dist > test_dist:
			current_dist = test_dist;
			closestPlayer = Player;
	return closestPlayer;

func get_local_player() -> Node2D:
	return Players[Network.local_player_id]; #fix later

func add_player(netid: int, forceid: int = -1) -> Node2D:
	var free_player_index: int = 0;
	for i in range(Players.size()):
		if Players[i]:
			free_player_index += 1;
			if Players[i].netid == netid: #already exists this player
				print("The player %d with netid %d was already in the list!!" % [i, netid])
				return Players[i];
			continue;
		break;
	
	var player_instance = PlayerNode.instance();
	
	if forceid != -1:
		free_player_index = forceid;

	player_instance.node_id = free_player_index;
	player_instance.netid = netid;
	#Game.Network.register_synced_node(player_instance, player_instance.node_id);
	#Game.Network.netentities[player_instance.id] = player_instance;
	Players[free_player_index] = player_instance;
	print("Adding player %d with netid %d" % [free_player_index, netid]);
	return Players[free_player_index];

func start_new_game():
	Network.stop_networking();
	#CurrentMap = null;
	change_to_map(START_MAP);

func change_to_map(map_name: String):
	CurrentMap = null;
	close_menu();
	Network.change_map(map_name);
	#clear_players();
	get_tree().call_deferred("change_scene", map_name);

func spawn_player(player: Node2D):
	if player.is_inside_tree():
		print("The player %d was already spawned!!" % player.node_id)
		return;
	player.Spawn = SpawnPoints[0];
	player.position = SpawnPoints[0].position;
	player.z_index = SpawnPoints[0].z_index;
	player.z_as_relative = SpawnPoints[0].z_as_relative;
	player.Spawn.get_parent().call_deferred("add_child", player);

func get_current_map_path() -> String:
	return CurrentMap.filename;

func get_active_players() -> Array:
	var result: Array = [];
	for i in range(Players.size()):
		if Players[i]:
			result.append(Players[i]);
	return result;

func new_map_loaded() -> void:
	#clear_players();
	add_player(Network.SERVER_NETID);
	Network.add_clients_to_map();
	

# Netcode specific
remote func game_process_rpc(method_name: String, data: Array): 
	Network.callv(method_name, data);
