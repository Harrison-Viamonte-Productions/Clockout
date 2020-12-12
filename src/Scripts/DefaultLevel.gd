extends Node2D

var MainMenuScene: PackedScene = preload("res://src/GUI/MainMenu.tscn");
export var map_limit_start: Vector2 = Vector2.ZERO;
export var map_limit_end: Vector2 = Vector2.ZERO;
var already_loaded: bool = false;

func _enter_tree():
	Game.CurrentMap = self;
	Game.SpawnPoints.clear();
	Game.new_map_loaded();
	print("I reach this...");

func _ready():
	
	for p in Game.Players:
		if p:
			Game.spawn_player(p);

	self.already_loaded = true;
	Game.Network.map_is_loaded();
	Game.MainMenu = MainMenuScene.instance();
	Game.MainMenu.set_ingame_mode();

func get_world_limits() -> Dictionary:
	var limits: Dictionary = {
		"start": map_limit_start,
		"end": map_limit_end
	};
	return limits;	

# TO AVOID CRASH IN RELEASE BUILD!
func _exit_tree():
	if Game.CurrentMap == self:
		Game.CurrentMap = null;
