local timer = {}

local WAIT_TIME = 0.001

timer.__index = timer

function timer.new(time_value)
	local self = setmetatable({}, timer)
	self.time_val = time_value or 0
	self.on = false
	return self
end

function timer:stop()
	self.on = false
end

function timer:start()
	
	if self.on then return end
	self.on = true
	
	spawn(function()
		while self.on  do
			task.wait(WAIT_TIME)
			self.time_val += WAIT_TIME
		end
	end)
end

function timer:display()
	local minutes = math.floor((self.time_val % 3600) / 60)
	local seconds = math.floor(self.time_val % 60)
	local milliseconds = math.floor((self.time_val - math.floor(self.time_val)) * 1000)

	return string.format("%02d:%02d.%03d", minutes, seconds, milliseconds)
end

return timer
