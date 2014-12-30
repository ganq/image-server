module("ImageProcessor",package.seeall)
require "zmq"
json = require('json')

local context = zmq.init(1)
local ImageProcessor = {}
local gm = require 'graphicsmagick'
ImageProcessor.__index = ImageProcessor


local function mkdirs(dirname)
	os.execute("mkdir -p " .. dirname)
end


local function isFileExists(fileName)
	local f = io.open(fileName,"r")
	
	if f ~= nil then
		io.close(f)
		return true
	end
	
	return false
end

local function appendPathSimbol2Tail(str) 
	local l = string.len(str)
	local s = string.sub(str, l, l)
	if s ~= "/" then
		return str .. "/"
	else 
		return str	
	end
end

local function removePathSimbolAtHead(str)
	local l = string.len(str)
	
	local s = string.sub(str, 1, 1)
	if s == "/" then
		return string.sub(str, 2, string.len(str))
	else 
		return str	
	end
end

local function sendMessage(message, serverUrl)
	local sender = context:socket(zmq.REQ)
	if sender then		
		sender:connect(serverUrl)		
		sender:send(message)
		sender:close()
		print("sent message:" .. message)
	else
		print("open socket failed")
	end
end

function ImageProcessor:extractThumbInfo(oriRequestPath)
	local pos1,pos2,imgName1,imgIndex,sizeStr1,sizeStr2 = string.find(oriRequestPath, "/([^/]*)([0-9]?)[_]([0-9*]+)[_]([0-9*]+)[.]jpg")
	
	if not pos1 then
		return nil
	end
   
	if pos1 < 0 then
		return false
	end
		
	local relativePath = appendPathSimbol2Tail(removePathSimbolAtHead(string.sub(oriRequestPath, 0, pos1)))
	--print("relativePath:" .. relativePath)
	
	local requestImageName = relativePath .. imgName1 .. imgIndex .. "_" .. sizeStr1 .. "_" .. sizeStr2 .. ".jpg"		
    
	local oriImgName = imgName1
	if pos1 > 0 then
		if imgName1 == "g" then
			oriImgName = "ori"			
		end
	end	
	
	--print("reqImageName:" .. requestImageName)
	--print("oriImgName:" .. oriImgName .. imgIndex)
	
    local width,height = nil, nil	
	
	if sizeStr1 ~= "*" and sizeStr1 ~= "0" then
		width = tonumber(sizeStr1)
	end
	
	if sizeStr2 ~= "*" and sizeStr2 ~= "0"	then
		height = tonumber(sizeStr2)
	end

	local sourceImageName = self.originalImagesRoot.. relativePath .. oriImgName .. imgIndex .. ".jpg"
	--print( "sourceImageName:" .. sourceImageName)

	local targetFolder = self.thumbnailImagesRoot .. relativePath
	
	local targetImageName = self.thumbnailImagesRoot.. requestImageName
	--print( "targetImageName:" .. targetImageName)
	
	local targetFileExists = isFileExists(targetImageName)
	
	return {
			isThumbRequest = true, 
			targetFileExists = targetFileExists, 
			sourceImageName = sourceImageName, 
			requestImageName = requestImageName, 
			targetFolder = targetFolder, 
			targetImageName = targetImageName, 
			width = width, 
			height = height
			}
	
end


local function table_contains(tbl, data) 
  for _k, v in pairs(tbl) do
	if v == data then
		return true;
	end
end
	return false;
end

local function resizeImage(sourceImageName, 
	targetImageName, width, height, 
	permitedSizes, sendMessageFlag, 
	serverUrl, widthLimit, heightLimit,
	originalImagesRoot, thumbnailImagesRoot
	)
	
	if not isFileExists(sourceImageName) then
		print(sourceImageName .. " not found.")
		return false
	end
	local image = gm.Image(sourceImageName)
			
	if image ~= nil then
		--resize the image
		--make the ground be white
		local pixwand = image:newPixWand(255,255,255)
		image:setBackgroundColor(pixwand)

		local sizeStr = ""
		if width then
			sizeStr = sizeStr .. width;
		else
			sizeStr = "0"
		end
		sizeStr = sizeStr .. "x"

		if height then
			sizeStr = sizeStr .. height
		else
			sizeStr = sizeStr .. "0"
		end
		
		local successFlag = false
		
		if table_contains(permitedSizes, sizeStr) then 	
			
			image:thumbnail4LargeImgs(width, height, widthLimit, heightLimit)		

			print("Begin to generate thumbnail:"..targetImageName)	
			image:save(targetImageName)	
			
			print("complete the generation." .. targetImageName)
			successFlag = true
		else 
			successFlag = false
		end
		
		if sendMessageFlag and successFlag then
			local msg = {}
			msg.msgType = 2
			msg.sourceImageName = removePathSimbolAtHead(string.sub(sourceImageName, string.len(originalImagesRoot)))
			msg.targetImageName = removePathSimbolAtHead(string.sub(targetImageName, string.len(thumbnailImagesRoot)))
			msg.width = width
			msg.height = height
			
			
			local jsonMsg = json.encode(msg)
			sendMessage(jsonMsg, serverUrl)			
		end 
		
		
		return successFlag		
	
	else
		print("graphicsmagick not found.")
		return false
	end	
end

function ImageProcessor:resolveImageURI(oriRequestPath)
	local thumbInfo  = self:extractThumbInfo(oriRequestPath)
	if not thumbInfo then
		return nil
	end
	
	if thumbInfo.isThumbRequest then
		if self.sendMessageFlag4EveryReq then
			local msg= {}
			msg.msgType = 1
			msg.oriRequestPath = oriRequestPath
			
			local jsonMsg = json.encode(test)
			
			sendMessage(jsonMsg, self.serverUrl)
		end
			
		if not thumbInfo.targetFileExists then
			mkdirs(thumbInfo.targetFolder)
			local rs,err = pcall(resizeImage, thumbInfo.sourceImageName, thumbInfo.targetImageName, thumbInfo.width, thumbInfo.height, self.permitedSizes, self.sendMessageFlag, self.serverUrl, self.widthLimit, self.heightLimit, self.originalImagesRoot, self.thumbnailImagesRoot)
			if not rs then
				print("Error on geneate thumbnail." .. err)
				return nil
			end
		end
		
		return self.thumbnailLocation .. thumbInfo.requestImageName
	else 
		return nil
	end
end

function ImageProcessor:new(processConfig)	
	thumbnailLocation = appendPathSimbol2Tail(processConfig.thumbnailLocation)
	originalImagesRoot = appendPathSimbol2Tail(processConfig.originalImagesRoot)
	thumbnailImagesRoot = appendPathSimbol2Tail(processConfig.thumbnailImagesRoot)
	
    return setmetatable ( {			
			originalImagesRoot = originalImagesRoot ,
			thumbnailImagesRoot = thumbnailImagesRoot,
			thumbnailLocation = thumbnailLocation,
			permitedSizes = processConfig.permitedSizes,
			sendMessageFlag = processConfig.sendMessageFlag,			
			serverUrl = processConfig.serverUrl,
			widthLimit = processConfig.widthLimit,
			heightLimit = processConfig.heightLimit,			
			sendMessageFlag4EveryReq = processConfig.sendMessageFlag4EveryReq			
        } , ImageProcessor )
end


return ImageProcessor
