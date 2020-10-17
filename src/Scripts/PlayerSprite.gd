extends Sprite

func update_animation(velocity: Vector2) -> void:
	if velocity.x < 0.0:
		if (self.scale.x > 0.0):
			self.scale.x = -self.scale.x;
	elif velocity.x > 0.0:
		if (self.scale.x < 0.0):
			self.scale.x = -self.scale.x;
