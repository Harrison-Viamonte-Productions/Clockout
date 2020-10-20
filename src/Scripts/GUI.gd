extends CanvasLayer

func _ready():
	$DialogSystem.visible = false;
	$InfoMessages/InfoMessage.visible = false
	$MessageTimer.connect("timeout", self, "hide_message");
	Game.GUI = self;

func _process(delta):
	$CenterContainer/HBoxContainer/VBoxContainer/FPSLabel.text = "FPS: " + str(Engine.get_frames_per_second());

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

func update_health(new_health: int):
	$CenterContainer/HBoxContainer/VBoxContainer/Health.text = "Health: %s" % str(new_health);

func info_message(msg: String, time: float = 5.0):
	$InfoMessages/InfoMessage.text = msg;
	$InfoMessagesAnims.play("info_message_show");
	$InfoMessages/InfoMessage.visible = true;
	var tween: Tween = $Tween;
	if tween.is_active():
		tween.remove(self, "info_message_hide");
	tween.interpolate_callback(self, time, "info_message_hide");
	tween.start();

func info_message_hide():
	$InfoMessagesAnims.play("info_message_hide");