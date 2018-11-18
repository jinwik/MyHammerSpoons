local _M = {}

_M.screen_watcher = nil
_M.app_watcher = nil
_M.app_watcher_started = false
_M.pre_pos = nil
_M.primary_screen_name = hs.screen.primaryScreen():name()

local function set_leftcenter(app)
    local screen = app:mainWindow():screen()
    local rect = screen:fullFrame()
    local center = hs.geometry.rectMidPoint(rect)
    center.x = center.x - rect.w / 4
    hs.mouse.setAbsolutePosition(center)
end

local function is_primary_screen(screen)
    return screen:name() == _M.primary_screen_name
end

local function actived(name, event, app)
    if event == hs.application.watcher.activated then
        -- debug
        -- if not app then print("======> app is nil"); return end
        -- if not app:mainWindow() then print("======> app: " .. app:name() .. " window is nil"); return end
        -- if not app:mainWindow():screen() then print("======> app: " .. app:name() .. " screen is nil"); return end

        local window = app:mainWindow()
        if not window then return end
        local screen = window:screen()
        if not is_primary_screen(screen) then
            _M.pre_pos = hs.mouse.getAbsolutePosition()
            set_leftcenter(app)
        else
            if _M.pre_pos then 
                hs.mouse.setAbsolutePosition(_M.pre_pos)
                _M.pre_pos = nil
            end
        end
    end
end

local function is_multi_screens()
    return #hs.screen.allScreens() > 1
end


function _M.start(self)

    if is_multi_screens() then
        self.app_watcher = hs.application.watcher.new(actived):start()
        self.app_watcher_started = true
    end

    self.screen_watcher = hs.screen.watcher.new(function()
        if is_multi_screens() then
            if not self.app_watcher_started then
                self.app_watcher = self.app_watcher and self.app_watcher or hs.application.watcher.new(actived)
                self.app_watcher:start()
                self.app_watcher_started = true
            end
        else
            if self.app_watcher_started then
                self.app_watcher:stop()
                self.app_watcher_started = false
            end
        end
    end)

    self.screen_watcher:start()

end

return _M