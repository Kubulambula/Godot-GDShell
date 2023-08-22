extends GDShellCommand


func _main(argv: Array, data) -> Dictionary:
	var path: String
	var options := argv_parse_options(argv, true)
	path = get_actual_path(argv)

	output_tree(path)

	return {}


func get_tree_dict(node: Node) -> Dictionary:
	#root_node = node if start else root_node
	var node_dict = {}
	node_dict["name"] = node.name
	node_dict["has_script"] = node.get_script() != null
	node_dict["type"] = node.get_class()
	node_dict["is_instanced_scene"] = node.scene_file_path != ""
	node_dict["scene_file_path"] = node.scene_file_path
	node_dict["scene_tree_path"] = node.get_path()
	node_dict["parent"] = node.get_parent().name if node.get_parent() != null else "none"
	node_dict["children"] = []
	var node_children = []
	
	var child_count := node.get_child_count()
	
	for i in child_count:
		#output(get_tree_dict(node.get_child(i), tree_dict, counter))
		node_dict["children"].append(get_tree_dict(node.get_child(i)))

	
	return node_dict


func output_tree_dict(tree_dict: Dictionary, parent:= "", prefix:= "", root_node:= "", start:= true, last:= false):
	var new_prefix := "" if start else " ┖╴" if last else " ┠╴"
	root_node = tree_dict["name"] if start else root_node
	output(prefix + new_prefix + tree_dict["name"])
	
	var dict_len:= len(tree_dict["children"]) if !tree_dict["is_instanced_scene"] or start else 0
	
	for i in range(dict_len):
		var item = tree_dict["children"][i]
		if item is Dictionary:
			var num_of_siblings:= dict_len
			if item["parent"] != root_node:
				new_prefix = "   " if last or start else " ┃ "
			output_tree_dict(item, item["parent"], prefix + new_prefix, root_node, false, i == num_of_siblings - 1)

func _get_all_children_old(node: Node, root_node := node, prefix := "", last := true, start := true):
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
			_get_all_children_old(child, root_node, prefix + new_prefix, is_last, false)

	return []


func output_tree(path: String) -> Dictionary:
	var node: Node
	var is_resource_path = path.begins_with("res://")
	var is_scn_file = path.ends_with(".tscn") or path.ends_with(".scn")
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

	output_tree_dict(get_tree_dict(node))
	#_get_all_children(node)
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

	if path.begins_with("root") or path.begins_with("/root"):
		path = "/" + path
	else:
		path = str(current_scene_path) + "/" + path

	return path
