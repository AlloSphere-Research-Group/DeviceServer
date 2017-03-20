require("osc")
require("fontgl")
require("opengl")

-- window setup
local ctx = "Device Server OSC"
win = Window(ctx, 0, 0, 250, 250)


-- font setup (for displaying OSC message values)
local font = fontgl.Font(LuaAV.findfile("VeraMono.ttf"), 16)
font.color = {1,1,1,1}

-- osc setup
local osc = osc

local sendto_ipaddress = '127.0.0.1'
local sendto_port = 12001
local receiveat_port = 12000

local oscout = osc.Send(sendto_ipaddress, sendto_port) -- hostaddress (string) and port (integer)
local oscin  = osc.Recv(receiveat_port)                -- optional port (integer) (default is 7007)
local xvalue = 0                                       -- will be displayed and changed via OSC
local yvalue = 0

value = 0

local oschandlers = {
  ["/X"] = function(val) xvalue = val end,
  ["/Y"] = function(val) yvalue = val end,
}

function processOSC() -- called in draw loop
    
    
  for msg in oscin:recv() do
  print(now(), msg.addr, unpack(msg))
  	local command = oschandlers[msg.addr]     -- lookup function to call based on OSC address
		if command then                           -- if function exists then
		  pcall(function() command(msg[1]) end)   -- call it
		end
	end
end

function win:draw()
    if(value == 0) then oscout:send('/handshake', 'Test1', receiveat_port) value = 1 end -- send an OSC msg 
    
	processOSC()
    setup_opengl()
		
    font:draw(win.dim[1] / 4, win.dim[2] / 2, 0, 1, "x = " .. xvalue)
    font:draw(win.dim[1] / 4, win.dim[2] / 4, 0, 1, "y = " .. yvalue)    

	--oscout:send('/msg', value + 1) -- send an OSC msg
end

-- needed so that the font displays correctly
function setup_opengl() 
    gl.MatrixMode(gl.PROJECTION)
		gl.LoadIdentity()
		gl.Ortho(0, win.dim[1], win.dim[2], 0, -100, 100)
		
	gl.MatrixMode(gl.MODELVIEW)
		gl.LoadIdentity()
end