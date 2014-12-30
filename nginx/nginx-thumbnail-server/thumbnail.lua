local imageProcessor = require "ImageProcessor"
local permitedSizes = {
"800x600",
"600x600",
"400x400",
"236x80",
"220x220",
"200x200",
"180x180",
"160x160",
"160x80",
"150x150",
"142x69",
"100x100",
"80x80",
"60x60",
"50x50",
"480x*",
"480x0",
"320x0",
"320x*",
"600x0",
"600x*",
"100x50",
"100x60",
"200x80",
"400x160",
"195x80",
"98x58",
"300x100",
"1000x200",
"1000x*",
"1000x800",
"210x140",
"160x106",
"600x400",
"150x100",
"250x100",
"120x120"
}

local waterMarkImagesKeys = {
{folder="supplier-1", waterMarkType = 6},
{folder="supplier-2", waterMarkType = 6},
{folder="supplier-3", waterMarkType = 6},
{folder="supplier-4", waterMarkType = 6},
{folder="supplier-6", waterMarkType = 6},
{folder="supplier-7", waterMarkType = 6},
{folder="supplier-8", waterMarkType = 6},
{folder="supplier-9", waterMarkType = 6},
{folder="supplier-12", waterMarkType = 6},
{folder="supplier-13", waterMarkType = 6}
};

local processorConfig = {
        thumbnailLocation = "/thumbnail/",
        originalImagesRoot = "/www/target/images/public",
        thumbnailImagesRoot = "/www/target/images/thumbnail/",
        permitedSizes = permitedSizes,
        compressFlag = true,
        sendMessageFlag = false,
        sendMessageFlag4EveryReq = false,
        serverUrl = "tcp://localhost:5559",
	logoPath = "/www/target/logos/center.png",
	waterMarkImagesKeys = waterMarkImagesKeys
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
