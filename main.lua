local timer = {
	
	timer_arr = {}
}

timer.__index = timer

function timer.new(timer_start_value:number?,sync_data:string?,plr:Player?,name:string?)

	local self = setmetatable({}, timer) 
	
	self.time_val = timer_start_value or 0
	self.on = false
	self._start_time = 0
	self.sync_data = sync_data or nil
	self.sync_data_value = 0
	self.plr = plr or nil 
	self.name=name or "unnamed_" .. #timer.timer_arr
	
	if table.find(timer.timer_arr,self.name) then
		return
	end
	
	if self.sync_data and plr then
		self.sync_data_value = plr:WaitForChild("session"):WaitForChild(tostring(self.sync_data)).Value
	end
	
	table.insert(timer.timer_arr,self.name)
	
	return self
end

function timer:sync_all()
	for i, timer_name in ipairs(timer.timer_arr) do
		local timer_obj = timer[timer_name]
		if timer_obj.sync_data and timer_obj.plr then
			timer_obj.sync_data_value = timer_obj.plr:WaitForChild("session"):WaitForChild(tostring(timer_obj.sync_data)).Value
		end
	end
end

function timer:get()
	return self.time_val
end

function timer:display(t)
	local hours = math.floor(t / 3600)
	local minutes = math.floor((t % 3600) / 60)
	local seconds = math.floor(t % 60)
	local milliseconds = math.floor((t % 1) * 1000)

	return string.format("%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds)
end

function timer:get_normalized()
	return timer:display(self.time_val)
end

function timer:start(label)
	if self.on then return end

	self.on = true
	self._start_time = os.clock() - self.time_val

	task.spawn(function()
		while self.on do
			
			task.wait(0.01)
			
			self.time_val = os.clock() - self._start_time
			label.Text = self:display(self.time_val)
			
			if self.sync_data ~= nil and self.plr~=nil then 
				self.sync_data_value = self.plr:WaitForChild("session"):WaitForChild(tostring(self.sync_data)).Value
			end
			self.plr:WaitForChild("session"):WaitForChild(tostring(self.sync_data)).Value=self.time_val
		end
	end)
end

function timer:stop()
	self.on = false
end

return timer
