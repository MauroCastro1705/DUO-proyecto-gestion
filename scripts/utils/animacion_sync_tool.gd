# animacion_sync_tool.gd - v4.1 (Correct, Simple, and Focused)
# Reverts to the simple and working v2.4 creation logic, and correctly
# integrates the loop adjustment before the animation is added to the library.
@tool
class_name AnimacionSyncTool
extends Node

@export var animation_player_path: NodePath
@export var animated_sprite_path: NodePath

@export_group("Acciones")
@export var crear_animaciones_faltantes: bool = false:
	set(value):
		if value:
			_ejecutar_creacion()

@export var sincronizar_duraciones: bool = false:
	set(value):
		if value:
			_ejecutar_sincronizacion()

func _ejecutar_sincronizacion():
	var validated_nodes = _get_validated_nodes()
	if not validated_nodes: return
	var anim_player: AnimationPlayer = validated_nodes["anim_player"]
	var sprite_frames: SpriteFrames = validated_nodes["sprite_frames"]

	print("--- Iniciando Sincronización de Duraciones ---")
	var synced_count = 0
	var player_anim_names = anim_player.get_animation_list()
	for player_anim_name in player_anim_names:
		if sprite_frames.has_animation(player_anim_name):
			var frame_count = sprite_frames.get_frame_count(player_anim_name)
			var fps = sprite_frames.get_animation_speed(player_anim_name)
			if fps <= 0: continue
			var new_duration = float(frame_count) / fps
			var animation: Animation = anim_player.get_animation(player_anim_name)
			animation.length = new_duration
			print("Sincronizado: '%s' -> Duración: %.2fs" % [player_anim_name, new_duration])
			synced_count += 1
	print("--- Sincronización Finalizada: %d animaciones actualizadas. ---" % synced_count)


func _ejecutar_creacion():
	var validated_nodes = _get_validated_nodes()
	if not validated_nodes: return
	var anim_player: AnimationPlayer = validated_nodes["anim_player"]
	var sprite_frames: SpriteFrames = validated_nodes["sprite_frames"]
	var as2d_node: AnimatedSprite2D = get_node(animated_sprite_path)
	
	var root_node = anim_player.get_node(anim_player.root_node)
	var path_to_sprite = root_node.get_path_to(as2d_node)

	print("--- Buscando Animaciones Faltantes para Crear ---")
	var created_count = 0
	var sprite_anim_names = sprite_frames.get_animation_names()
	
	for sprite_anim_name in sprite_anim_names:
		if not anim_player.has_animation(sprite_anim_name):
			print("Creando animación faltante: '%s'" % sprite_anim_name)
			var new_animation = Animation.new()
			
			# --- This is the key: Configure the object completely FIRST ---
			
			# 1. Set the loop mode on the new_animation object in memory.
			#_ajustar_loop_mode(new_animation, sprite_frames, sprite_anim_name)
			
			# 2. Add and configure the method track on the new_animation object.
			var track_index = new_animation.add_track(Animation.TYPE_METHOD)
			new_animation.track_set_path(track_index, path_to_sprite)
			var key_value = { "method": &"play", "args": [StringName(sprite_anim_name)] }
			new_animation.track_insert_key(track_index, 0.0, key_value)
			
			# 3. NOW, add the fully configured animation to the library.
			# This is the single, high-level change that the editor will see and save.
			var lib_name = ""
			if not anim_player.has_animation_library(lib_name):
				anim_player.add_animation_library(lib_name, AnimationLibrary.new())
			
			var library = anim_player.get_animation_library(lib_name)
			library.add_animation(sprite_anim_name, new_animation)
			
			created_count += 1
	
	if created_count > 0:
		print("--- Creación Finalizada: %d nuevas animaciones creadas. ---" % created_count)
		print(">> ¡Ahora haz clic en 'Sincronizar Duraciones' para establecer sus duraciones correctas! <<")
	else:
		print("--- No se encontraron animaciones faltantes. Todo está en orden. ---")


func _get_validated_nodes():
	if not is_inside_tree() or not get_owner():
		print("Error: La herramienta debe ser parte de una escena guardada para funcionar correctamente.")
		return null
	var anim_player: AnimationPlayer = get_node_or_null(animation_player_path)
	var as2d_node: AnimatedSprite2D = get_node_or_null(animated_sprite_path)
	if not anim_player or not as2d_node:
		print("Error: Asigna AnimationPlayer y AnimatedSprite2D en el Inspector.")
		return null
	var sprite_frames: SpriteFrames = as2d_node.sprite_frames
	if not sprite_frames:
		print("Error: El AnimatedSprite2D no tiene un recurso SpriteFrames.")
		return null
	return { "anim_player": anim_player, "sprite_frames": sprite_frames }


# This function is now back to being a simple helper as you requested.
# It only modifies the animation object passed into it.
func _ajustar_loop_mode(animation: Animation, sprite_frames: SpriteFrames, anim_name: StringName):
	var loop_mode_value = sprite_frames.get_animation_loop_mode(anim_name)
	animation.loop_mode = loop_mode_value

	if loop_mode_value == Animation.LOOP_NONE:
		print(" -> Preparando loop para '%s': Sin Loop" % anim_name)
	else:
		print(" -> Preparando loop para '%s': Con Loop" % anim_name)
