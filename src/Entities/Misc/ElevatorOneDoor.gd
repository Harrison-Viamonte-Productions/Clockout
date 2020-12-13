extends ElevatorBase
onready var elev_door: Door = $Door;

func _ready():
	elev_door.unlock();

func move_to_pos(new_pos_index: int):
	.move_to_pos(new_pos_index);
	elev_door.lock();

func next_pos_reached():
	.next_pos_reached();
	elev_door.unlock();
