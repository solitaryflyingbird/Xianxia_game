# button_manager.gd
extends Node

# 부모 노드인 event_manager를 참조하기 위한 변수
var event_manager

func _ready():
	# event_manager의 시그널을 연결
	event_manager = get_parent()  # event_manager가 부모 노드라고 가정
	event_manager.connect("event_queue_changed", self, "_on_event_queue_changed")
	
	hide_buttons()  # 처음에는 버튼을 숨김

# event_queue_changed 시그널을 수신할 때 호출되는 함수
func _on_event_queue_changed(is_empty):
	if is_empty:
		show_buttons()  # 큐가 비어있으면 버튼을 보임
	else:
		hide_buttons()  # 큐에 이벤트가 있으면 버튼을 숨김

func hide_buttons():
	self.visible = false  # button_manager 자체를 숨김
	for button in get_children():
		if button is Button:
			button.disabled = true  # 버튼 비활성화
			button.visible = false  # 버튼 숨김

func show_buttons():
	self.visible = true  # button_manager 자체를 보임
	for button in get_children():
		if button is Button:
			button.disabled = false  # 버튼 활성화
			button.visible = true  # 버튼 보임
