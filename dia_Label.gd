extends Label

# 부모 노드가 대화 텍스트를 변경할 때 호출되는 함수
func _ready():
	get_parent().connect("dialogue_text_changed", self, "_on_dialogue_text_changed")

# 시그널을 받아 텍스트를 갱신하는 함수
func _on_dialogue_text_changed(text: String, character: String):
	self.text = character + ": " + text
