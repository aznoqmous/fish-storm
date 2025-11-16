class_name FixedRandom
var rate := 0.1
var value := 0.0

func pick():
	value += rate
	if value > 1:
		if randf() < rate or value > 2.0:
			reset()
			return true
	return false

func reset():
	value = 0
