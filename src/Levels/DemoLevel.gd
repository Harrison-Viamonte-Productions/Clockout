extends Node2D

export var map_limit_start: Vector2 = Vector2.ZERO;
export var map_limit_end: Vector2 = Vector2.ZERO;
export var night_time: bool = false; #just for testing

func _ready():
	Game.CurrentMap = self;
	Game.Player.update_camera_limits(map_limit_start, map_limit_end);
	night_time_test(night_time);

#For testing only, remove later
func night_time_test(is_night: bool):#if is_night:
	if is_night:
		$StaticEntities/CeilingLamp.enable_light();
		$StaticEntities/CeilingLamp2.enable_light();
		$StaticEntities/CeilingLamp3.enable_light();
		$CanvasModulate.color = Color(0.125, 0.125, 0.15);
		$Background/back1.modulate = Color(0.07, 0.07, 0.07);
		$Background/Back2.modulate = Color(0.2, 0.2, 0.2);
		$Background/Back3.modulate = Color(0.2, 0.2, 0.2);
		$Background/Back4.modulate = Color(0.2, 0.2, 0.2);
		$Background/Back5.modulate = Color(0.2, 0.2, 0.2);
