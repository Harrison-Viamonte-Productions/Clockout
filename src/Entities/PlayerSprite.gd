extends Sprite

func update_animation(velocity: Vector2) -> void:
	if velocity.x < 0.0:
		self.scale.x = -1.0;
	else:
		self.scale.x = 1.0;
