extends Node

signal dialogue_text_changed(text, character)
signal event_queue_changed(is_empty)

var event_queue = []
var image_nodes = {}
var event_data = {}

func _ready():
	load_event_data()
	print(MainData.player_data)

func load_event_data():
	var dir = Directory.new()
	var json_path = "res://json_file/"
	
	# Initialize event_data with an empty "events" array if it doesn't exist
	if not "events" in event_data:
		event_data["events"] = []
	
	if dir.open(json_path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".json"):
				var full_path = json_path + file_name
				var file = File.new()
				if file.file_exists(full_path):
					file.open(full_path, File.READ)
					var json_text = file.get_as_text()
					file.close()
					var json_result = JSON.parse(json_text)
					if json_result.error == OK:
						var data = json_result.result
						if typeof(data) == TYPE_DICTIONARY and "events" in data:
							for event in data["events"]:
								if "id" in event:
									# Check if the event already exists
									var existing_event = get_event_by_id(event["id"])
									if existing_event:
										# Update existing event
										var index = event_data["events"].find(existing_event)
										event_data["events"][index] = event
									else:
										# Add new event
										event_data["events"].append(event)
							print("Events loaded successfully from: " + file_name)
						else:
							print("Warning: 'events' key not found or invalid structure in " + file_name)
					else:
						print("JSON Parse Error in " + file_name + ": ", json_result.error)
						print("Error Line: ", json_result.error_line)
						print("Error String: ", json_result.error_string)
				else:
					print("Cannot open file: " + full_path)
			
			file_name = dir.get_next()
		
		dir.list_dir_end()
	else:
		print("Cannot open directory: " + json_path)
		print("Current script path: ", get_script().resource_path)
		print("Project root path: ", ProjectSettings.globalize_path("res://"))

	print("Total events loaded: ", event_data["events"].size())

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event_queue.size() > 0:
			var current_event = event_queue[0]
			if not current_event.get("auto_execute", true):
				print("Processing event on user click")
				process_event()
			else:
				print(event_queue)
				print("Auto-execute event is already being processed")

func add_event_to_queue(event):
	event_queue.append(event)
	emit_signal("event_queue_changed", false)

func add_events_to_queue(events: Array):
	for event in events:
		add_event_to_queue(event)

func process_event():
	if event_queue.size() == 0:
		print("No events to process.")
		return
	var current_event = event_queue[0]
	match current_event["type"]:
		"dialogue":
			print("dialogue")
			process_dialogue_event(current_event)
		"show_image":
			print("show")
			show_image(current_event["content"]["image_path"], current_event["content"]["position"])
		"hide_image":
			print("hide")
			hide_image(current_event["content"]["image_path"])
		"call_function":
			print("call function")
			process_call_function_event(current_event)
		"conditional":
			print("conditional")
			process_conditional_event(current_event)
		"event_sequence":
			print("sequence")
			process_event_sequence(current_event)

func complete_event():
	event_queue.pop_front()
	
	if event_queue.size() == 0:
		emit_signal("event_queue_changed", true)
		print("Event queue is empty, nothing to complete.")
		return

	var current_event = event_queue[0]
	var auto_execute = current_event.get("auto_execute", true)

	if not auto_execute:
		print("Auto-execute is disabled for the current event.")
		return

	process_event()

func process_dialogue_event(event):
	var dialogue_content = event["content"]
	var current_line = event.get("current_line", 0)
	var auto_execute = event.get("auto_execute", false)
	if current_line < dialogue_content.size():
		var text_data = dialogue_content[current_line]
		emit_signal("dialogue_text_changed", text_data["text"], text_data["character"])
		event["current_line"] = current_line + 1
		if auto_execute:
			call_deferred("process_dialogue_event", event)
		else:
			print("Waiting for next click to continue dialogue")
	else:
		event["current_line"] = 0 
		complete_event()

func show_image(image_path, position):
	print("Showing image: ", image_path)
	if image_path in image_nodes:
		image_nodes[image_path].show()
		image_nodes[image_path].rect_position = position
	else:
		var texture = load(image_path)
		if texture:
			var texture_rect = TextureRect.new()
			texture_rect.texture = texture
			texture_rect.rect_position = position
			add_child(texture_rect)
			image_nodes[image_path] = texture_rect
		else:
			print("Failed to load image: ", image_path)
	complete_event()

func hide_image(image_path):
	print("Hiding image: ", image_path)
	if image_path in image_nodes:
		image_nodes[image_path].hide()
	else:
		print("Image not found: ", image_path)
	complete_event()

func process_call_function_event(event):
	var function_name = event["function"]
	var content = event.get("content", {})
	MainData.call_function(function_name, content)
	complete_event()

func process_conditional_event(event):
	var condition = event["condition"]
	var success = false
	match condition["type"]:
		"stat_check":
			var stat_value = MainData.get_player_data()["variable_attributes"][condition["stat_name"]]
			match condition["comparison"]:
				"gte":
					success = stat_value >= condition["value"]
				"lte":
					success = stat_value <= condition["value"]
				"eq":
					success = stat_value == condition["value"]
	
	var next_event_id = event["success_event_id"] if success else event["failure_event_id"]
	var next_event = get_event_by_id(next_event_id)
	
	if next_event:
		event_queue.pop_front()
		event_queue.push_front(next_event)
		process_event()
	else:
		complete_event()

func process_event_sequence(event):
	var event_ids = event["content"]["event_ids"]
	for event_id in event_ids:
		var event_to_add = get_event_by_id(event_id)
		if event_to_add:
			add_event_to_queue(event_to_add)
	complete_event()

func get_event_by_id(event_id: int):
	for event in event_data["events"]:
		if event["id"] == event_id:
			return event
	return null
