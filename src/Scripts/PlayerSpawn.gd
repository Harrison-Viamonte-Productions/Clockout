extends Node2D

const PlayerNode = preload("res://src/Entities/Player.tscn");
var PlayerInstance = null;

func _enter_tree():
	PlayerInstance = PlayerNode.instance();
	Game.Player = PlayerInstance;

func _ready():
	PlayerInstance.Spawn = self;
	PlayerInstance.position = self.position
	PlayerInstance.z_index = self.z_index;
	PlayerInstance.z_as_relative = self.z_as_relative;
	get_parent().call_deferred("add_child", PlayerInstance)
	self.visible = false;
