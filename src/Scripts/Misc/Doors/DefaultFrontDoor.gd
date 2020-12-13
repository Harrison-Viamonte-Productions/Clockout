class_name FrontDoor
extends AnimatedSprite

export var locked: bool = false;
export var call_function: String; #functions are called only in the current map
export var call_args: Array = [];
onready var tween: Tween = $Tween;

func _ready():
	update_trigger();

func update_trigger():
	if locked:
		$TriggerUse.disable_trigger();
	else:
		$TriggerUse.enable_trigger();

func activated():
	if Game.CurrentMap:
		Game.CurrentMap.callv(call_function, call_args);
		self.open();
func open():
	self.play("open");
	if tween.is_active():
		tween.remove(self, "close");
	tween.interpolate_callback(self, 3.0, "close"); #close after 3 seconds
	tween.start();

func close():
	self.play("close");
