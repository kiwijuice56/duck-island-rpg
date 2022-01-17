extends PanelContainer

func initialize(file: Resource):
	if file == null:
		$MarginContainer/VBoxContainer/FileName.text = "EMPTY"
		$MarginContainer/VBoxContainer/Time.text = ""
		$MarginContainer/VBoxContainer/Location.text = ""
	else:
		$MarginContainer/VBoxContainer/Location.text = file.data["overworld_nodes"]["overworld"]["location"]
