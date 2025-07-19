
local timer = {
	timer_arr = {},    
	instances = {}
}

timer.__index = timer

function timer.new(timer_start_value: number?, sync_data: string?, plr: Player?, name: string?)
	
	if timer.timer_arr[name] then return end 
	
	local self = setmetatable({}, timer)

	self.time_val = timer_start_value or 0
	self.on = false
	self._start_time = 0
	self.sync_data = sync_data
	self.sync_data_value = 0
	self.plr = plr
	self.name = name or "unnamed_" .. #timer.timer_arr

	local success, ref
	repeat
		success, ref = pcall(function()
			return self.plr:WaitForChild("session"):WaitForChild(tostring(self.sync_data))
		end)
	until success

	if success then
		self.sync_ref = ref
		self.sync_data_value = ref.Value
	end

	timer.instances[self.name] = self
	table.insert(timer.timer_arr, self.name)

	return self
end

function timer:sync_all()
	for i, timer_name in ipairs(timer.timer_arr) do
		local timer_obj = timer.instances[timer_name]
		if timer_obj and timer_obj.sync_ref then
			local ok, value = pcall(function()
				return timer_obj.sync_ref.Value
			end)
			if ok then
				timer_obj.sync_data_value = value
				timer_obj.time_val = value
			end
		end
	end
end

function timer:get()
	return self.time_val
end

function timer:display(t: number)
	local hours = math.floor(t / 3600)
	local minutes = math.floor((t % 3600) / 60)
	local seconds = math.floor(t % 60)
	local milliseconds = math.floor((t % 1) * 1000)

	return string.format("%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds)
end

function timer:get_normalized()
	return self:display(self.time_val)
end

function timer:start(label)
	
	if self.on then return end
	if not label or typeof(label) ~= "Instance" or not label:IsA("TextLabel") then
		warn("Invalid label passed to timer:start()")
		return
	end

	self.on = true
	self._start_time = os.clock() - self.time_val

	task.spawn(function()
		while self.on do
			task.wait(0.01)

			self.time_val = os.clock() - self._start_time
			label.Text = self:display(self.time_val)

			if self.sync_ref then
				pcall(function()
					self.sync_data_value = self.sync_ref.Value
					self.sync_ref.Value = self.time_val
				end)
			end
		end
	end)
end

function timer:stop()
	self.on = false
end

function timer:destroy()
	self.on = false
	timer.instances[self.name] = nil

	for i, name in ipairs(timer.timer_arr) do
		if name == self.name then
			table.remove(timer.timer_arr, i)
			break
		end
	end
end

return timer
