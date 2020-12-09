extends Object

var current_boop: Dictionary = {};
var father_node: Node2D;

func _init(node: Node2D):
	father_node = node;

func boops_are_equal(boopA: Dictionary, boopB: Dictionary) -> bool:
	for key in boopA:
		if !boopB.has(key) or boopB[key] != boopA[key]:
			return false;
	for key in boopB:
		if !boopA.has(key) or boopB[key] != boopA[key]:
			return false;
	return true; #they are totally equal

func delta_boop_changed(new_boop: Dictionary) -> bool:
	var retResult: bool = new_boop.empty() or !boops_are_equal(new_boop, current_boop);
	current_boop = new_boop;
	return retResult;
