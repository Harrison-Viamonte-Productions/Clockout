extends Node2D

export var map_limit_start: Vector2 = Vector2.ZERO;
export var map_limit_end: Vector2 = Vector2.ZERO;

var player_inside_storage: bool = false;
var is_night: bool = false;
var CameraPaths: Array;
onready var LevelStaticCamera = $Cameras/LevelCamera1; #Static camera used for camera_move_to

func _enter_tree():
	Game.CurrentMap = self;
	
func _ready():
	$Tiles/FuncTiles.visible = false;
	set_day();
	Game.ViewportFX = $Transitions;
	LevelStaticCamera.update_limits(map_limit_start, map_limit_end);
	CameraPaths = $Cameras/CameraPath.get_children();

func get_world_limits() -> Dictionary:
	var limits: Dictionary = {
		"start": map_limit_start,
		"end": map_limit_end
	};
	return limits;

func _on_player_outside():
	Game.ActiveCamera.change_zoom_interpolated(1.5, 0.5);

func _on_player_inside():
	if !player_inside_storage:
		Game.ActiveCamera.change_zoom_interpolated(1.0, 0.5);

func select_camera(cameraStr: String):
	var CameraPathNode: NodePath = NodePath(str(self.get_path()) + "/" + cameraStr);
	var CameraNode: Camera2D;
	CameraNode = get_node(CameraPathNode);
	CameraNode.current = true;
	Game.set_active_camera(CameraNode);

func camera_move_to(path_index: int, interpolated: bool = true):
	if Game.ActiveCamera != LevelStaticCamera:
		LevelStaticCamera.global_position = Game.ActiveCamera.global_position;
	LevelStaticCamera.move_to_node2d(CameraPaths[path_index], interpolated);
	Game.set_active_camera(LevelStaticCamera);

func reset_camera(interpolated: bool = false):
	Game.Player.get_camera().move_from_node2d(Game.ActiveCamera, Game.Player.get_camera().Util.init_pos);
	Game.set_active_camera(Game.Player.get_camera());

func show_message(msg: String, time: float) -> void:
	Game.GUI.display_message(msg, time);

#Playing around with the level, don't mind this.

func enter_building():
	Game.ViewportFX.fade_in_out(1.0, 0.5);
	var tween: Tween = $Tween;
	tween.interpolate_callback(self, 0.75, "entering_building_effect");
	tween.start();

func entering_building_effect():
	is_night = !is_night;
	if is_night:
		set_night();
	else:
		set_day();
	
	#Game.Player.respawn();
	player_inside_storage = true;
	$PlayerSpawn.global_position = $Entities/Misc/Teleport1.global_position;
	Game.Player.global_position = $Entities/Misc/Teleport1.global_position;
	#new Camera limits
	map_limit_start.x = 5888;
	map_limit_start.y = -928;
	map_limit_end.x = 9728;
	map_limit_end.y = 610;
	
	Game.ActiveCamera.update_limits(map_limit_start, map_limit_end);
	LevelStaticCamera.update_limits(map_limit_start, map_limit_end);

func set_night():
	$Lights.visible = true;
	$LightOcluders.visible = true;
	$CanvasModulate.color = Color("4e4e4e");
	$Mountains1/CanvasModulate.color = Color("4e4e4e");
	
func set_day():
	$Lights.visible = false;
	$LightOcluders.visible = false;
	$CanvasModulate.color = Color("e6e6e6");
	$Mountains1/CanvasModulate.color = Color("e6e6e6");
	
