extends "res://src/Scripts/StaticEntityDefault.gd"

export var light_on: bool = true;
export var light_broken: bool = false;

func _ready():
	update_light();

func update_light():
	$StaticBody2D/Light2D.enabled = light_on;
	if light_broken:
		if !$Timer.is_connected("timeout", self, "_on_Timeout"):
			$Timer.connect("timeout", self, "_on_Timeout");
		$Timer.start();
	else:
		if $Timer.is_connected("timeout", self, "_on_Timeout"):
			$Timer.disconnect("timeout", self, "_on_Timeout");
		$Timer.stop();

func enable_light():
	light_on = true;
	update_light();

func disable_light():
	light_on = false;
	update_light();

func set_light_broken(broken: bool):
	light_broken = broken;
	update_light();

func _on_Timeout():
	if light_on:
		$Timer.wait_time = rand_range(0.085, 0.25);
		$StaticBody2D/Light2D.enabled = !$StaticBody2D/Light2D.enabled;
