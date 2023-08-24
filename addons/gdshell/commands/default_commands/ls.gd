extends GDShellCommand


func _main(argv: Array, data) -> Dictionary:
	var path: String

	# If additional functionality is added, this should be moved to it's own function
	# But i think i addressed most of what an ls command could do
	var starting_node = get_starting_node(argv)
	if starting_node is Dictionary:
		return starting_node
	var tree_dict = get_tree_dict(starting_node, starting_node)
	output_tree_dict(tree_dict)

	return {
		"error": 0,
		"error_string": "",
		"data": tree_dict,
	}


func get_tree_dict(node: Node, root_node: Node, start := true) -> Dictionary:
	root_node = node if start else root_node
	var node_dict = {}
	node_dict["name"] = node.name
	node_dict["has_script"] = node.get_script() != null
	node_dict["script_file"] = node.get_script().get_path() if node_dict["has_script"] else "none"
	node_dict["type"] = node.get_class()
	node_dict["is_instanced_scene"] = node.scene_file_path != ""
	node_dict["scene_file_path"] = str(node.scene_file_path)
	node_dict["scene_tree_path"] = str(node.get_path())
	node_dict["parent"] = node.get_parent().name if node.get_parent() != null else "none"
	node_dict["children"] = []

	for child in node.get_children():
		node_dict["children"].append(get_tree_dict(child, root_node, false))

	if not node.is_inside_tree():
		root_node.queue_free()

	return node_dict


func output_tree_dict(
	tree_dict: Dictionary, parent := "", prefix := "", root_node := "", start := true, last := false
):
	var new_prefix := "" if start else " ┖╴" if last else " ┠╴"
	root_node = tree_dict["name"] if start else root_node
	var postfix = " (" + tree_dict["type"] + ") "
	if tree_dict["is_instanced_scene"] and tree_dict["name"] != root_node:
		postfix += "[hint=" + tree_dict["scene_file_path"] + "] 🎬[/hint]"
	if tree_dict["has_script"]:
		postfix += "[hint=" + tree_dict["script_file"] + "] 📜[/hint]"

	var name_output
	if tree_dict["scene_tree_path"] != "":
		name_output = "[hint=" + tree_dict["scene_tree_path"] + "]" + tree_dict["name"] + "[/hint]"
	else:
		name_output = tree_dict["name"]
	output(prefix + new_prefix + name_output + postfix)

	var dict_len := len(tree_dict["children"]) if !tree_dict["is_instanced_scene"] or start else 0

	for i in dict_len:
		var item = tree_dict["children"][i]
		if item is Dictionary:
			var num_of_siblings := dict_len
			if item["parent"] != root_node:
				new_prefix = "   " if last or start else " ┃ "
			output_tree_dict(
				item,
				item["parent"],
				prefix + new_prefix,
				root_node,
				false,
				i == num_of_siblings - 1
			)


func get_starting_node(argv: Array):
	var path: String
	var node: Node
	if len(argv) == 1:
		return get_tree().current_scene
	else:
		path = argv[1]

	var is_scn_file = path.ends_with(".tscn") or path.ends_with(".scn")
	var is_resource_file = path.begins_with("res://")
	var is_absolute_path = path.begins_with("/root") or path.begins_with("root")

	if is_resource_file and is_scn_file:
		if !FileAccess.file_exists(path):
			output("[color=red]" + "Resource file does not exit" + "[/color]")
			return {"error": ERR_FILE_NOT_FOUND, "error_string": "File not found"}
		else:
			node = load(path).instantiate()

	elif is_absolute_path:
		node = get_node("/" + path)
	else:
		var current_scene := get_tree().current_scene
		var current_scene_path := "/root"
		if !path.begins_with(current_scene.name):
			current_scene_path = str(current_scene.get_path())

		path = current_scene_path + "/" + path
		node = get_node_or_null(path)
	if node == null:
		output("[color=red]" + "Node does not exit at " + path + "[/color]")
		return {"error": ERR_DOES_NOT_EXIST, "error_string": "Node not found"}

	return node
