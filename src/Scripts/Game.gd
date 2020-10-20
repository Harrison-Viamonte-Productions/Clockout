extends Node2D

const GRAVITY: float = 1200.0

var Player: Node = null;
var CurrentMap: Node = null;
var GUI: Node = null;
var ActiveCamera: Camera2D = null;
var ViewportFX: Node = null; # Reference to the node that leads with transitions. Loaded per level

#Objects (to avoid using classes)
var Util_Object = preload("res://src/Scripts/Util.gd");

func _process(delta):
	interpolate_colors(delta);
	
func interpolate_colors(delta):
	pass;

func set_active_camera(newCamera):
	ActiveCamera = newCamera;
	ActiveCamera.current = true;
