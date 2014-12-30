module("xiulogger",package.seeall)

require"logging"

local LOG_FILE = string.format("/var/log/imgprocess/imgprocess-%s.log",os.date("%Y-%m-%d"))

local f = io.open(LOG_FILE, "a")
if not f then
	print("Create log file LOG_FILE failed.")	
	return nil
end

f:setvbuf ("line")
local logger = logging.new( function(self, level, message)
						local s = logging.prepareLogMsg(LOG_PATTERN, os.date(), level, message)
						f:write(s)						
						return true
					end
				  )
				
logger:setLevel (logging.INFO)
return logger
