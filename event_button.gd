extends Button

# 호출할 이벤트 ID를 저장
export(int) var event_id
var event_manager  # event_manager에 대한 참조

func _ready():
	# 부모의 부모인 button_manager에서 event_manager를 찾음 (button_manager가 event_manager의 자식임을 가정)
	event_manager = get_parent().get_parent()

	# 버튼 클릭 시 신호 연결
	connect("pressed", self, "_on_button_pressed")

# 버튼이 눌렸을 때 호출되는 함수
func _on_button_pressed():
	if event_manager and event_id != -1:
		var event_to_add = event_manager.get_event_by_id(event_id)
		if event_to_add:
			event_manager.add_event_to_queue(event_to_add)  # event_manager의 이벤트 큐에 추가
		else:
			print("Invalid event ID: ", event_id)
