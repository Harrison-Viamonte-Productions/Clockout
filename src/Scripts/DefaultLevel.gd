extends Node2D

var MainMenuScene: PackedScene = preload("res://src/GUI/MainMenu.tscn");
export var map_limit_start: Vector2 = Vector2.ZERO;
export var map_limit_end: Vector2 = Vector2.ZERO;

func _enter_tree():
	Game.CurrentMap = self;

func _ready():
	Game.MainMenu = MainMenuScene.instance();
	Game.MainMenu.set_ingame_mode();

func get_world_limits() -> Dictionary:
	var limits: Dictionary = {
		"start": map_limit_start,
		"end": map_limit_end
	};
	return limits;
