require"logging.file"
--Ô­Í¼Ä¿Â¼
local ORIGINAL_IMAGE_ROOT = "/www/target/docdir/images/"
--ËõÂÔÍ¼Ä¿Â¼
local THUMBNAIL_IMAEG_ROOT = "/www/target/docdir/images/thumbnail"

local THUMNAIL_LOCATION = "/outer_thumbnail/"
local INNER_IMAGE_LOCATION = "/internal_images/"
local INNER_THUMBNAIL_LOCATION = "/internal_thumbnail/"

local logger = require"xiulogger" 

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


function getURI(thumbnailSupport, reqPath, reqPath1)

	if not thumbnailSupport or thumbnailSupport == "0" then
		return INNER_IMAGE_LOCATION .. reqPath1
	end
	
	if not reqPath or reqPath == "" then		
		return nil
	end
	
	local filePath = appendPathSimbol2Tail(ORIGINAL_IMAGE_ROOT) .. reqPath
	logger:info(filePath)

	if isFileExists(filePath) then
		--find the file in original image root			
		return INNER_IMAGE_LOCATION .. reqPath
	end
	
	filePath = appendPathSimbol2Tail(THUMBNAIL_IMAEG_ROOT) .. reqPath	
	logger:info(filePath)
	
	if isFileExists(filePath) then
		--find the file in thumbnailImageRoot		
		return INNER_THUMBNAIL_LOCATION .. reqPath
	else				
		return THUMNAIL_LOCATION .. reqPath
	end

end

local thumbnailSupport = ngx.var.thumbnailSupport
local reqPath = removePathSimbolAtHead(ngx.var.reqPath)
local reqPath1 = removePathSimbolAtHead(ngx.var.reqPath1)
logger:info(thumbnailSupport)
logger:debug(reqPath)
logger:debug(reqPath1)

local aURI = getURI(thumbnailSupport, reqPath, reqPath1)

logger:info(aURI)
if aURI then
	ngx.req.set_uri(aURI, true)	
end

