local imageProcessor = require "ImageProcessor"
local permitedSizes = {
"600x600",
"400x400",
"220x220",
"200x200",
"180x180",
"160x160",
"150x150",
"100x100",
"80x80",
"60x60",
"50x50",
"480x*",
"480x0"
}

local processorConfig = {
	thumbnailLocation = "/thumbnail/",
	originalImagesRoot = "/www/images/public/",
	thumbnailImagesRoot = "/www/images/public/thumbnail/",
	permitedSizes = permitedSizes,
	compressFlag = true,
	sendMessageFlag = true,
	sendMessageFlag4EveryReq = true,
	serverUrl = "tcp://localhost:5555",
	widthLimit = 480,
	heightLimit = 1000
}

local processor = imageProcessor:new(processorConfig)
if processor then
	local reqPath = ngx.var.reqPath	
	print(reqPath)
	local uri = processor:resolveImageURI(reqPath)	
	
	if uri == nil then
			ngx.exit(404)
	else
			ngx.req.set_uri(uri, true)
	end
else	
	ngx.exit(404)
end
