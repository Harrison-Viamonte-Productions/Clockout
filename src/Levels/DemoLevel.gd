extends Node2D

export var map_limit_start: Vector2 = Vector2.ZERO;
export var map_limit_end: Vector2 = Vector2.ZERO;

var CameraPaths: Array;
onready var LevelStaticCamera = $Cameras/LevelCamera1; #Static camera used for camera_move_to

func _enter_tree():
	Game.CurrentMap = self;
	
func _ready():
	Game.ActiveCamera.update_limits(map_limit_start, map_limit_end);
	LevelStaticCamera.update_limits(map_limit_start, map_limit_end);
	CameraPaths = $Cameras/CameraPath.get_children();

func _on_player_outside():
	Game.ActiveCamera.change_zoom_interpolated(1.5, 0.5);

func _on_player_inside():
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
