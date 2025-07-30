Pulse = {
    New = function(self, secondsPerPulse, count)
        local obj = {CurrentTime = 0, SecondsPerPulse = secondsPerPulse, Count = count or -1}
        setmetatable(obj, self)
        self.__index = self
        obj.CheckPulse = function(this)
            local time = GetTime() - this.CurrentTime
            local doPulse = time >= this.SecondsPerPulse
            local newCount = this.Count

            if doPulse then
                this.CurrentTime = GetTime()
                if newCount > 0 then
                    newCount = newCount - 1
                end
            end

            if this.Count > 0 then
                this.Count = newCount
                return doPulse
            elseif this.Count == -1 then
                return doPulse
            else
                return false
            end
        end

        obj.Reset = function(this, newCount)
            this.CurrentTime = GetTime()
            this.Count = newCount or -1
        end

        return obj
    end,
}