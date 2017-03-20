atrributes = {
  name = "nanoKEY"
}

controls = {}

for i = 0, 127 do
	controls[#controls + 1] = {
		id = i,
		usagePage = 0,
		usage = 0, 
		name = "noteon " .. i,
		minimum = 0,
		maximum = 127,
		expression = "",
	}
	
	local ccNumber = i + 128
	
	controls[ccNumber + 1] = {
		id = ccNumber,
		usagePage = 0,
		usage = 0, 
		name = "cc " .. ccNumber - 128,
		minimum = 0,
		maximum = 127,
		expression = "",
	}
	
end