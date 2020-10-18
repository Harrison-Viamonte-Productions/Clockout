extends Camera2D

const MIN_MOVE_PRECISION: float = 1.0;

var camera_step: Vector2;
var camera_next_zoom: Vector2;
var camera_next_pos: Vector2;
var moving_to: bool = false;

func _ready():
	camera_next_pos = global_position;
	camera_next_zoom = zoom;

func _physics_process(delta):
	interpolate_movement(delta);
	interpolate_zoom(delta);

func interpolate_movement(delta):
	if moving_to:
		global_position = global_position.linear_interpolate(camera_next_pos, delta * 4.0);
		if (global_position - camera_next_pos).length() <= MIN_MOVE_PRECISION:
			moving_to = false;

func interpolate_zoom(delta: float) -> void:
	if camera_next_zoom != zoom:
		if camera_next_zoom.x > zoom.x:
			zoom.x = clamp(zoom.x + camera_step.x*delta, zoom.x, camera_next_zoom.x);
		else:
			zoom.x = clamp(zoom.x + camera_step.x*delta, camera_next_zoom.x, zoom.x);
		if camera_next_zoom.y > zoom.y:
			zoom.y = clamp(zoom.y + camera_step.y*delta, zoom.y, camera_next_zoom.y);
		else:
			zoom.y = clamp(zoom.y + camera_step.y*delta, camera_next_zoom.y, zoom.y);

func update_limits(start: Vector2, end:Vector2) -> void:
	limit_left = start.x;
	limit_top = start.y;
	limit_right = end.x;
	limit_bottom = end.y;

func change_zoom_interpolated(new_scale: float, seconds: float) -> void:
	camera_step.x = (new_scale - zoom.x)/seconds;
	camera_step.y = (new_scale - zoom.y)/seconds;
	camera_next_zoom = Vector2(new_scale, new_scale);

func move_to(new_pos: Position2D, interpolated: bool):
	if (interpolated):
		moving_to = true;
		camera_next_pos.x = new_pos.global_position.x;
		camera_next_pos.y = new_pos.global_position.y;
	else:
		global_position.x = new_pos.global_position.x;
		global_position.y = new_pos.global_position.y;
