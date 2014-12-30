local format = string.format
require "zmq"
require "zhelpers"
local json = require('cjson')
local zmsg = require"zmsg"
require"logging.file"

local logger = logging.file("compress%s.log", "%Y-%m-%d")

local context = zmq.init(1)


local RECEIEVE_SERVER_URL = "tcp://172.16.3.28:5560"
local RESEND_SERVER_URL = "tcp://172.16.3.28:5561"
local COMPRESS_COMMAND = "'/www/target/compressimage/program/page-speed-1.9/out/Release/optimize_image_bin' "
local ORIGINAL_IMAGE_ROOT = "/www//images/public/"
local THUMBNAIL_IMAEG_ROOT = "/www/images/public/thumbnail"


local function appendPathSimbol2Tail(str)
	if not str then
		return nil
	end
		
	local l = string.len(str)
	local s = string.sub(str, l, l)
	if s ~= "/" then
		return str .. "/"
	else
		return str
	end
end

local function removePathSimbolAtHead(str)
	if not str then
		return nil
	end
	local l = string.len(str)

	local s = string.sub(str, 1, 1)
	if s == "/" then
		return string.sub(str, 2, string.len(str))
	else
		return str
	end
end


local function isFileExists(fileName)
	local f = io.open(fileName,"r")

	if f ~= nil then
		io.close(f)
		return true
	end

	return false
end

function compressImage(imageFullPath)
	if isFileExists(imageFullPath) then
		local tempFile = imageFullPath .. ".comps.jpg"
		local compressCmd = COMPRESS_COMMAND .." '" .. imageFullPath .. "' '" .. tempFile .. "'"
		logger:info(compressCmd)

		os.execute(compressCmd)

		if isFileExists(tempFile) then
			os.execute("mv -f '" .. tempFile .. "' '" .. imageFullPath .. "'")
			logger:info("image compress success." .. imageFullPath)
		end
	else
		logger:info("file not exist:" .. imageFullPath)
	end
end


local function sendMessage(message, serverUrl)
	local sender = context:socket(zmq.DEALER)
	if sender then
		local identity = format("%04X-%04X", randof (0x10000), randof (0x10000))
		sender:setopt(zmq.IDENTITY, identity)
		sender:connect(serverUrl)
		sender:send(message)
		sender:close()
		logger:info("sent message:[" .. message .. "]")
	else
		logger:info("open socket failed")
	end
end

function onMessageArrive(jsonMsg)
	local msg = json.decode(jsonMsg)

	if not msg then
		logger:info("Failed to decode message:[" .. jsonMsg .. "]")
		return false
	end

	if not msg.sourceImageName then
		return false
	end

	--compress the dynamic generated thumbnail in thumbnail folder directly
    if msg.msgType == 2 then
        local imageFullPath = appendPathSimbol2Tail(THUMBNAIL_IMAEG_ROOT) .. removePathSimbolAtHead(msg.targetImageName)
        compressImage(imageFullPath)
	    sendMessage(jsonMsg, RESEND_SERVER_URL)
		return true
	elseif msg.msgType == 3 then
		--compress the image or thumbnail in public images folder	
        local imageFullPath = appendPathSimbol2Tail(ORIGINAL_IMAGE_ROOT) .. removePathSimbolAtHead(msg.imagePath)
		compressImage(msg.imagePath)
		return true
	else
		logger:info("unknown msg type:" .. msg.msgType)
		return false
	end
end


--  Socket to talk to clients
local socket = context:socket(zmq.DEALER)
socket:setopt(zmq.IDENTITY, "COMPRESS")
socket:connect(RECEIEVE_SERVER_URL)

while true do
    -- Wait for next request from client
	local aZmsg = zmsg.recv(socket)		
	local address = aZmsg:pop()
	local jsonMsg = aZmsg:pop()
	logger:info(jsonMsg)
	if jsonMsg and string.len(jsonMsg) > 0 then
		logger:info("msg:("..jsonMsg..")")
		local flag, err = pcall(onMessageArrive, jsonMsg)
		if not flag then
			logger:error(err)	
			local aZmsg = zmsg.new()
			aZmsg:push("failed")
			aZmsg:push(address)
			aZmsg:send(socket)			
		else
			local aZmsg = zmsg.new()
			aZmsg:push("success")
			aZmsg:push(address)
			aZmsg:send(socket)			
		end
	end
end

--  We never get here but clean up anyhow
socket:close()
context:term()
