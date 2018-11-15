local _M = {}

_M.app_watcher = nil

local EN = 'com.apple.keylayout.ABC'
local ZH = 'com.apple.inputmethod.SCIM.ITABC'

_M.apps = {
    ['IntelliJ IDEA'] = EN,  -- abc
    ['Code'] = EN,
    ['Sublime Text'] = EN,
    ['iTerm2'] = EN,
}

local function actived(name, event, app)
    if event == hs.application.watcher.activated then
        
        -- print(name)
        -- print(hs.keycodes.currentSourceID())

        local input_source = _M.apps[name]
        if input_source then
            hs.keycodes.currentSourceID(input_source)
        end
    end
end

function _M.start(self)
    self.app_watcher = hs.application.watcher.new(actived):start()
end


return _M