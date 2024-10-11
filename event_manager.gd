extends Node

signal dialogue_text_changed(text, character)

var event_data = {
	"events": [
		{
			"id": 1,
			"type": "dialogue",
			"content": [
				{"text": "안녕하세요, 제 이름은 아랑입니다.", "character": "아랑"},
				{"text": "여기 오신 걸 환영합니다.", "character": "아랑"}
			],
			"next_event": 2
		},
		{
			"id": 2,
			"type": "show_image",
			"content": {
				"image_path": "res://assets/image/jabmu.png",
				"position": Vector2(10, 10)
			},
			"next_event": 3
		},
		{
			"id": 3,
			"type": "dialogue",
			"content": [
				{"text": "오늘은 무엇을 하실 건가요?", "character": "아랑"},
				{"text": "제가 도와드리겠습니다.", "character": "아랑"}
			],
			"next_event": 4
		},
		{
			"id": 4,
			"type": "hide_image",
			"content": {
				"image_path": "res://assets/image/jabmu.png"
			},
			"next_event": null
		}
	]
}

var current_event = null
var image_nodes = {}

func _ready():
	start_event(1)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		next_event()

func start_event(event_id: int):
	current_event = {"id": event_id, "current_line": 0}
	process_current_event()

func next_event():
	if current_event == null:
		print("진행 중인 이벤트가 없습니다.")
		return
	var event = get_current_event()
	if event["type"] == "dialogue":
		if current_event["current_line"]+1 >= event["content"].size():
			move_to_next_event(event)
		else:
			current_event["current_line"] += 1
			process_current_event()
	else:
		move_to_next_event(event)

func move_to_next_event(event):
	var next_event_id = event["next_event"]
	if next_event_id == null:
		end_event()
	else:
		start_event(next_event_id)
		var next_event = get_current_event()  # 새로운 이벤트를 가져옴
		if next_event["type"] == "hide_image":  # 타입이 "hide_image"일 경우
			next_event()  # 추가로 next_event 함수를 호출


func process_current_event():
	var event = get_current_event()
	match event["type"]:
		"dialogue":
			process_dialogue_event(event)
		"show_image":
			show_image(event["content"]["image_path"], event["content"]["position"])
		"hide_image":
			hide_image(event["content"]["image_path"])

func process_dialogue_event(event):
	if current_event["current_line"] >= event["content"].size():
		end_event()
		return
	var text_data = event["content"][current_event["current_line"]]
	emit_signal("dialogue_text_changed", text_data["text"], text_data["character"])

func get_current_event():
	for event in event_data["events"]:
		if event["id"] == current_event["id"]:
			return event
	return null

func end_event():
	print("이벤트가 종료되었습니다.")
	current_event = null
	emit_signal("dialogue_text_changed", "", "")

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

func hide_image(image_path):
	print("Hiding image: ", image_path)
	if image_path in image_nodes:
		image_nodes[image_path].hide()
	else:
		print("Image not found: ", image_path)
