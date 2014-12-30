-- FFI bindings to GraphicsMagick:
local ffi = require "ffi"
ffi.cdef
[[
  // free
  void free(void *);

  // Magick types:
  typedef void MagickWand;
  typedef int MagickBooleanType;
  typedef int ExceptionType;
  typedef int size_t;
  typedef int ssize_t;
  typedef int ChannelType;
  typedef void PixelWand;
  typedef void DrawingWand;

  // Pixel formats:
  typedef enum
  {
    CharPixel,
    ShortPixel,
    IntPixel,
    LongPixel,
    FloatPixel,
    DoublePixel,
  } StorageType;

  // Resizing filters:
  typedef enum
  {
    UndefinedFilter,
    PointFilter,
    BoxFilter,
    TriangleFilter,
    HermiteFilter,
    HanningFilter,
    HammingFilter,
    BlackmanFilter,
    GaussianFilter,
    QuadraticFilter,
    CubicFilter,
    CatromFilter,
    MitchellFilter,
    JincFilter,
    SincFilter,
    SincFastFilter,
    KaiserFilter,
    WelshFilter,
    ParzenFilter,
    BohmanFilter,
    BartlettFilter,
    LagrangeFilter,
    LanczosFilter,
    LanczosSharpFilter,
    Lanczos2Filter,
    Lanczos2SharpFilter,
    RobidouxFilter,
    RobidouxSharpFilter,
    CosineFilter,
    SplineFilter,
    LanczosRadiusFilter,
    SentinelFilter
  } FilterTypes;

  // Channels:
  typedef enum
  {
    UndefinedChannel,
    RedChannel,     /* RGB Red channel */
    CyanChannel,    /* CMYK Cyan channel */
    GreenChannel,   /* RGB Green channel */
    MagentaChannel, /* CMYK Magenta channel */
    BlueChannel,    /* RGB Blue channel */
    YellowChannel,  /* CMYK Yellow channel */
    OpacityChannel, /* Opacity channel */
    BlackChannel,   /* CMYK Black (K) channel */
    MatteChannel,   /* Same as Opacity channel (deprecated) */
    AllChannels,    /* Color channels */
    GrayChannel     /* Color channels represent an intensity. */
  } ChannelType;

  // Color spaces:
  typedef enum
  {
    UndefinedColorspace,
    RGBColorspace,         /* Plain old RGB colorspace */
    GRAYColorspace,        /* Plain old full-range grayscale */
    TransparentColorspace, /* RGB but preserve matte channel during quantize */
    OHTAColorspace,
    XYZColorspace,         /* CIE XYZ */
    YCCColorspace,         /* Kodak PhotoCD PhotoYCC */
    YIQColorspace,
    YPbPrColorspace,
    YUVColorspace,
    CMYKColorspace,        /* Cyan, magenta, yellow, black, alpha */
    sRGBColorspace,        /* Kodak PhotoCD sRGB */
    HSLColorspace,         /* Hue, saturation, luminosity */
    HWBColorspace,         /* Hue, whiteness, blackness */
    LABColorspace,         /* LAB colorspace not supported yet other than via lcms */
    CineonLogRGBColorspace,/* RGB data with Cineon Log scaling, 2.048 density range */
    Rec601LumaColorspace,  /* Luma (Y) according to ITU-R 601 */
    Rec601YCbCrColorspace, /* YCbCr according to ITU-R 601 */
    Rec709LumaColorspace,  /* Luma (Y) according to ITU-R 709 */
    Rec709YCbCrColorspace  /* YCbCr according to ITU-R 709 */
  } ColorspaceType;

  typedef enum
  {
	Enumeration,
	ForgetGravity,
	NorthWestGravity,
	NorthGravity,
	NorthEastGravity,
	WestGravity,
	CenterGravity,
	EastGravity,
	SouthWestGravity,
	SouthGravity,
	SouthEastGravity	
  } GravityType;
  

  // Global context:
  void MagickWandGenesis();
  void InitializeMagick();
  
  // Magick Wand:
  MagickWand* NewMagickWand();
  MagickWand* DestroyMagickWand(MagickWand*);

  //by luis
  PixelWand* NewPixelWand();
  PixelWand* DestroyPixelWand(PixelWand*);
 
  //color setting
  int PixelSetRed(PixelWand*, const double);
  int PixelSetGreen(PixelWand*, const double);
  int PixelSetBlue(PixelWand*, const double);

  DrawingWand* MagickNewDrawingWand();
  DrawingWand* MagickDestroyDrawingWand(DrawingWand*);

  void MagickDrawSetGravity( DrawingWand* drawing_wand, const GravityType gravity );


  // Read/Write:
  MagickBooleanType MagickReadImage(MagickWand*, const char*);
  MagickBooleanType MagickReadImageBlob(MagickWand*, const void*, const size_t);
  MagickBooleanType MagickWriteImage(MagickWand*, const char*);
  unsigned char *MagickWriteImageBlob( MagickWand *wand, size_t *length );

  // Quality:
  unsigned int MagickSetCompressionQuality( MagickWand *wand, const unsigned long quality );
 
  //Exception handling:
  const char* MagickGetException(const MagickWand*, ExceptionType*);

  // Dimensions:
  int MagickGetImageWidth(MagickWand*);
  int MagickGetImageHeight(MagickWand*);

  //add by luis
  unsigned int MagickGetImageBackgroundColor( MagickWand* wand, PixelWand* background_color );
  unsigned int MagickSetImageBackgroundColor( MagickWand* wand, const PixelWand* background );

  unsigned int MagickRemoveImageProfile( MagickWand* wand, const unsigned char* name, const unsigned long* length);


  // Depth
  int MagickGetImageDepth(MagickWand*);
  unsigned int MagickSetImageDepth( MagickWand *wand, const unsigned long depth );

  // Resize:
  MagickBooleanType MagickResizeImage(MagickWand*, const size_t, const size_t, const FilterTypes, const double);

  //by luis lau 2013-04-25
  // Resize:
  MagickBooleanType MagickExtentImage(MagickWand*, const size_t, const size_t, const ssize_t, const ssize_t);

  // Set size:
  unsigned int MagickSetSize( MagickWand *wand, const unsigned long columns, const unsigned long rows );

  // Image format (JPEG, PNG, ...)
  const char* MagickGetImageFormat(MagickWand* wand);
  MagickBooleanType MagickSetImageFormat(MagickWand* wand, const char* format);

  // Raw data:
  unsigned int MagickGetImagePixels( MagickWand *wand, const long x_offset, const long y_offset,
                                     const unsigned long columns, const unsigned long rows,
                                     const char *map, const StorageType storage,
                                     unsigned char *pixels );
  unsigned int MagickSetImagePixels( MagickWand *wand, const long x_offset, const long y_offset,
                                     const unsigned long columns, const unsigned long rows,
                                     const char *map, const StorageType storage,
                                     unsigned char *pixels );

   // Flip/Flop
   unsigned int MagickFlipImage( MagickWand *wand );
   unsigned int MagickFlopImage( MagickWand *wand );

   // Colorspace:
   ColorspaceType MagickGetImageColorspace( MagickWand *wand );
   unsigned int MagickSetImageColorspace( MagickWand *wand, const ColorspaceType colorspace );

   // Description
   const char *MagickDescribeImage( MagickWand *wand );
]]
-- Load lib:
local clib = ffi.load('GraphicsMagickWand')

-- Initialize lib:
clib.InitializeMagick();

-- Image object:
local Image = {
   name = 'magick.Image',
   path = '<>',
   buffers = {
      HWD = {},
      DHW = {},
   }
}

-- Metatable:
setmetatable(Image, {
   __call = function(self,...)
      return self.new(...)
   end
})

-- Constructor:
function Image.new(pathOrTensor, ...)
   -- Create new instance:
   local image = {}
   for k,v in pairs(Image) do
      image[k] = v
   end

   -- Create Wand:
   image.wand = ffi.gc(clib.NewMagickWand(), function(wand)
      -- Collect:
      clib.DestroyMagickWand(wand)
   end)
  
   -- Arg?
   if type(pathOrTensor) == 'string' then
      -- Is a path:
      image:load(pathOrTensor, ...)
   
   elseif type(pathOrTensor) == 'userdata' then
      -- Is a tensor:
      image:fromTensor(pathOrTensor, ...)

   end
   
   -- 
   return image
end

-- Load image:
function Image:load(path, width, height)
   -- Set canvas size:
   if width then
      -- This gives a cue to the wand that we don't need
      -- a large image than this. This is super cool, because
      -- it speeds up the loading of large images by a lot.
      clib.MagickSetSize(self.wand, width, height or width)
   end

   -- Load image:
   local status = clib.MagickReadImage(self.wand, path)
   
   -- Error?
   if status == 0 then
      clib.DestroyMagickWand(self.wand)
      error(self.name .. ': error loading image at path "' .. path .. '"')
   end

   -- Save path:
   self.path = path

   -- return self
   return self
end

-- Save image:
function Image:save(path, quality)
   -- Format?
   -- local format = (path:gfind('%.(...)$')() or path:gfind('%.(....)$')()):upper()
   -- if format == 'JPG' then format = 'JPEG' end
   -- self:format(format)

   -- Set quality:
   quality = quality or 85
   clib.MagickSetCompressionQuality(self.wand, quality) 

   -- Save:
   local status = clib.MagickWriteImage(self.wand, path)
   
   -- Error?
   if status == 0 then
      error(self.name .. ': error saving image to path "' .. path .. '"')
   end

   -- return self
   return self
end

-- Size:
function Image:size(width,height,filter)
   -- Set or get:
   if width or height then
      -- Get filter:
      local filter = clib[(filter or 'Cubic') .. 'Filter']

      -- Bounding box?
      if not height then
         -- in this case, the image must fit in a widthxwidth box:
         local box = width
         local cwidth,cheight = self:size()
         if cwidth > cheight then
            width = box
            height = box * cheight/cwidth
         else
            height = box
            width = box * cwidth/cheight
         end
      end
      
      -- Min box?
      if not width then
         -- in this case, the image must cover a heightxheight box:
         local box = height
         local cwidth,cheight = self:size()
         if cwidth < cheight then
            width = box
            height = box * cheight/cwidth
         else
            height = box
            width = box * cwidth/cheight
         end
      end

      -- Set dimensions:
      local status = clib.MagickResizeImage(self.wand, width, height, filter, 0.5)

      -- Error?
      if status == 0 then
         error(self.name .. ': error resizing image')
      end

      -- return self
      return self
   else
      -- Get dimensions:
      width,height = clib.MagickGetImageWidth(self.wand), clib.MagickGetImageHeight(self.wand)
   end
   --
   return width,height
end

--added by luis
function Image:thumbnail(width, height)	
	local mwidth = width
	local mheight = height	

	if mwidth and mheight then
		print("with width and height")
		local cwidth,cheight = self:size()
		if (mwidth / cwidth) > (mheight / cheight)  then
			mwidth = cwidth * (mheight / cheight)
		else
			mheight = cheight * (mwidth / cwidth)				
		end
		self:size(mwidth, mheight)
	
		local cwidth, cheight = self:size()
		
		self:extent(width, height, (width - cwidth) / 2, (height - cheight) / 2);
	elseif mwidth then		
		--only with the width
		local cwidth,cheight = self:size()				
		self:size(mwidth, cheight * mwidth / cwidth)		
	else
		--only deliver the height
		local cwidth,cheight = self:size()		
		self:size(cwidth *  mheight / cheight, mheight)
	end
	
end
	

--added by luis
function Image:thumbnail4LargeImgs(width, height, widthLimit, heightLimit)	
	local mwidth = width
	local mheight = height	

	if mwidth and mheight then
		print("with width and height")
		local cwidth,cheight = self:size()
		
		--only if the width or the height is bigger then the width limitation or height limitation then needs to generate thumbnail		
		if cwidth < widthLimit and cheight < heightLimit then			
			return false
		end
		
		if (mwidth / cwidth) > (mheight / cheight)  then
			mwidth = cwidth * (mheight / cheight)
		else
			mheight = cheight * (mwidth / cwidth)				
		end
		self:size(mwidth, mheight)
	
		local cwidth, cheight = self:size()
		
		if cwidth ~= width or cheight ~= height then			
			self:extent(width, height, (width - cwidth) / 2, (height - cheight) / 2);		
		end
		
	elseif mwidth then		
		--only with the width
		local cwidth,cheight = self:size()				
		--only when the width is bigger then the width limitation then needs to generate thumbnail		
		if cwidth < widthLimit then
			return false
		end
		
		self:size(mwidth, cheight * mwidth / cwidth)		
	else
		--only deliver the height
		local cwidth,cheight = self:size()		
		--only when the height is bigger then the height limitation then needs to generate thumbnail		
		if cheight < heightLimit then
			return false
		end
				
		self:size(cwidth *  mheight / cheight, mheight)
	end
	
end

function Image:removeProfile()	
	local lengthPtr = ffi.new('unsigned long[1]')
	local profile = ""
	clib.MagickRemoveImageProfile(self.wand, profile, lengthPtr)	
end

--by luis 2013-04-25
function Image:extent(width,height,leftPos, topPos)
	clib.MagickExtentImage(self.wand, width, height, leftPos , topPos);
end

function Image:setBackgroundColor(color)
	clib.MagickSetImageBackgroundColor(self.wand, color);
end

-- Depth:
function Image:depth(depth)
   -- Set or get:
   if depth then
      -- Set depth:
      clib.MagickSetImageDepth(self.wand, depth)

      -- return self
      return self
   else
      -- Get depth:
      local depth = clib.MagickGetImageDepth(self.wand)
   end
   --
   return depth 
end

-- Format:
function Image:format(format)
   -- Set or get:
   if format then
      -- Set format:
      clib.MagickSetImageFormat(self.wand, format)

      -- return self
      return self
   else
      -- Get format:
      format = ffi.string(clib.MagickGetImageFormat(self.wand))
   end
   return format
end

-- Colorspaces available:
local colorspaces = {
   [0] = 'Undefined',
   'RGB',
   'GRAY',
   'Transparent',
   'OHTA',
   'XYZ',
   'YCC',
   'YIQ',
   'YPbPr',
   'YUV',
   'CMYK',
   'sRGB',
   'HSL',
   'HWB',
   'LAB',
   'CineonLogRGB',
   'Rec601Luma',
   'Rec601YCbCr',
   'Rec709Luma',
   'Rec709YCbCr'
}
-- Coloispaces:
function Image:colorspaces()
   return colorspaces
end

-- Colorspace:
function Image:colorspace(colorspace)
   -- Set or get:
   if colorspace then
      -- Set format:
      clib.MagickSetImageColorspace(self.wand, clib[colorspace .. 'Colorspace'])

      -- return self
      return self
   else
      -- Get format:
      colorspace = tonumber(ffi.cast('double', clib.MagickGetImageColorspace(self.wand)))

      colorspace = colorspaces[colorspace]
   end
   return colorspace 
end

--luis added
function Image:newPixWand(redValue, greedValue, blueValue) 	

	local pixwand = ffi.gc(clib.NewPixelWand(), function(wand)
      -- Collect:
      clib.DestroyPixelWand(wand)
    end)

    --white barckground
    clib.PixelSetRed(pixwand, redValue);
	clib.PixelSetGreen(pixwand, greedValue);
	clib.PixelSetBlue(pixwand, blueValue);
	
	return pixwand
end	

--luis added
function Image:newDrawingWand() 	

	local drawingwand = ffi.gc(clib.MagickNewDrawingWand(), function(wand)
      -- Collect:
      clib.MagickDestroyDrawingWand(wand)
    end)
	
	return drawingwand
end	

function Image:drawSetGravity( drawing_wand, gravity )
	clib.MagickDrawSetGravity(drawing_wand, gravity)
end
-- Flip:
function Image:flip()
   -- Flip image:
   clib.MagickFlipImage(self.wand)

   -- return self
   return self
end

-- Flop:
function Image:flop()
   -- Flop image:
   clib.MagickFlopImage(self.wand)

   -- return self
   return self
end

-- Export to Blob:
function Image:toBlob()
   -- Size pointer:
   local sizep = ffi.new('size_t[1]')

   -- To Blob:
   local blob = ffi.gc(clib.MagickWriteImageBlob(self.wand, sizep), ffi.C.free)
   
   -- Return blob and size:
   return blob, tonumber(sizep[0])
end

-- Export to string:
function Image:toString()
   -- To blob:
   local blob, size = self:toBlob()

   -- Lua string:
   local str = ffi.string(blob,size)

   -- Return string:
   return str
end

-- To Tensor:
function Image:toTensor(dataType, colorspace, dims, nocopy)
   -- Torch+FII required:
   local ok = pcall(require, 'torchffi')
   if not ok then 
      error(Image.name .. '.toTensor: requires TorchFFI. Install it like this: luarocks install torchffi')
   end

   -- Dims:
   local width,height = self:size()

   -- Color space:
   colorspace = colorspace or 'RGB'  -- any combination of R, G, B, A, C, Y, M, K, and I
   -- common colorspaces are: RGB, RGBA, CYMK, and I

   -- Other colorspaces?
   if colorspace == 'HSL' or colorspace == 'HWB' or colorspace == 'LAB' or colorspace == 'YUV' then
      -- Switch to colorspace:
      self:colorspace(colorspace)
      colorspace = 'RGB'
   end

   -- Type:
   dataType = dataType or 'byte'
   local tensorType, pixelType
   if dataType == 'byte' then
      tensorType = 'ByteTensor'
      pixelType = 'CharPixel'
   elseif dataType == 'float' then
      tensorType = 'FloatTensor'
      pixelType = 'FloatPixel'
   elseif dataType == 'double' then
      tensorType = 'DoubleTensor'
      pixelType = 'DoublePixel'
   else
      error(Image.name .. ': unknown data type ' .. dataType)
   end

   -- Dest:
   local tensor = Image.buffers['HWD'][tensorType] or torch[tensorType]()
   tensor:resize(height,width,#colorspace)

   -- Cache tensor:
   Image.buffers['HWD'][tensorType] = tensor

   -- Raw pointer:
   local ptx = torch.data(tensor)

   -- Export:
   clib.MagickGetImagePixels(self.wand, 
                             0, 0, width, height,
                             colorspace, clib[pixelType],
                             ffi.cast('unsigned char *',ptx))

   -- Dims:
   if dims == 'DHW' then
      -- Transposed Tensor:
      local tensorDHW = Image.buffers['DHW'][tensorType] or tensor.new()
      tensorDHW:resize(#colorspace,height,width)

      -- Copy:
      tensorDHW:copy(tensor:transpose(1,3):transpose(2,3))

      -- Cache:
      Image.buffers['DHW'][tensorType] = tensorDHW

      -- Return:
      tensor = tensorDHW
   end

   -- Return tensor
   if nocopy then
      return tensor
   else
      return tensor:clone()
   end
end

-- Import from blob:
function Image:fromBlob(blob,size)
   -- Read from blob:
   clib.MagickReadImageBlob(self.wand, ffi.cast('const void *', blob), size)
   
   -- Save path:
   self.path = '<blob>'

   -- return self
   return self
end

-- Import from blob:
function Image:fromString(string)
   -- Convert blob (lua string) to C string
   local size = #string
   blob = ffi.new('char['..size..']', string)

   -- Load blob:
   return self:fromBlob(blob, size)
end

-- From Tensor:
function Image:fromTensor(tensor, colorspace, dims)
   -- Torch+FII required:
   local ok = pcall(require, 'torchffi')
   if not ok then 
      error(Image.name .. '.toTensor: requires TorchFFI. Install it like this: luarocks install torchffi')
   end

   -- Dims:
   local height,width,depth
   if dims == 'DHW' then
      depth,height,width= tensor:size(1),tensor:size(2),tensor:size(3)
      tensor = tensor:transpose(1,3):transpose(1,2)
   else -- dims == 'HWD'
      height,width,depth = tensor:size(1),tensor:size(2),tensor:size(3)
   end
   
   -- Force contiguous:
   tensor = tensor:contiguous()
   
   -- Color space:
   if not colorspace then
      if depth == 1 then
         colorspace = 'I'
      elseif depth == 3 then
         colorspace = 'RGB'
      elseif depth == 4 then
         colorspace = 'RGBA'
      else
      end
   end
   -- any combination of R, G, B, A, C, Y, M, K, and I
   -- common colorspaces are: RGB, RGBA, CYMK, and I

   -- Compat:
   assert(#colorspace == depth, Image.name .. '.fromTensor: Tensor depth must match color space')

   -- Type:
   local ttype = torch.typename(tensor)
   local pixelType
   if ttype == 'torch.FloatTensor' then
      pixelType = 'FloatPixel'
   elseif ttype == 'torch.DoubleTensor' then
      pixelType = 'DoublePixel'
   elseif ttype == 'torch.ByteTensor' then
      pixelType = 'CharPixel'
   else
      error(Image.name .. ': only dealing with float, double and byte')
   end
   
   -- Raw pointer:
   local ptx = torch.data(tensor)

   -- Resize image:
   self:load('xc:black')
   self:size(width,height)

   -- Export:
   clib.MagickSetImagePixels(self.wand, 
                             0, 0, width, height,
                             colorspace, clib[pixelType],
                             ffi.cast("unsigned char *", ptx))

   -- Save path:
   self.path = '<tensor>'

   -- return self
   return self
end

-- Show:
function Image:show(zoom)
   -- Get Tensor from image:
   local tensor = self:toTensor('float', nil,'DHW')
   
   -- Display this tensor:
   require 'image'
   image.display({
      image = tensor,
      zoom = zoom
   })

   -- return self
   return self
end

-- Description:
function Image:info()
   -- Get information
   local str = ffi.gc(clib.MagickDescribeImage(self.wand), ffi.C.free)
   return ffi.string(str)
end

-- Exports:
return Image

