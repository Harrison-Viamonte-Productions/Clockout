extends Camera2D

const MIN_MOVE_PRECISION: float = 1.0;

var move_step: Vector2;
var next_zoom: Vector2;
var next_pos: Vector2;
var moving_to: bool = false;
var moving_to_global: bool = false;
var Util = Game.Util_Object.new(self);

func _ready():
	next_pos = global_position;
	next_zoom = zoom;
	moving_to_global = true;
	Util._ready();

func _physics_process(delta):
	interpolate_movement(delta);
	interpolate_zoom(delta);

func interpolate_movement(delta):
	if moving_to:
		if moving_to_global:
			global_position = global_position.linear_interpolate(next_pos, delta * 4.0);
			if (global_position - next_pos).length() <= MIN_MOVE_PRECISION:
				moving_to = false;
		else:
			position = position.linear_interpolate(next_pos, delta * 4.0);
			if (position - next_pos).length() <= MIN_MOVE_PRECISION:
				moving_to = false;

func interpolate_zoom(delta: float) -> void:
	if	next_zoom != zoom:
		if next_zoom.x > zoom.x:
			zoom.x = clamp(zoom.x + move_step.x*delta, zoom.x, next_zoom.x);
		else:
			zoom.x = clamp(zoom.x + move_step.x*delta, next_zoom.x, zoom.x);
		if next_zoom.y > zoom.y:
			zoom.y = clamp(zoom.y + move_step.y*delta, zoom.y, next_zoom.y);
		else:
			zoom.y = clamp(zoom.y + move_step.y*delta, next_zoom.y, zoom.y);

func update_limits(start: Vector2, end:Vector2) -> void:
	limit_left = start.x;
	limit_top = start.y;
	limit_right = end.x;
	limit_bottom = end.y;

func change_zoom_interpolated(new_scale: float, seconds: float) -> void:
	move_step.x = (new_scale - zoom.x)/seconds;
	move_step.y = (new_scale - zoom.y)/seconds;
	next_zoom = Vector2(new_scale, new_scale);

func move_to_point2d(new_pos: Position2D, interpolated: bool, global: bool = true):
	moving_to_global = global;
	if global:
		if (interpolated):
			moving_to = true;
			next_pos.x = new_pos.global_position.x;
			next_pos.y = new_pos.global_position.y;
		else:
			global_position.x = new_pos.global_position.x;
			global_position.y = new_pos.global_position.y;
	else:
		var new_pos_local: Vector2 = get_parent().global_position - new_pos.global_position;
		if (interpolated):
			moving_to = true;
			next_pos.x = new_pos_local.x;
			next_pos.y = new_pos_local.y;
		else:
			position.x = new_pos_local.x;
			position.y = new_pos_local.y;

func move_to(new_pos: Vector2, interpolated: bool, global: bool = true):
	moving_to_global = global;
	if global:
		if (interpolated):
			moving_to = true;
			next_pos.x = new_pos.x;
			next_pos.y = new_pos.y;
		else:
			global_position.x = new_pos.x;
			global_position.y = new_pos.y;
	else:
		if (interpolated):
			moving_to = true;
			next_pos.x = new_pos.x;
			next_pos.y = new_pos.y;
		else:
			position.x = new_pos.x;
			position.y = new_pos.y;
