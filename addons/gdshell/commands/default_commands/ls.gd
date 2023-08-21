extends GDShellCommand


func _main(argv: Array, data) -> Dictionary:
	var path: String
	match len(argv):
		1:
			path = "/root"
		_:
			path = argv[1]
			if path[0] != "/":
				path = "/" + path

	output_tree(path)

	return {}


var root_node: Node


func _get_all_children(node: Node, prefix := "", last := true, start := true):
	var new_prefix := "" if start else " ┖╴" if last else " ┠╴"

	root_node = node if start else root_node
	var postfix = " (" + node.get_class() + ")"
	postfix = " (" + node.get_class() + ")"

	if node.scene_file_path != "" and node != root_node:
		postfix += " 🎬"
	if node.get_script() != null:
		postfix += " 📜"
	output(prefix + new_prefix + node.name + postfix)

	var child_count := node.get_child_count()

	if node.scene_file_path == "" or node == root_node:
		for i in range(child_count):
			var child = node.get_child(i)
			var num_of_siblings = child_count - 1
			var is_last = i == num_of_siblings
			
			if child.get_parent() != root_node:
				new_prefix = "  " if last else " ┃ "
			_get_all_children(child, prefix + new_prefix, is_last, false)

	return []


func output_tree(path) -> Dictionary:
	var node: Node
	var regex_res := RegEx.new()
	var regex_tscn := RegEx.new()
	regex_tscn.compile(".tscn")
	regex_res.compile("^(res://)")
	var regex_res_result = regex_res.search(path)
	var regex_tscn_result = regex_tscn.search(path)
	if regex_res_result == null and regex_tscn_result == null:
		node = get_node(path)
	elif regex_tscn_result != null:
		node = load(path).instantiate()
		if node == null:
			return {"error": ERR_FILE_NOT_FOUND, "error_string": "File not found"}
	else:
		output('[color="red"] Path is not tscn file [/color]')
		return {"error": ERR_PARAMETER_RANGE_ERROR, "error_string": "Node not found"}

	if node == null:
		output('[color="red"] Wrong path, node not found [/color]')
		return {"error": ERR_FILE_NOT_FOUND, "error_string": "Node not found"}

	_get_all_children(node)
	return {}
