extends Node2D

func _enter_tree():
	Game.SpawnPoints.append(self);

func _ready():
	#PlayerInstance.Spawn = self;
	#PlayerInstance.position = self.position
	#PlayerInstance.z_index = self.z_index;
	#PlayerInstance.z_as_relative = self.z_as_relative;
	#get_parent().call_deferred("add_child", PlayerInstance)
	self.visible = false;
