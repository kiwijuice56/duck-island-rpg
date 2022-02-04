extends PanelContainer

func initialize(index: int, file: Resource):
	$MarginContainer/VBoxContainer/FileName.text = "File %02d" % index
	if file == null:
		$MarginContainer/VBoxContainer/Time.text = ""
		$MarginContainer/VBoxContainer/Location.text = ""
	else:
		$MarginContainer/VBoxContainer/Location.text = file.data["overworld_nodes"]["overworld"]["location"]
