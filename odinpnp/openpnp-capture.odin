/*

    OpenPnp-Capture: a video capture subsystem.

    Copyright (c) 2017 Jason von Nieda, Niels Moseley.

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
*/


/*!
*  @file
*  @brief C API for OpenPnP Capture Library
*/
package openpnp

when ODIN_OS == .Windows {
	#panic("WINDOWS SUPPORT IS WIP, TODO FINISH THIS MAXIM")
}
when ODIN_OS == .Linux {
	foreign import lib "libopenpnp-capture.so"
}


CapContext  :: rawptr ///< an opaque pointer to the internal Context*
CapStream   :: i32    ///< a stream identifier (normally >=0, <0 for error)
CapResult   :: u32    ///< result defined by CAPRESULT_xxx
CapDeviceID :: u32    ///< unique device ID
CapFormatID :: u32    ///< format identifier 0 .. numFormats

// supported properties:
CAPPROPID_EXPOSURE      :: 1
CAPPROPID_FOCUS         :: 2
CAPPROPID_ZOOM          :: 3
CAPPROPID_WHITEBALANCE  :: 4
CAPPROPID_GAIN          :: 5
CAPPROPID_BRIGHTNESS    :: 6
CAPPROPID_CONTRAST      :: 7
CAPPROPID_SATURATION    :: 8
CAPPROPID_GAMMA         :: 9
CAPPROPID_HUE           :: 10
CAPPROPID_SHARPNESS     :: 11
CAPPROPID_BACKLIGHTCOMP :: 12
CAPPROPID_POWERLINEFREQ :: 13
CAPPROPID_LAST          :: 14

CapPropertyID :: u32 ///< property ID (exposure, zoom, focus etc.)

CapFormatInfo :: struct {
	width:  u32, ///< width in pixels
	height: u32, ///< height in pixels
	fourcc: u32, ///< fourcc code (platform dependent)
	fps:    u32, ///< frames per second
	bpp:    u32, ///< bits per pixel
}

CAPRESULT_OK                   :: 0
CAPRESULT_ERR                  :: 1
CAPRESULT_DEVICENOTFOUND       :: 2
CAPRESULT_FORMATNOTSUPPORTED   :: 3
CAPRESULT_PROPERTYNOTSUPPORTED :: 4

@(default_calling_convention="c")
foreign lib {
	/** Initialize the capture library
	@return The context ID.
	*/
	Cap_createContext :: proc() -> CapContext ---

	/** Un-initialize the capture library context
	@param ctx The ID of the context to destroy.
	@return The context ID.
	*/
	Cap_releaseContext :: proc(ctx: CapContext) -> CapResult ---

	/** Get the number of capture devices on the system.
	note: this can change dynamically due to the
	pluggin and unplugging of USB devices.
	@param ctx The ID of the context.
	@return The number of capture devices found.
	*/
	Cap_getDeviceCount :: proc(ctx: CapContext) -> u32 ---

	/** Get the name of a capture device.
	This name is meant to be displayed in GUI applications,
	i.e. its human readable.
	
	if a device with the given index does not exist,
	NULL is returned.
	@param ctx The ID of the context.
	@param index The device index of the capture device.
	@return a pointer to an UTF-8 string containting the name of the capture device.
	*/
	Cap_getDeviceName :: proc(ctx: CapContext, index: CapDeviceID) -> cstring ---

	/** Get the unique name of a capture device.
	The string contains a unique concatenation
	of the device name and other parameters.
	These parameters are platform dependent.
	
	Note: when a USB camera does not expose a serial number,
	platforms might have trouble uniquely identifying
	a camera. In such cases, the USB port location can
	be used to add a unique feature to the string.
	This, however, has the down side that the ID of
	the camera changes when the USB port location
	changes. Unfortunately, there isn't much to
	do about this.
	
	if a device with the given index does not exist,
	NULL is returned.
	@param ctx The ID of the context.
	@param index The device index of the capture device.
	@return a pointer to an UTF-8 string containting the unique ID of the capture device.
	*/
	Cap_getDeviceUniqueID :: proc(ctx: CapContext, index: CapDeviceID) -> cstring ---

	/** Returns the number of formats supported by a certain device.
	returns -1 if device does not exist.
	
	@param ctx The ID of the context.
	@param index The device index of the capture device.
	@return The number of formats supported or -1 if the device does not exist.
	*/
	Cap_getNumFormats :: proc(ctx: CapContext, index: CapDeviceID) -> i32 ---

	/** Get the format information from a device.
	@param ctx The ID of the context.
	@param index The device index of the capture device.
	@param id The index/ID of the frame buffer format (0 .. number returned by Cap_getNumFormats() minus 1 ).
	@param info pointer to a CapFormatInfo structure to be filled with data.
	@return The CapResult.
	*/
	Cap_getFormatInfo :: proc(ctx: CapContext, index: CapDeviceID, id: CapFormatID, info: ^CapFormatInfo) -> CapResult ---

	/** Open a capture stream to a device with specific format requirements
	
	Although the (internal) frame buffer format is set via the fourCC ID,
	the frames returned by Cap_captureFrame are always 24-bit RGB.
	
	@param ctx The ID of the context.
	@param index The device index of the capture device.
	@param formatID The index/ID of the frame buffer format (0 .. number returned by Cap_getNumFormats() minus 1 ).
	@return The stream ID or -1 if the device does not exist or the stream format ID is incorrect.
	*/
	Cap_openStream :: proc(ctx: CapContext, index: CapDeviceID, formatID: CapFormatID) -> CapStream ---

	/** Close a capture stream
	@param ctx The ID of the context.
	@param stream The stream ID.
	@return CapResult
	*/
	Cap_closeStream :: proc(ctx: CapContext, stream: CapStream) -> CapResult ---

	/** Check if a stream is open, i.e. is capturing data.
	@param ctx The ID of the context.
	@param stream The stream ID.
	@return 1 if the stream is open and capturing, else 0.
	*/
	Cap_isOpenStream :: proc(ctx: CapContext, stream: CapStream) -> u32 ---

	/** this function copies the most recent RGB frame data
	to the given buffer.
	*/
	Cap_captureFrame :: proc(ctx: CapContext, stream: CapStream, RGBbufferPtr: rawptr, RGBbufferBytes: u32) -> CapResult ---

	/** returns 1 if a new frame has been captured, 0 otherwise */
	Cap_hasNewFrame :: proc(ctx: CapContext, stream: CapStream) -> u32 ---

	/** returns the number of frames captured during the lifetime of the stream.
	For debugging purposes */
	Cap_getStreamFrameCount :: proc(ctx: CapContext, stream: CapStream) -> u32 ---

	/** get the min/max limits and default value of a camera/stream property (e.g. zoom, exposure etc)
	
	returns: CAPRESULT_OK if all is well.
	CAPRESULT_PROPERTYNOTSUPPORTED if property not available.
	CAPRESULT_ERR if context, stream are invalid.
	*/
	Cap_getPropertyLimits :: proc(ctx: CapContext, stream: CapStream, propID: CapPropertyID, min: ^i32, max: ^i32, dValue: ^i32) -> CapResult ---

	/** set the value of a camera/stream property (e.g. zoom, exposure etc)
	
	returns: CAPRESULT_OK if all is well.
	CAPRESULT_PROPERTYNOTSUPPORTED if property not available.
	CAPRESULT_ERR if context, stream are invalid.
	*/
	Cap_setProperty :: proc(ctx: CapContext, stream: CapStream, propID: CapPropertyID, value: i32) -> CapResult ---

	/** set the automatic flag of a camera/stream property (e.g. zoom, focus etc)
	
	returns: CAPRESULT_OK if all is well.
	CAPRESULT_PROPERTYNOTSUPPORTED if property not available.
	CAPRESULT_ERR if context, stream are invalid.
	*/
	Cap_setAutoProperty :: proc(ctx: CapContext, stream: CapStream, propID: CapPropertyID, bOnOff: u32) -> CapResult ---

	/** get the value of a camera/stream property (e.g. zoom, exposure etc)
	
	returns: CAPRESULT_OK if all is well.
	CAPRESULT_PROPERTYNOTSUPPORTED if property not available.
	CAPRESULT_ERR if context, stream are invalid or outValue == NULL.
	*/
	Cap_getProperty :: proc(ctx: CapContext, stream: CapStream, propID: CapPropertyID, outValue: ^i32) -> CapResult ---

	/** get the automatic flag of a camera/stream property (e.g. zoom, focus etc)
	
	returns: CAPRESULT_OK if all is well.
	CAPRESULT_PROPERTYNOTSUPPORTED if property not available.
	CAPRESULT_ERR if context, stream are invalid.
	*/
	Cap_getAutoProperty :: proc(ctx: CapContext, stream: CapStream, propID: CapPropertyID, outValue: ^u32) -> CapResult ---

	/**
	Set the logging level.
	
	LOG LEVEL ID  | LEVEL
	------------- | -------------
	LOG_EMERG     | 0
	LOG_ALERT     | 1
	LOG_CRIT      | 2
	LOG_ERR       | 3
	LOG_WARNING   | 4
	LOG_NOTICE    | 5
	LOG_INFO      | 6
	LOG_DEBUG     | 7
	LOG_VERBOSE   | 8
	
	*/
	Cap_setLogLevel :: proc(level: u32) ---
}

CapCustomLogFunc :: proc "c" (level: u32, _string: cstring)

@(default_calling_convention="c")
foreign lib {
	/** install a custom callback for a logging function.
	
	the callback function must have the following
	structure:
	
	void func(uint32_t level, const char *string);
	*/
	Cap_installCustomLogFunction :: proc(logFunc: CapCustomLogFunc) ---

	/** Return the version of the library as a string.
	In addition to a version number, this should
	contain information on the platform,
	e.g. Win32/Win64/Linux32/Linux64/OSX etc,
	wether or not it is a release or debug
	build and the build date.
	
	When building the library, please set the
	following defines in the build environment:
	
	__LIBVER__
	__PLATFORM__
	__BUILDTYPE__
	
	*/
	Cap_getLibraryVersion :: proc() -> cstring ---
}

