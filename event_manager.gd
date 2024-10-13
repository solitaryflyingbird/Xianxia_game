extends Node

signal dialogue_text_changed(text, character)
signal event_queue_changed(is_empty)

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
		},
		{
			"id": 5,
			"type": "modify_stat",
			"auto_execute": true,  # 자동 실행
			"content": {
				"stat_name": "health",  # 수정할 스탯 이름
				"value": -10  # 수정할 값
			}
		},
		{
			"id": 6,
			"type": "event_sequence",
			"auto_execute": true,  # 자동 실행
			"content": {
				"event_ids": [1, 2, 3, 4]  # 차례로 실행할 이벤트들의 ID 목록
			}
		},
		{
			"id": 10001,
			"type": "event_sequence",
			"auto_execute": false,  # 자동 실행
			"content": {
				"event_ids": [10002, 10003, 10002, 10003, 10002, 10003]  # 차례로 실행할 이벤트들의 ID 목록
			}
		},
		{
			"id": 10002,
			"type": "dialogue",
			"auto_execute": false,
			"content": [
				{"text": "종문 잡무 업무를 맡았다.", "character": "아랑"},
				{"text": "오늘도 열심히 일했다.", "character": "아랑"},
			]
		},
		{
			"id": 10003,
			"type": "modify_stat",
			"auto_execute": true,  # 자동 실행
			"content": {
				"stat_name": "health",  # 수정할 스탯 이름
				"value": -10  # 수정할 값
			}
		},
	]
}

func _ready():
	print(MainData.player_data)
	add_event_to_queue(get_event_by_id(10001))


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event_queue.size() > 0:
			print("click process event")
			process_event()

# 큐에 이벤트를 추가하는 함수 (단일 이벤트)
func add_event_to_queue(event):
	event_queue.append(event)
	emit_signal("event_queue_changed", false)

# 큐에 여러 이벤트를 한 번에 추가하는 함수
func add_events_to_queue(events: Array):
	for event in events:
		add_event_to_queue(event)

# 현재 큐의 첫 번째 이벤트를 처리하는 함수
func process_event():
	print(len(event_queue))
	if event_queue.size() == 0:
		print("No events to process.")
		return
	var current_event = event_queue[0]  # 큐의 첫 번째 이벤트 가져옴
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
		"modify_stat":
			print("sfat")
			modify_stat_event(current_event)
		"event_sequence":
			print("swquence")
			process_event_sequence(current_event)


# 현재 이벤트 완료 후 큐에서 제거하고 다음 이벤트로 넘어가는 함수
func complete_event():
	event_queue.pop_front()
	
	if event_queue.size() == 0:
		emit_signal("event_queue_changed", true)  # 큐가 비었으므로 true 신호 보냄
		print("Event queue is empty, nothing to complete.")
		return

	var current_event = event_queue[0]
	var auto_execute = current_event.get("auto_execute", true)  # auto_execute 값 가져오기, 기본값은 true

	if not auto_execute:
		print("Auto-execute is disabled for the current event.")
		return  # auto_execute가 false인 경우 아무것도 하지 않음

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
		event["current_line"] = 0 
		complete_event()  # 이벤트 완료

		
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

func modify_stat_event(event):
	var stat_name = event["content"]["stat_name"]
	var value = event["content"]["value"]
	MainData.modify_player_stat(stat_name, value)
	complete_event()
	
func process_event_sequence(event):
	var event_ids = event["content"]["event_ids"]
	for event_id in event_ids:
		var event_to_add = get_event_by_id(event_id)
		if event_to_add:
			add_event_to_queue(event_to_add)
	complete_event()

# 이벤트 데이터에서 특정 ID로 이벤트를 찾는 함수
func get_event_by_id(event_id: int):
	for event in event_data["events"]:
		if event["id"] == event_id:
			return event
	return null
