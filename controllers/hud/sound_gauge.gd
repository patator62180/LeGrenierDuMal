class_name SoundGauge
extends Control

const VALUE_MAX_SCALE = 2.005
const TIP_MAX_X = 297

const TIP_MIN_X = -270
const VALUE_MIN_SCALE = 0.1

@onready var _value: TextureRect = $Gauge/Value
@onready var _tip: TextureRect = $Gauge/Tip

var value: float:
    set(v):
        _value.scale.x = remap(v, 0, 1, VALUE_MIN_SCALE, VALUE_MAX_SCALE)
        _tip.position.x = remap(v, 0, 1, TIP_MIN_X, TIP_MAX_X)

func _ready():
    value = 0
