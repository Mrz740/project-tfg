extends Node

signal frame_dirty  # emitted when anything visual changes


func _ready():
	# optional: emit once to quiet the UNUSED_SIGNAL warning
	FrameDirtyNotifier.emit_signal("frame_dirty")
	pass
