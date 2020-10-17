extends CanvasLayer

func _ready():
	Game.GUI = self;

func _process(delta):
	$CenterContainer/HBoxContainer/FPSLabel.text = "FPS: " + str(Engine.get_frames_per_second());
