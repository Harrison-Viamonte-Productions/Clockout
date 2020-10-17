extends Node2D

var Player: Node = null;
var CurrentMap: Node = null;
var GUI: Node = null;
var ActiveCamera: Camera2D = null;

func set_active_camera(newCamera):
	ActiveCamera = newCamera;
	ActiveCamera.current = true;
