extends Node

signal dialogue_text_changed(text, character)

var event_queue = []
var image_nodes = {}

var event_data = {
	"events": [
		{
			"id": 1,
			"type": "dialogue",
			"auto_execute": false,  # 클릭으로 처리해야 함
			"content": [
				{"text": "안녕하세요, 제 이름은 아랑입니다.", "character": "아랑"},
				{"text": "여기 오신 걸 환영합니다.", "character": "아랑"}
			]
		},
		{
			"id": 2,
			"type": "show_image",
			"auto_execute": true,  # 자동으로 실행
			"content": {
				"image_path": "res://assets/image/jabmu.png",
				"position": Vector2(10, 10)
			}
		},
		{
			"id": 22,
			"type": "show_image",
			"auto_execute": false,  # 자동으로 실행
			"content": {
				"image_path": "res://assets/image/jabmu.png",
				"position": Vector2(10, 10)
			}
		},
		{
			"id": 3,
			"type": "dialogue",
			"auto_execute": false,
			"content": [
				{"text": "오늘은 무엇을 하실 건가요?", "character": "아랑"},
				{"text": "제가 도와드리겠습니다.", "character": "아랑"}
			]
		},
		{
			"id": 4,
			"type": "hide_image",
			"auto_execute": true,
			"content": {
				"image_path": "res://assets/image/jabmu.png"
			}
		}
	]
}

func _ready():
	add_event_to_queue(get_event_by_id(1))
	process_event()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event_queue.size() > 0:
			process_event()

# 큐에 이벤트를 추가하는 함수 (단일 이벤트)
func add_event_to_queue(event):
	event_queue.append(event)

# 큐에 여러 이벤트를 한 번에 추가하는 함수
func add_events_to_queue(events: Array):
	for event in events:
		add_event_to_queue(event)

# 현재 큐의 첫 번째 이벤트를 처리하는 함수

func process_event():
	if event_queue.size() == 0:
		print("No events to process.")
		return
	var current_event = event_queue[0]  # 큐의 첫 번째 이벤트 가져옴
	match current_event["type"]:
		"dialogue":
			process_dialogue_event(current_event)
		"show_image":
			show_image(current_event["content"]["image_path"], current_event["content"]["position"])
			complete_event()
		"hide_image":
			hide_image(current_event["content"]["image_path"])
			complete_event()
	


# 현재 이벤트 완료 후 큐에서 제거하고 다음 이벤트로 넘어가는 함수
func complete_event():
	event_queue.pop_front()  # 큐에서 첫 번째 이벤트 제거
	process_event()  # 다음 이벤트 실행

# 대화 이벤트 처리 함수
func process_dialogue_event(event):
	var dialogue_content = event["content"]
	var current_line = event.get("current_line", 0)
	if current_line < dialogue_content.size():
		var text_data = dialogue_content[current_line]
		emit_signal("dialogue_text_changed", text_data["text"], text_data["character"])
		event["current_line"] = current_line + 1
	else:
		complete_event()  # 대화 이벤트가 끝났으면 완료 처리
		


# 이미지 표시 함수
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
	complete_event()  # 이미지 표시 이벤트는 자동 실행이므로 완료 처리

# 이미지 숨김 함수
func hide_image(image_path):
	print("Hiding image: ", image_path)
	if image_path in image_nodes:
		image_nodes[image_path].hide()
	else:
		print("Image not found: ", image_path)
	complete_event()  # 이미지 숨김 이벤트도 자동 실행이므로 완료 처리

# 이벤트 데이터에서 특정 ID로 이벤트를 찾는 함수
func get_event_by_id(event_id: int):
	for event in event_data["events"]:
		if event["id"] == event_id:
			return event
	return null
