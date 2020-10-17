extends Node2D

export var map_limit_start: Vector2 = Vector2.ZERO;
export var map_limit_end: Vector2 = Vector2.ZERO;

func _ready():
	Game.CurrentMap = self;
	Game.Player.update_camera_limits(map_limit_start, map_limit_end);
