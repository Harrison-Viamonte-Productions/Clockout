extends Area2D

export var call_function_enter: String;
export var call_args_enter: Array = [];
export var call_function_exit: String;
export var call_args_exit: Array = [];
export var node_caller: String = "$CurrentMap";
export var activated_by: String = "$Player" ;

var activatedBy: Node;
var nodeCaller: Node;

func _ready():
	if call_function_enter.length() > 1 || call_function_exit.length() > 1:
		nodeCaller = Game.CurrentMap; # By default
		activatedBy = Game.Player; # By default
		
		if node_caller != "$CurrentMap":
			nodeCaller = get_tree().get_node(NodePath(node_caller));
		if activated_by != "$Player":
			activatedBy = get_tree().get_node(NodePath(activated_by));

		if call_function_enter.length() > 1:
			if has_node_type(activatedBy, PhysicsBody2D):
				self.connect("body_entered", self,  "on_body_entered");
			else:
				self.connect("area_entered", self,  "on_area_entered");
				
		if call_function_exit.length() > 1:
			if has_node_type(activatedBy, PhysicsBody2D):
				self.connect("body_exited", self, "on_body_exited");
			else:
				self.connect("area_entered", self,  "on_area_exited");

func has_node_type(nodeEntity: Node, nodeType):
	if nodeEntity is nodeType:
		return true;
	
	#check if the children does not include a phycisbody2d first
	var children_of_node = nodeEntity.get_children();
	for child in children_of_node:
		if has_node_type(child, nodeType):
			return true;
		
	return false;
	
func on_body_entered(body):
	if body == activatedBy:
		nodeCaller.callv(call_function_enter, call_args_enter);
		
func on_area_entered(area):
	if area == activatedBy:
		nodeCaller.callv(call_function_enter, call_args_enter);

func on_body_exited(body):
	if body == activatedBy:
		nodeCaller.callv(call_function_exit, call_args_exit);
		
func on_area_exited(area):
	if area == activatedBy:
		nodeCaller.callv(call_function_exit, call_args_exit);
