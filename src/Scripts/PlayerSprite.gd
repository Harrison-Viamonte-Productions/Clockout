extends AnimatedSprite

var anim_crouched: bool = false;
var anim_walking: bool = false;
func update_animation(velocity: Vector2, is_crouched:bool) -> void:
	anim_crouched = is_crouched;
	
	if anim_walking:
		if anim_crouched:
			self.play("crouch_walk");
		else:
			self.play("walk");
	else:
		if anim_crouched:
			self.play("crouch");
		else:
			self.play("idle");
	
	if velocity.x < 0.0:
		if (self.scale.x > 0.0):
			self.scale.x = -self.scale.x;
	elif velocity.x > 0.0:
		if (self.scale.x < 0.0):
			self.scale.x = -self.scale.x;

func _input(event):
	if !get_parent().is_local_player():
		return;
	if Input.is_action_pressed("move_left") || Input.is_action_pressed("move_right"):
		anim_walking = true;
	else:
		anim_walking = false;
