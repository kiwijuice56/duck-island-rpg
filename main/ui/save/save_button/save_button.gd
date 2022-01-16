extends PanelContainer

func initialize(file: Resource):
	$MarginContainer/VBoxContainer/Location.text = file.location
