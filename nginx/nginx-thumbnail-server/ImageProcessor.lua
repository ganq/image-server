module("ImageProcessor",package.seeall)

require "zhelpers"
require "zmq"

local format = string.format
local json = require('cjson')

local context = zmq.init(1)
local ImageProcessor = {}
local gm = require 'graphicsmagick'
ImageProcessor.__index = ImageProcessor

local logger = require"xiulogger" 

local function mkdirs(dirname)
	os.execute("mkdir -p " .. dirname)
end


local function isFileExists(fileName)
	local f = io.open(fileName,"r")
       logger:info("***fileName:" .. fileName)	
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
	local sender = context:socket(zmq.DEALER)
	local identity = format("%04X-%04X", randof (0x10000), randof (0x10000))
	sender:setopt(zmq.IDENTITY, identity)
	if sender then		
		sender:connect(serverUrl)		
		sender:send(message)
		sender:close()
		logger:info("sent message:[" .. message .. "]")
	else
		logger:info("open socket failed")
	end
end

function split(szFullString, szSeparator)
	local nFindStartIndex = 1
	local nSplitIndex = 1
	local nSplitArray = {}
	while true do
	   local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
	   if not nFindLastIndex then
	    nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
	    break
	   end
	   nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
	   nFindStartIndex = nFindLastIndex + string.len(szSeparator)
	   nSplitIndex = nSplitIndex + 1
	end
	return nSplitArray
end

function ImageProcessor:extractThumbInfo(oriRequestPath)

local pos1,pos2,oriImgName,sizeStr1,sizeStr2 = string.find(oriRequestPath, "/([^/]*)[.]([0-9*]+)[X|x]([0-9*]+)[.][png|jpg|gif]")	
	logger:info("oriRequestPath:" .. oriRequestPath)
	if not pos1 then
		return nil
	end
   
	if pos1 < 0 then
		return false
	end
		
	local relativePath = appendPathSimbol2Tail(removePathSimbolAtHead(string.sub(oriRequestPath, 0, pos1)))
	logger:info("relativePath:" .. relativePath)
	local len = string.len(oriRequestPath)
        local prefix = string.sub(oriRequestPath,len-3,len)
	
    
	local requestImageName = relativePath .. oriImgName .. "_" .. sizeStr1 .. "*" .. sizeStr2 .. prefix
	
	logger:info("***reqImageName:" .. requestImageName)
	logger:info("***oriImgName:" .. oriImgName)
	
    local width,height = nil, nil	
	
	if sizeStr1 ~= "*" and sizeStr1 ~= "0" then
		width = tonumber(sizeStr1)
	end
	
	if sizeStr2 ~= "*" and sizeStr2 ~= "0"	then
		height = tonumber(sizeStr2)
	end

	 local sourceImageName = self.originalImagesRoot.. relativePath .. oriImgName .. prefix
	logger:info( "***sourceImageName:" .. sourceImageName)

	local targetFolder = self.thumbnailImagesRoot .. relativePath
	
	local targetImageName = self.thumbnailImagesRoot.. requestImageName
	logger:info( "***targetImageName:" .. targetImageName)
	
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

startswith = function(str, substr)
	if str == nil or substr == nil then
		return nil, "the string or the sub-stirng parameter is nil"
	end
	if string.find(str, substr) > 0 then
		return false
	else
		return true
	end
end

local function table_contains(tbl, data) 
  for _k, v in pairs(tbl) do
	if v == data then
		return true;
	end
end
	return false;
end

local function processImage(sourceImageName, 
	targetImageName,targetFolder, width, height, 
	permitedSizes, sendMessageFlag, 
	serverUrl, 
	originalImagesRoot, thumbnailImagesRoot,toGenWaterMark, waterMarkConfig, logoPath
	)
	logger:info("***sourceImageName:" .. sourceImageName )	
	if not isFileExists(sourceImageName) then
		logger:info(sourceImageName .. " not found.")
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
			logger:info("***Begin to generate thumbnail:"..targetImageName)		
			mkdirs(targetFolder)
                        local i_width,i_height = image:size()

			local logo = logoPath
			if toGenWaterMark and waterMarkConfig.logoPath then
				logo = waterMarkConfig.logoPath
			end
	
			local rsize = image:thumbnail4LargeImgs(width, height)	
                        if toGenWaterMark and waterMarkConfig.waterMarkType == 5 then
                                image:addWaterMark(logo, "OverCompositeOp", 0, 0, 600,600)
                        end

                        if toGenWaterMark and waterMarkConfig.waterMarkType == 1 then
                                image:addWaterMark(logo, "OverCompositeOp", rsize.x + rsize.rwidth - 120, rsize.y + rsize.rheight - 57, 100 ,37.0)
                        end

                        if toGenWaterMark and waterMarkConfig.waterMarkType == 6 then
                                image:addWaterMark(logo, "OverCompositeOp", width/2 - 50, height/2 - 19, 100.0 ,37.0)
                        end

			image:save(targetImageName)
			
			logger:info("***complete the generation." .. targetImageName)
			successFlag = true
		else 
			logger:info("***not permited sizes." .. sizeStr)
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
		logger:info("***graphicsmagick not found.")
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
			
			local jsonMsg = json.encode(msg)
			
			sendMessage(jsonMsg, self.serverUrl)
		end
	logger:info("***".. thumbInfo.sourceImageName)			
	
	if not thumbInfo.targetFileExists then
			 logger:info("**file compress" )
	local toGenWaterMark = thumbInfo.width and thumbInfo.width >=400 or thumbInfo.height and thumbInfo.height >= 400;
	local waterMarkConfig = nil;
	if toGenWaterMark then
		local isRightKey = false;

		local tempTbl = split(thumbInfo.requestImageName,"/")

		local imgDic = tempTbl[2];
		if self.waterMarkImagesKeys then
			for _k, v in pairs(self.waterMarkImagesKeys) do
				if imgDic == v.folder then
					isRightKey = true;
					waterMarkConfig = v;
					break;
				end
			end
		end
		toGenWaterMark = isRightKey; 
	end
        local rs,err = pcall(processImage, thumbInfo.sourceImageName, thumbInfo.targetImageName, thumbInfo.targetFolder, thumbInfo.width, thumbInfo.height, self.permitedSizes, self.sendMessageFlag, self.serverUrl, self.originalImagesRoot, self.thumbnailImagesRoot, toGenWaterMark, waterMarkConfig, self.logoPath)			
if not rs then
				logger:info("***Error on geneate thumbnail." .. err)
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
			sendMessageFlag4EveryReq = processConfig.sendMessageFlag4EveryReq,
			waterMarkImagesKeys = processConfig.waterMarkImagesKeys,
			logoPath = processConfig.logoPath
        } , ImageProcessor )
end


return ImageProcessor
