local _M = {}

_M.app_watcher = nil

local EN = 'com.apple.keylayout.ABC'
local ZH = 'com.apple.inputmethod.SCIM.ITABC'

_M.apps = {
    ['IntelliJ IDEA'] = EN,  -- abc
    ['Code'] = EN,
    ['Sublime Text'] = EN,
    ['iTerm2'] = EN,
    ['Google Chrome'] = EN,
}

_M.pre = {}
_M.current = nil

local function actived(name, event, app)
    if event == hs.application.watcher.activated then
        
        -- print(name)
        -- print(hs.keycodes.currentSourceID())

        local input_source = _M.apps[name] or _M.pre[name]
        _M.current = hs.keycodes.currentSourceID()
        if input_source then
            hs.keycodes.currentSourceID(input_source)
        end
    elseif event == hs.application.watcher.deactivated then
        if not name then return end-- deactivated event fired after activated event
        _M.pre[name] = _M.current
    end
end

function _M.start(self)
    self.app_watcher = hs.application.watcher.new(actived):start()
end


return _M