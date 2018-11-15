local _M = {}

_M.screen_watcher = nil
_M.app_watcher = nil
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
        local screen = app:mainWindow():screen()
        if not is_primary_screen(screen) then
            _M.pre_pos = hs.mouse.getAbsolutePosition()
            set_leftcenter(app)
        elseif _M.pre_pos then
            hs.mouse.setAbsolutePosition(_M.pre_pos)
            _M.pre_pos = nil
        end
    end
end

local function is_multi_screens()
    return #hs.screen.allScreens() > 1
end


function _M.start(self)

    if is_multi_screens() then
        self.app_watcher = hs.application.watcher.new(actived):start()
    end

    self.screen_watcher = hs.screen.watcher.new(function()

        if is_multi_screens() then
            self.app_watcher:start()
        else
            self.app_watcher:stop()
        end
    end)

    self.screen_watcher:start()

end

return _M