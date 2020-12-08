extends Node2D

const GRAVITY: float = 1200.0
const VERSION: String = "0.1.5"; #Major, Minor, build count
const LANG_FILES_FOLDER: String = "lang";
const CONFIG_FILE: String = "game_config.cfg";
const PLAYER_ATTACK_LAYER: int = 32;

var Player: Node = null;
var CurrentMap: Node = null;
var GUI: Node = null;
var ActiveCamera: Camera2D = null;
var ViewportFX: Node = null; # Reference to the node that leads with transitions. Loaded per level
var MainMenu:Node = null;
var current_lang: String = "";

#Objects (to avoid using classes)
var Util_Object = preload("res://src/Scripts/Util.gd");
var Lang = load("res://src/Scripts/Langs.gd").new();
var Config = load("res://src/Scripts/ConfigManager.gd").new();
var Network = load("res://src/Scripts/Netcode/NetBase.gd").new();

# Game specific vars
var threatLevel: int = 0; # Maybe I want to move this into a different place later.

func _init():
	Lang.load_langs(LANG_FILES_FOLDER);
	Config.load_from_file(CONFIG_FILE);
	current_lang = Lang.get_langs()[0];
	self.call_deferred("update_settings");

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
			CurrentMap.call_deferred("remove_child", MainMenu);
			get_tree().paused = false;
		else:
			CurrentMap.call_deferred("add_child", MainMenu);
			get_tree().paused = true;

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

remote func game_process_rpc(method_name: String, data): 
	print("ruarua " + method_name);
	Network.call(method_name, data);
