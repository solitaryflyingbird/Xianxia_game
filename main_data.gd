extends Node

signal data_changed

# 아이템 데이터베이스
var item_data = {
	1: {"name": "소형 영약", "type": "consumable", "effect": "health_restore", "value": 20},
	2: {"name": "기본 검", "type": "weapon", "attack": 10, "durability": 100},
	3: {"name": "중형 영약", "type": "consumable", "effect": "health_restore", "value": 50},
	4: {"name": "강화된 검", "type": "weapon", "attack": 20, "durability": 150}
}

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
		"inventory": [
			{"id": 1, "quantity": 5},  # 소형 영약
			{"id": 2, "quantity": 1}   # 기본 검
		]
	}
}

func get_player_data():
	return player_data

func get_item_data(item_id):
	return item_data.get(item_id)

# 수치 조작 함수
func modify_player_stat(stat_name: String, value: int, data: Dictionary = player_data):
	for key in data.keys():
		var item = data[key]
		
		# 만약 Dictionary이면 재귀적으로 호출하여 수정
		if typeof(item) == TYPE_DICTIONARY:
			modify_player_stat(stat_name, value, item)
		
		# 배열은 무시 (techniques, inventory 등을 포함)
		elif typeof(item) == TYPE_ARRAY:
			continue
		
		# 해당하는 stat_name을 찾으면 값을 수정
		elif key == stat_name:
			data[key] += value
			print(stat_name + " has been modified by " + str(value))
			emit_signal("data_changed")
			return
	
	print("Error: Invalid stat name or array detected - " + stat_name)

# 시간 흐름 함수 춘하추동
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

# 아이템 추가 함수
func add_item_to_inventory(item_id: int, quantity: int):
	var inventory = player_data["variable_attributes"]["inventory"]
	for item in inventory:
		if item["id"] == item_id:
			item["quantity"] += quantity
			emit_signal("data_changed")
			return
	
	# 아이템이 인벤토리에 없으면 새로 추가
	inventory.append({"id": item_id, "quantity": quantity})
	emit_signal("data_changed")

# 아이템 제거 함수
func remove_item_from_inventory(item_id: int, quantity: int):
	var inventory = player_data["variable_attributes"]["inventory"]
	for i in range(inventory.size()):
		var item = inventory[i]
		if item["id"] == item_id:
			if item["quantity"] > quantity:
				item["quantity"] -= quantity
			else:
				inventory.remove(i)
			emit_signal("data_changed")
			return

# 아이템 정보 조회 함수
func get_item_info(item_id: int):
	return item_data.get(item_id, null)
