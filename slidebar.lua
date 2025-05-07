Slidebar = {}

function Slidebar:new(props)
    if not (tonumber(props.width) and tonumber(props.height) and type(props.color) == "table") then
        error("[SLIDEBAR]: Width or Height or Color not defined.", 2)
    end

    local instance = {
        -- meta
        width = props.width,
        height = props.height,
        radius = props.radius or 0,
        color = props.color,
        orientation = props.orientation or "x",
        -- extra uses
        useBackground = props.useBackground or false,
        useCircle = props.useCircle or false,
        -- throwback functions
        onSlideThrowback = false,
        onEndThrowback = false,
        -- system
        actualProgress = props.defaultValue or .5,
        smoothProgress = props.useSmooth and {
            actual = props.defaultValue or .5,
            goal = props.defaultValue or .5,
            velocity = props.smoothSpeed or .05
        } or nil
    }

    -- Svg functions
    local function createSvg(width, height, content)
        return svgCreate(width, height, string.format([[<svg width="%s" height="%s" xmlns="http://www.w3.org/2000/svg">%s</svg>]], width, height, content))
    end

    if instance.useCircle then
        local size = (instance.orientation == "x" and instance.height or instance.width)
        local radius = size / 2

        instance.circleSVG = createSvg(size, size, string.format("<circle r='%s' cx='%s' cy='%s' fill='white'/>", radius, radius, radius))
    end

    if instance.radius > 0 then
        instance.barSVG = createSvg(instance.width, instance.height, string.format("<rect rx='%s' width='%s' height='%s' fill='white'/>", instance.radius, instance.width, instance.height))
    end

    -- Index instance
    setmetatable(instance, {
        __index = self
    })

    -- Return instance
    return instance
end

-- System functions
local screenWidth, screenHeight = guiGetScreenSize()
local inFocus = false
local isSliding = false

function Slidebar:updateProgress(x, y, width, height)
    if not isCursorShowing() then
        return false
    end

    -- Cursor
    local cursorAbsoluteX, cursorAbsoluteY = getCursorPosition()
    local cursorX, cursorY = cursorAbsoluteX * screenWidth, cursorAbsoluteY * screenHeight
    local isHover = (cursorX >= x and cursorX <= x + width and cursorY >= y and cursorY <= y + height)
    self.isHover = isHover

    if not (isHover or isSliding) or (inFocus and inFocus ~= self) then
        return false
    end

    if not getKeyState("mouse1") then
        if isSliding and inFocus == self then
            isSliding = false
            inFocus = false

            if self.onEndThrowback then
                self.onEndThrowback(self.actualProgress)
            end
        end

        return false
    end

    -- Variables
    isSliding = true
    inFocus = self

    -- Calc
    local progress = self.orientation == "x" and (cursorX - x) / width or 1 - ((cursorY - y) / height)
    local newProgress = clamp(progress, 0, 1)

    if self.actualProgress ~= newProgress then
        self.actualProgress = newProgress
        if self.smoothProgress then
            self.smoothProgress.goal = self.actualProgress
        end

        if self.onSlideThrowback then
            self.onSlideThrowback(self.actualProgress)
        end
    end
end

-- User functions
function Slidebar:render(x, y, alpha)
    -- System Aliasses
    local width, height  = self.width, self.height
    local barX, barY, barWidth, barHeight = x, y, width, height
    local progress = self.actualProgress
    local orientation = self.orientation
    local isHover = self.isHover or inFocus == self

    -- Draw Aliasses
    local color = self.color
    local colorType = isHover and "hover" or "default"
    
    -- Smooth
    if self.smoothProgress then
        self.smoothProgress.actual = animation(self.smoothProgress.actual, self.smoothProgress.goal, self.smoothProgress.velocity)
        progress = self.smoothProgress.actual
    end

    if orientation == "x" then
        barWidth = barWidth * progress
    else
        barHeight = barHeight * -progress
        barY = barY + height
    end
    
    -- Draw
    if self.useBackground then
        local backgroundColor = color.background[colorType]
        if self.barSVG then
            dxDrawImage(x, y, width, height, self.barSVG, 0, 0, 0, tocolor(backgroundColor[1], backgroundColor[2], backgroundColor[3], backgroundColor[4] * alpha))
        else 
            dxDrawRectangle(x, y, width, height, tocolor(backgroundColor[1], backgroundColor[2], backgroundColor[3], backgroundColor[4] * alpha))
        end
    end

    local barColor = color.bar[colorType]
    if self.barSVG then
        dxDrawImageSection(barX, barY, barWidth, barHeight, 0, 0, barWidth, barHeight, self.barSVG, 0, 0, 0, tocolor(barColor[1], barColor[2], barColor[3],  barColor[4] * alpha)) 
    else
        dxDrawRectangle(barX, barY, barWidth, barHeight, tocolor(barColor[1], barColor[2], barColor[3], barColor[4] * alpha))
    end

    if self.useCircle then
        local circleColor = color.circle[colorType]
        local circleSize = orientation == "x" and height or width
        local circleX, circleY = 0, 0

        if orientation == "x" then
            circleX = (barX + barWidth) - circleSize / 2
            circleY = (barY + barHeight) - circleSize
        else
            circleX = (barX + barWidth) - circleSize
            circleY = (barY + barHeight) - circleSize / 2
        end
        
        dxDrawImage(circleX, circleY, circleSize, circleSize, self.circleSVG, 0, 0, 0, tocolor(circleColor[1], circleColor[2], circleColor[3], circleColor[4] * alpha))
    end

    -- Update progress
    self:updateProgress(x, y, width, height)
end

function Slidebar:getOffset()
    return self.actualProgress
end

function Slidebar:setOffset(value)
    if not value and type(value) ~= "number" then
        return false
    end

    self.actualProgress = clamp(value, 0, 1)
end

function Slidebar:onSlide(throwback)
    if not throwback then
        error("[SLIDEBAR]: Event 'onSlide' Trowback not defined.", 2)
    end

    self.onSlideThrowback = throwback
end

function Slidebar:onEnd(throwback)
    if not throwback then
        error("[SLIDEBAR]: Event 'onEnd' Trowback not defined.", 2)
    end

    self.onEndThrowback = throwback
end

function Slidebar:destroy()
    if inFocus == self then
        inFocus = false
        isSliding = false
    end

    if isElement(self.barSVG) then
        destroyElement(self.barSVG)
    end
    if isElement(self.circleSVG) then
        destroyElement(self.circleSVG)
    end

    self = nil
end

-- Utils
function clamp(number, min, max)
	if (number < min) then
		return min
	elseif (number > max) then
		return max
	end
	return number
end

function animation(a, b, t)
    local r = a + (b - a) * t
    local s = t / 2
    return a < b and math.min(r + s, b) or math.max(r - s, b)
end
