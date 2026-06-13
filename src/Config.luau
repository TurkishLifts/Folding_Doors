local config = {
	Opening = {
		Time = 2.2,
		Delay = 0.5, -- You are recommended to keep this above 0.5. Lower delays may result in unexpected glitches.
		EasingStyle = Enum.EasingStyle.Sine,
		EasingDirection = Enum.EasingDirection.Out,
	},
	Closing = {
		Time = 2.25,
		Delay = 0.5,
		EasingStyle = Enum.EasingStyle.Sine,
		EasingDirection = Enum.EasingDirection.Out,
	}
}

return config
