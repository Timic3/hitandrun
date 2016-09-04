nametag = {}
local nametags = {}
local g_screenX,g_screenY = guiGetScreenSize()
local bHideNametags = false

local NAMETAG_SCALE = 0.3
local NAMETAG_ALPHA_DISTANCE = 50
local NAMETAG_DISTANCE = 120
local NAMETAG_ALPHA = 120
local NAMETAG_TEXT_BAR_SPACE = 2
local NAMETAG_WIDTH = 50
local NAMETAG_HEIGHT = 5
local NAMETAG_TEXTSIZE = 0.7
local NAMETAG_OUTLINE_THICKNESS = 1.2

local NAMETAG_ALPHA_DIFF = NAMETAG_DISTANCE - NAMETAG_ALPHA_DISTANCE
NAMETAG_SCALE = 1/NAMETAG_SCALE * 800 / g_screenY 

local maxScaleCurve = { {0, 0}, {3, 3}, {13, 5} }
local textScaleCurve = { {0, 0.8}, {0.8, 1.2}, {99, 99} }
local textAlphaCurve = { {0, 0}, {25, 100}, {120, 190}, {255, 190} }

function nametag.create ( player )
    nametags[player] = true
end

function nametag.destroy ( player )
    nametags[player] = nil
end

addEventHandler ( "onClientRender", root,
    function()
        for i, v in ipairs(getElementsByType"player") do
            if v ~= localPlayer then
                setPlayerNametagShowing ( v, false )
                if not nametags[v] then
                    nametag.create ( v )
                end
            end
        end
        if bHideNametags then
            return
        end
        local x,y,z = getCameraMatrix()
        for v in pairs(nametags) do 
            while true do
                if not isPedInVehicle(v) or isPedDead(v) then break end
                local vehicle = getPedOccupiedVehicle(v)
                local px,py,pz = getElementPosition ( vehicle )
                local pdistance = getDistanceBetweenPoints3D ( x,y,z,px,py,pz )
                if pdistance <= NAMETAG_DISTANCE then
                    local sx,sy = getScreenFromWorldPosition ( px, py, pz+0.95, 0.06 )
                    if not sx or not sy then break end
                    local scale = 1/(NAMETAG_SCALE * (pdistance / NAMETAG_DISTANCE))
                    local alpha = ((pdistance - NAMETAG_ALPHA_DISTANCE) / NAMETAG_ALPHA_DIFF)
                    alpha = (alpha < 0) and NAMETAG_ALPHA or NAMETAG_ALPHA-(alpha*NAMETAG_ALPHA)
                    scale = math.evalCurve(maxScaleCurve,scale)
                    local textscale = math.evalCurve(textScaleCurve,scale)
                    local textalpha = math.evalCurve(textAlphaCurve,alpha)
                    local outlineThickness = NAMETAG_OUTLINE_THICKNESS*(scale)
                    local r,g,b = 255,255,255
                    local team = getPlayerTeam(v)
                    if team then
                        r,g,b = getTeamColor(team)
                    end
                    local offset = (scale) * NAMETAG_TEXT_BAR_SPACE/2
					if isLineOfSightClear( x, y, z, px, py, pz, true, false, false, true, false, false, false,v ) then
						dxDrawText ( getPlayerName(v):gsub("#%x%x%x%x%x%x",""), sx+1.2, (sy+1.2 - offset), sx+1.2, (sy+1.2 - offset), tocolor(0,0,0,255 or textalpha), textscale*NAMETAG_TEXTSIZE, "default-bold", "center", "bottom", false, false, false, true, true )
						dxDrawText ( getPlayerName(v), sx, sy - offset, sx, sy - offset, tocolor(r,g,b,textalpha), textscale*NAMETAG_TEXTSIZE, "default-bold", "center", "bottom", false, false, false, true, true )
					end
				end
                break
            end
        end
    end
)

addEventHandler('onClientResourceStart', resourceRoot,
    function()
        for i, v in ipairs(getElementsByType"player") do
            if v ~= localPlayer then
                nametag.create ( v )
            end
        end
    end
)

addEventHandler ( "onClientPlayerJoin", root,
    function()
        if source == localPlayer then return end
        setPlayerNametagShowing ( source, false )
        nametag.create ( source )
    end
)

addEventHandler ( "onClientPlayerQuit", root,
    function()
        nametag.destroy ( source )
    end
)


addEvent ( "onClientScreenFadedOut", true )
addEventHandler ( "onClientScreenFadedOut", root,
    function()
        bHideNametags = true
    end
)

addEvent ( "onClientScreenFadedIn", true )
addEventHandler ( "onClientScreenFadedIn", root,
    function()
        bHideNametags = false
    end
)

-- Math extensions

function math.lerp(from,to,alpha)
    return from + (to-from) * alpha
end

function math.clamp(low,value,high)
    return math.max(low,math.min(value,high))
end

function math.wrap(low,value,high)
    while value > high do
        value = value - (high-low)
    end
    while value < low do
        value = value + (high-low)
    end
    return value
end

function math.wrapdifference(low,value,other,high)
    return math.wrap(low,value-other,high)+other
end

function math.evalCurve( curve, input )
    if input<curve[1][1] then
        return curve[1][2]
    end
    for idx=2,#curve do
        if input<curve[idx][1] then
            local x1 = curve[idx-1][1]
            local y1 = curve[idx-1][2]
            local x2 = curve[idx][1]
            local y2 = curve[idx][2]
            local alpha = (input - x1)/(x2 - x1);
            return math.lerp(y1,y2,alpha)
        end
    end
    return curve[#curve][2]
end
