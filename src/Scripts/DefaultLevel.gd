extends Node2D

var MainMenuScene: PackedScene = preload("res://src/GUI/MainMenu.tscn");

func _ready():
	Game.MainMenu = MainMenuScene.instance();
	Game.MainMenu.set_ingame_mode();
