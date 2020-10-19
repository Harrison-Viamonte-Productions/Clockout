extends Node2D

var Player: Node = null;
var CurrentMap: Node = null;
var GUI: Node = null;
var ActiveCamera: Camera2D = null;

#Objects (to avoid using classes)
var Util_Object = preload("res://src/Scripts/Util.gd");

func set_active_camera(newCamera):
	ActiveCamera = newCamera;
	ActiveCamera.current = true;
