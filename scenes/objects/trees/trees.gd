extends Node

func get_all_tree_states() -> Dictionary:
	var tree_states = {}
	for tree in get_children():
		if tree.has_method("get_state"):
			tree_states[tree.name] = tree.get_state()
	print("Collected tree states: ", tree_states)  # Debug print
	return tree_states
