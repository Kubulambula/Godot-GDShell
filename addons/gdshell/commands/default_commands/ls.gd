extends GDShellCommand


func _main(argv: Array, data) -> Dictionary:
	var path: String
	var options := argv_parse_options(argv, true)
	path = get_actual_path(argv)

	output_tree(path)

	return {}


func _get_all_children(node: Node, root_node := node, prefix := "", last := true, start := true):
	var new_prefix := "" if start else " ┖╴" if last else " ┠╴"

	root_node = node if start else root_node
	var postfix = " (" + node.get_class() + ")"

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
			_get_all_children(child, root_node, prefix + new_prefix, is_last, false)

	return []


func output_tree(path: String) -> Dictionary:
	var node: Node
	var is_resource_path = path.begins_with("res://")
	var is_scn_file = path.ends_with(".tscn") or path.ends_with(".scn")
	print_debug(path)
	if !is_resource_path and !is_scn_file:
		node = get_node(path)
	elif is_scn_file:
		node = load(path).instantiate()
		if node == null:
			return {"error": ERR_FILE_NOT_FOUND, "error_string": "File not found"}
	else:
		output('[color="red"] Path is not a tscn or scn file [/color]')
		return {"error": ERR_PARAMETER_RANGE_ERROR, "error_string": "Node not found"}

	if node == null:
		output('[color="red"] Wrong path, node not found [/color]')
		return {"error": ERR_FILE_NOT_FOUND, "error_string": "Node not found"}

	_get_all_children(node)
	if is_scn_file:
		node.queue_free()
	return {}


func get_ls_root_path(argv, path) -> String:
	match len(argv):
		1:
			path = "/root"
		_:
			if path[0] != "/":
				path = "/" + path
	return path


func get_actual_path(argv) -> String:
	var path: String
	var current_scene_path = get_tree().current_scene.get_path()
	var options := argv_parse_options(argv, true)

	match len(argv):
		1:
			return current_scene_path
		_:
			path = argv[1]

	if path.begins_with("root"):
		path = "/" + path
	else:
		path = str(current_scene_path) + "/" + path

	return path
