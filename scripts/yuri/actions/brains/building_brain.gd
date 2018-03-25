extends "res://scripts/yuri/actions/brains/base_brain.gd"


var close_threshold = 4

var base_spawn_score = 100
var in_danger_score = 100

var unit_amount_penalty = 50

var global_spawn_limit = 20


func _initialize():
    self.actions_templates['spawn'] = preload("res://scripts/yuri/actions/types/spawn_unit_action.gd")


func get_actions(entity, enemies = {}, units = {}):
    if entity.spawn_field == null or entity.spawn_field.object != null:
        return []

    var available_action_points = self.bag.controllers.action_controller[entity.player]

    if entity.get_required_ap() > available_action_points:
        return []

    var spawn_limit = min(self.bag.yuri_ai.pathfinder.passable_field_count / 7, self.global_spawn_limit)
    if units.size() <= spawn_limit:
        return []


    var spawn_action = self.actions_templates["spawn"].new(entity)
    var score = self.base_spawn_score
    var distance

    for position in enemies:
        if enemies[position].type_name != "soldier":
            continue

        distance = self.bag.yuri_ai.pathfinder.get_distance(entity.position_on_map, position)
        if distance <= self.close_threshold:
            score = score + self.in_danger_score
            break

    if self._apply_amount_penalty(units):
        self.score = score - self.unit_amount_penalty

    spawn_action.set_score(score)

    return [spawn_action]


func _apply_amount_penalty(units):
    return false

func _count_units(units):
    var counts = {}

    for key in units:
        if not counts.has(units[key].type_name):
            counts[units[key].type_name] = 0
        counts[units[key].type_name] += 1

    return counts
