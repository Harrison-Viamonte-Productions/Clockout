extends CanvasLayer

func _ready():
	$MessageContainer.visible = false;
	$MessageTimer.connect("timeout", self, "hide_message");
	Game.GUI = self;

func _process(delta):
	$CenterContainer/HBoxContainer/FPSLabel.text = "FPS: " + str(Engine.get_frames_per_second());

func hide_message():
	$AnimationPlayer.play("hide_message");
	$MessageTimer.stop();

func display_message(message: String, time: float = 5.0):
	$MessageTimer.stop();
	$MessageContainer/HBoxContainer/PanelContainer/message_label.text = message;
	$AnimationPlayer.play("show_message");
	$MessageTimer.wait_time = time;
	$MessageContainer.visible = true;
	
func message_showed():
	$MessageTimer.start();

func message_hided():
	$MessageContainer.visible = false;
