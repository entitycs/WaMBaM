local JoystickInputProto = require("core.input.joystick")
local keyboard = require("core.input.keyboard")

function CheckConsumeJoy(state)
    -- if joystick.lastButton == state.joyMap then
    --         joystick.lastButton = "none"
    if JoystickInputProto.consumeButtonAny(state.joyMap) then
        return true
    end
    return false
end

function CheckConsumeJoyInstance(js, state)
    -- if joystick.lastButton == state.joyMap then
    --         joystick.lastButton = "none"
    if js:consumeButton(state.joyMap) then
        return true
    end
    return false
end

function CheckConsumeKey(state)
    if keyboard.lastKey == state.keyMap then
        keyboard.lastKey = "none"
        return true
    end
    return false
end

function CheckConsumeInputAny(state)
    return CheckConsumeJoy(state) or CheckConsumeKey(state)
end

function CheckConsumeInputs(state)
    return CheckConsumeJoy(state), CheckConsumeKey(state)
end
