Hooks:PostHook( MoneyManager, "_setup", "MIHInit", function(self)
	self.catch_reduction_to_persist = 0
	self.previous_stored_cash = 0
end)

function MoneyManager:send_to_the_persist(amount)
	self.catch_reduction_to_persist = self.catch_reduction_to_persist + amount
end

function MoneyManager:retrieve_the_persist()
	return self.catch_reduction_to_persist
end

Hooks:PostHook( MoneyManager, "civilian_killed", "MoneyInHud2", function(self)
	self:send_to_the_persist(self:get_civilian_deduction())
end)

