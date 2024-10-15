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
###### 잡무
		{
			"id": 10001,
			"type": "event_sequence",
			"auto_execute": false,  # 자동 실행
			"content": {
				"event_ids": [10006, 10003, 10002, 10003, 10002, 10003, 10004, 10005]  # 차례로 실행할 이벤트들의 ID 목록
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
			"id": 10006,
			"type": "dialogue",
			"auto_execute": true,
			"content": [
				{"text": "종문 잡무 업무를 맡았다.", "character": "아랑"},
				{"text": "오늘도 열심히 일했다.", "character": "아랑"},
			]
		},
		{
			"id": 10003,
			"type": "call_function",
			"function": "modify_player_stat",
			"auto_execute": true,
			"content": {
				"stat_name": "health",
				"value": -10
			}
		},
		{
			"id": 10004,
			"type": "call_function",
			"function": "modify_player_stat",
			"auto_execute": true,
			"content": {
				"stat_name": "money",
				"value": 30
			}
		},
		{
			"id": 10005,
			"type": "call_function",
			"function": "advance_time",
			"auto_execute": true,
		},
######잡무


######휴식
		{
			"id": 10011,
			"type": "event_sequence",
			"auto_execute": false,  # 자동 실행
			"content": {
				"event_ids": [10012, 10013, 10005]  # 차례로 실행할 이벤트들의 ID 목록
			}
		},
		{
			"id": 10012,
			"type": "dialogue",
			"auto_execute": true,
			"content": [
				{"text": "휴식을 취했다.", "character": "아랑"},
			]
		},
		{
			"id": 10013,
			"type": "call_function",
			"function": "modify_player_stat",
			"auto_execute": true,
			"content": {
				"stat_name": "health",
				"value": 30
			}
		},
#####휴식

#####수련
		{
			"id": 10021,
			"type": "conditional",
			"auto_execute": false,
			"condition": {
				"type": "stat_check",
				"stat_name": "money",
				"value": 500,
				"comparison": "gte"  # greater than or equal
			},
			"success_event_id": 10022,
			"failure_event_id": 10023
		},
		{
			"id": 10022,
			"type": "event_sequence",
			"auto_execute": false,
			"content": {
				"event_ids": [10024, 10025, 10026]  # Money 감소, 특정 이벤트 실행
			}
		},
		{
			"id": 10023,
			"type": "dialogue",
			"auto_execute": false,
			"content": [
				{"text": "돈이 부족합니다.", "character": "시스템"}
			]
		},
		{
			"id": 10024,
			"type": "call_function",
			"function": "modify_player_stat",
			"auto_execute": false,
			"content": {
				"stat_name": "money",
				"value": -500
			}
		},
		{
			"id": 10025,
			"type": "dialogue",
			"auto_execute": false,
			"content": [
				{"text": "500 공헌도를 지불했습니다.", "character": "시스템"}
			]
		},
		{
			"id": 10026,
			"type": "dialogue",
			"auto_execute": false,
			"content": [
				{"text": "특별한 이벤트가 발생했습니다!", "character": "시스템"}
			]
		},
#####수련
	]
}

func _ready():
	print(MainData.player_data)


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
		"call_function":
			print("call function")
			process_call_function_event(current_event)
		"conditional":
			print("conditional")
			process_conditional_event(current_event)
		"event_sequence":
			print("sequence")
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
	var auto_execute = event.get("auto_execute", false)
	if current_line < dialogue_content.size():
		var text_data = dialogue_content[current_line]
		emit_signal("dialogue_text_changed", text_data["text"], text_data["character"])
		event["current_line"] = current_line + 1
		if auto_execute:
			# Auto-execute 모드에서는 모든 대화를 즉시 처리
			call_deferred("process_dialogue_event", event)
		else:
			# 수동 모드에서는 다음 클릭을 기다림
			print("Waiting for next click to continue dialogue")
	else:
		# 모든 대화 라인이 처리되면 이벤트 완료
		event["current_line"] = 0 
		complete_event()

		
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
#함수 호출
func process_call_function_event(event):
	var function_name = event["function"]
	var content = event.get("content", {})
	MainData.call_function(function_name, content)
	complete_event()

#분기문
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
		# 다음 이벤트를 현재 큐의 맨 앞에 추가
		event_queue.pop_front()  # 현재 조건부 이벤트 제거
		event_queue.push_front(next_event)  # 다음 이벤트를 맨 앞에 추가
		process_event()  # 즉시 다음 이벤트 처리
	else:
		complete_event()  # 다음 이벤트가 없으면 현재 이벤트 완료
		


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
	
