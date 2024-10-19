extends Node

func _ready():
	load_json_file()

func load_json_file():
	var file = File.new()
	if file.file_exists("res://json_file/event_data.json"):
		file.open("res://json_file/event_data.json", File.READ)
		var json_text = file.get_as_text()
		file.close()
		var json_result = JSON.parse(json_text)
		if json_result.error == OK:
			print("JSON data loaded successfully:")
			print(json_result.result)
		else:
			print("JSON Parse Error: ", json_result.error)
			print("Error Line: ", json_result.error_line)
			print("Error String: ", json_result.error_string)
	else:
		print("Cannot find event_data.json")
		print("Current script path: ", get_script().resource_path)
		print("Project root path: ", ProjectSettings.globalize_path("res://"))
