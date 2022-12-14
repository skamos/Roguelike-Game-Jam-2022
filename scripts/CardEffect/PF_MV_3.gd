extends StaticBody2D

export var actif: bool = false
export var speed: float = 10

var ValidPlace: bool = true
signal valid_place(valid)

func _ready() -> void:
	get_node('/root/Level/Play').connect("pressed", self, "Play")
	$AnimatedSprite.play("default")

func _process(delta: float) -> void:
	if !actif:
		if ($SlotArea.get_overlapping_areas().size() > 1 or $SlotArea.get_overlapping_bodies().size() > 0):
			if ValidPlace:
				ValidPlace = false
				emit_signal("valid_place", ValidPlace)
				$AnimatedSprite.modulate = Color('ff5050')
		else:
			if !ValidPlace:
				ValidPlace = true
				emit_signal("valid_place", ValidPlace)
				$AnimatedSprite.modulate = Color('ffffff')

func Play():
	actif = true
	$CollisionShape2D.disabled = false
