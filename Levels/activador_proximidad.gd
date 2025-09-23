# ProximityActivator2D.gd (Godot 4.x)
extends Area2D

signal sector_toggled(sector_name: String, active: bool, count: int)

@export_group("Objetivos")
@export var use_groups := true
@export var groups_to_toggle: Array[StringName] = ["activable"]
@export var targets_root: Node = null # si no usas grupos, arrastra aquí la carpeta del sector

@export_group("Comportamiento")
@export var also_toggle_visibility := true
@export var disable_collisions := true
@export var enter_delay := 0.0
@export var exit_delay := 0.25
@export var start_active := false

@export_group("Debug")
@export var debug_logs := true
@export var debug_list_limit := 12
@export var debug_show_counts_only := false

var _inside := false
var _exit_timer: Timer

func _ready() -> void:
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)

	_exit_timer = Timer.new()
	_exit_timer.one_shot = true
	add_child(_exit_timer)
	_exit_timer.timeout.connect(_do_deactivate.bind("exit_timer"))

	# Estado inicial
	if start_active:
		_do_activate("ready/start_active")
	else:
		_do_deactivate("ready/start_inactive")

	await get_tree().process_frame
	# Si el player ya está dentro, activar
	var player := get_tree().get_first_node_in_group("jugador")
	if player and get_overlapping_bodies().has(player):
		_inside = true
		_do_activate("ready/player_inside")

func _collect_targets() -> Array[Node]:
	var out: Array[Node] = []
	if use_groups:
		for g in groups_to_toggle:
			for n in get_tree().get_nodes_in_group(g):
				out.append(n)
	elif targets_root:
		_walk_collect(targets_root, out)
	return out

func _walk_collect(n: Node, out: Array[Node]) -> void:
	out.append(n)
	for c in n.get_children():
		_walk_collect(c, out)


func _on_enter(body: Node) -> void:
	if body.is_in_group("jugador"):
		_inside = true
		if not _exit_timer.is_stopped(): _exit_timer.stop()
		if enter_delay > 0.0:
			await get_tree().create_timer(enter_delay).timeout
		_do_activate("enter")

func _on_exit(body: Node) -> void:
	if body.is_in_group("jugador"):
		_inside = false
		if exit_delay <= 0.0:
			_do_deactivate("exit")
		else:
			_exit_timer.start(exit_delay)

func _do_activate(origin: String) -> void:
	var candidates := _collect_targets()
	var changed: Array[Node] = []
	for n in candidates:
		if _toggle_node(n, true):
			changed.append(n)
	_log_detail(true, origin, candidates, changed)

func _do_deactivate(origin: String) -> void:
	if _inside: return
	var candidates := _collect_targets()
	var changed: Array[Node] = []
	for n in candidates:
		if _toggle_node(n, false):
			changed.append(n)
	_log_detail(false, origin, candidates, changed)

func _log_detail(active: bool, origin: String, candidates: Array[Node], changed: Array[Node]) -> void:
	if not debug_logs: return
	var action := "[color=lightgreen]ON[/color]" if active else "[color=salmon]OFF[/color]"
	var sample: Array[String] = []
	var to_list: Array = changed if not debug_show_counts_only else []


	to_list = to_list as Array[Node]

	for i in range(min(to_list.size(), debug_list_limit)):
		var n = to_list[i]
		sample.append("%s(%s)" % [n.name, n.get_class()])
	var tail := " … +%d más" % (to_list.size() - debug_list_limit) if to_list.size() > debug_list_limit else ""
	var extra_sep := ""
	var extra_txt := ""
	if to_list.size() > 0:
		extra_sep = " → "
		extra_txt = ", ".join(sample) + tail

	print_rich("▸ Sector [b]%s[/b] %s (%s): candidatos=%d, cambiados=%d%s%s" % [
	name, action, origin, candidates.size(), changed.size(), extra_sep, extra_txt
])

func _for_each_target(cb: Callable) -> Array[Node]:
	var touched: Array[Node] = []
	if use_groups:
		for g in groups_to_toggle:
			for n in get_tree().get_nodes_in_group(g):
				if cb.call(n): touched.append(n)
	elif targets_root:
		for n in targets_root.get_children():
			_walk(n, cb, touched)
	return touched

func _walk(n: Node, cb: Callable, touched: Array[Node]) -> void:
	if cb.call(n): touched.append(n)
	for c in n.get_children():
		_walk(c, cb, touched)

func _toggle_node(n: Node, active: bool) -> bool:
	var changed := false

	# Visibilidad / dibujo
	if also_toggle_visibility and n is CanvasItem:
		var ci := n as CanvasItem
		if ci.visible != active:
			ci.visible = active
			changed = true

	# Luces
	if n is Light2D:
		var l := n as Light2D
		if l.enabled != active:
			l.enabled = active
			changed = true
		if n.get("shadow_enabled") != null and n.get("shadow_enabled") != active:
			n.set("shadow_enabled", active)
			changed = true

	# Partículas
	if n.has_method("set_emitting"):
		if n.get("emitting") != active:
			n.set_emitting(active)
			changed = true

	# Procesos de script
	if n.has_method("set_process"):
		n.set_process(active); changed = true
	if n.has_method("set_physics_process"):
		n.set_physics_process(active); changed = true

	# Animaciones básicas
	if not active and n.has_method("stop"): n.call_deferred("stop")
	elif active and n.has_method("play"): n.call_deferred("play")

	# Colisiones
	if disable_collisions:
		for cs in n.get_children():
			if cs is CollisionShape2D:
				cs.set_deferred("disabled", not active)
				changed = true

	return changed

func _log_result(active: bool, nodes: Array[Node], origin: String) -> void:
	if not debug_logs: return
	var sector := name
	var action := "[color=lightgreen]ON[/color]" if active else "[color=salmon]OFF[/color]"
	var total := nodes.size()

	if debug_show_counts_only or total == 0:
		print_rich("▸ Sector [b]%s[/b] %s (%s): %d nodos" % [sector, action, origin, total])
		return

	var sample := []
	for i in range(min(total, debug_list_limit)):
		var n := nodes[i]
		sample.append("%s(%s)" % [n.name, n.get_class()])

	var tail := " … +%d más" % (total - debug_list_limit) if total > debug_list_limit else ""
	print_rich("▸ Sector [b]%s[/b] %s (%s): %d nodos → %s%s" %
		[sector, action, origin, total, ", ".join(sample), tail])
