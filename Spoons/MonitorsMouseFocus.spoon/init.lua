local _M = {}

_M.screen_watcher = nil
_M.app_watcher = nil
_M.app_watcher_started = false
_M.pos_cache = {}
_M.pos = nil


local function leftcenter(screen)

    local rect = screen:fullFrame()
    local pos = hs.geometry.rectMidPoint(rect)
    pos.x = pos.x - rect.w / 4
    return pos

end


-- local function is_mouse_on_top(app)
--     local window = app:focusedWindow()
--     if not window then return true end

--     local screen = window:screen()
--     local rect = screen:fullFrame()

--     local pos = hs.mouse.getAbsolutePosition()

--     return rect.x < pos.x and pos.x < rect.x + rect.w

-- end


local function is_pos_at_the_screen(pos, screen)

    local rect = screen:fullFrame()

    return rect.x < pos.x and pos.x < rect.x + rect.w

end

local function actived(name, event, app)

    if event == hs.application.watcher.activated then

        _M.pos = hs.mouse.getAbsolutePosition()
        local win = hs.window.focusedWindow()
        local screen = win:screen()

        if screen:id() ~= hs.mouse.getCurrentScreen():id() then
            local pos = _M.pos_cache[screen:id()] or leftcenter(screen)
            hs.mouse.setAbsolutePosition(pos)
        end
    
    elseif event == hs.application.watcher.deactivated then

        local pos = _M.pos
        if not pos then return end

        local win = app:focusedWindow()
        if not win then return end

        local screen = win:screen()
        if is_pos_at_the_screen(pos, screen) then
            _M.pos_cache[screen:id()] = pos
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
                print("app watcher started.")
            end
        else
            if self.app_watcher_started then
                self.app_watcher:stop()
                self.app_watcher_started = false
                print("app watcher stopped.")
            end
        end
    end)

    self.screen_watcher:start()

end

return _M