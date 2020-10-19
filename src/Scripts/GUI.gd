extends CanvasLayer

func _ready():
	$DialogSystem.visible = false;
	$MessageTimer.connect("timeout", self, "hide_message");
	Game.GUI = self;

func _process(delta):
	$CenterContainer/HBoxContainer/FPSLabel.text = "FPS: " + str(Engine.get_frames_per_second());

func hide_message():
	$DialogSystem/AnimationPlayer.play("hide_message");
	$MessageTimer.stop();

func display_message(message: String, time: float = 5.0):
	#$MessageTimer.stop();
	#$DialogSystem/Mensaje.text = message;
	#$DialogSystem/AnimationPlayer.play("show_message");
	#$MessageTimer.wait_time = time;
	#$DialogSystem.visible = true;
	$DialogSystem.show_message(message);
	
func message_showed():
	$MessageTimer.start();

func message_hided():
	$DialogSystem.visible = false;
