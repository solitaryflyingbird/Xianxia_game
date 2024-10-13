extends Node

signal data_changed

var player_data = {
	"fixed_attributes": {
		"name": "아랑",
		"gender": "남자",
		"spiritual_root": ["화","수","목","금","토"],
		"appearance": 7,
		"intelligence": 8,
		"luck": 5
	},
	"variable_attributes": {
		"season" : "봄",
		"age": 20,
		"remain_life" : 80,
		"health" : 100,
		"experience_point" : 0,
		"cultivation_stage": "연기기 1성",
		"techniques": [
			{"name": "기초 심법", "proficiency": 50},
			{"name": "기초 화공", "proficiency": 60}
		],
		"money": 1000, # 소지한 공헌 양
		"item_data": {
			"items": [
				{"name": "소형 영약", "quantity": 5},
				{"name": "기본 검", "quantity": 1}
			]
		}
	}
}


func get_player_data():
	return player_data
	
	
#수치 조작 함수
func modify_player_stat(stat_name: String, value: int, data: Dictionary = player_data):
	for key in data.keys():
		var item = data[key]
		
		# 만약 Dictionary이면 재귀적으로 호출하여 수정
		if typeof(item) == TYPE_DICTIONARY:
			modify_player_stat(stat_name, value, item)
		
		# 배열은 무시 (techniques, items 등을 포함)
		elif typeof(item) == TYPE_ARRAY:
			continue
		
		# 해당하는 stat_name을 찾으면 값을 수정
		elif key == stat_name:
			data[key] += value
			print(stat_name + " has been modified by " + str(value))
			emit_signal("data_changed")
			return
	
	print("Error: Invalid stat name or array detected - " + stat_name)
	
#시간 흐름 함수 춘하추동
func advance_time():
	var current_season = player_data["variable_attributes"]["season"]
	if current_season == "봄":
		player_data["variable_attributes"]["season"] = "여름"
	elif current_season == "여름":
		player_data["variable_attributes"]["season"] = "가을"
	elif current_season == "가을":
		player_data["variable_attributes"]["season"] = "겨울"
	elif current_season == "겨울":
		player_data["variable_attributes"]["season"] = "봄"
		player_data["variable_attributes"]["age"] += 1
		player_data["variable_attributes"]["remain_life"] -= 1
	emit_signal("data_changed")
