extends Node2D

const GRAVITY: float = 1200.0
const VERSION: String = "0.1.5"; #Major, Minor, build count

var Player: Node = null;
var CurrentMap: Node = null;
var GUI: Node = null;
var ActiveCamera: Camera2D = null;
var ViewportFX: Node = null; # Reference to the node that leads with transitions. Loaded per level
var MainMenu:Node = null;

#Objects (to avoid using classes)
var Util_Object = preload("res://src/Scripts/Util.gd");

func _process(delta):
	self.pause_mode = Node.PAUSE_MODE_PROCESS; #So we can use functions
	interpolate_colors(delta);
	
func interpolate_colors(delta):
	pass;

func set_active_camera(newCamera):
	ActiveCamera = newCamera;
	ActiveCamera.current = true;

func print_warning(text: String):
	print("[WARNING] %s" % text);


func get_data_from_json(filename: String):
	var file: File = File.new();
	assert(file.file_exists(filename), ("¡The file %s doesn't exists!" % filename));
	file.open(filename, File.READ); #Assumes the file exists
	var text = file.get_as_text();
	var data = parse_json(text);
	file.close();
	return data;


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
