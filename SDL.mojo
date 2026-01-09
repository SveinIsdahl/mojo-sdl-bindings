from sys import ffi, info
from sys.ffi import dlopen, dlsym, RTLD, OwnedDLHandle


#    SDL_PIXELFORMAT_RGBA8888 =
#      SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_RGBA,
#                             SDL_PACKEDLAYOUT_8888, 32, 4),

comptime SDL_PIXELTYPE_PACKED32 = 6
comptime SDL_PACKEDORDER_RGBA = 4
comptime SDL_PACKEDLAYOUT_8888 = 6


fn SDL_DEFINE_PIXELFORMAT(type: Int, order: Int, layout: Int, bits: Int, bytes: Int) -> Int:
    return ((1 << 28) | ((type) << 24) | ((order) << 20) | ((layout) << 16) | ((bits) << 8) | ((bytes) << 0))

comptime SDL_PIXELFORMAT_RGBA8888 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32,
                                                        SDL_PACKEDORDER_RGBA,
                                                        SDL_PACKEDLAYOUT_8888,
                                                        32,
                                                        4)

comptime SDL_TEXTUREACCESS_TARGET = 2




@register_passable('trivial')
struct SDL_Window:
    pass

@register_passable('trivial')
struct SDL_Rect:
    var x: Int32
    var y: Int32
    var w: Int32
    var h: Int32

@register_passable('trivial')
struct SDL_PixelFormat:
    pass

@register_passable('trivial')
struct SDL_Renderer:
    pass

@register_passable('trivial')
struct SDL_Texture:
    pass

@register_passable('trivial')
struct SDL_Surface:
    var flags: UInt32
    var format: UnsafePointer[SDL_PixelFormat, MutOrigin.external]
    var w: Int32
    var h: Int32
    var pitch: Int32
    var pixels: UnsafePointer[UInt32, MutOrigin.external]
    var userdata: UnsafePointer[Int8, MutOrigin.external]
    var locked: Int32
    var list_blitmap: UnsafePointer[Int8, MutOrigin.external]
    var clip_rect: SDL_Rect
    var map: UnsafePointer[Int8, ImmutOrigin.external]
    var refcount: Int32



comptime SDL_QUIT = 0x100

comptime SDL_KEYDOWN = 0x300
comptime SDL_KEYUP   = 0x301

comptime SDL_MOUSEMOTION     = 0x400
comptime SDL_MOUSEBUTTONDOWN = 0x401
comptime SDL_MOUSEBUTTONUP   = 0x402
comptime SDL_MOUSEWHEEL      = 0x403

@register_passable('trivial')
struct Keysym:
    var scancode: Int32
    var keycode: Int32
    var mod: UInt16
    var unused: UInt32
    fn __init__ (out self, scancode: Int32,
                     keycode: Int32,
                     mod: UInt16,
                     unused: UInt32):
        self.scancode = 0
        self.keycode = 0
        self.mod = 0
        self.unused = 0

@register_passable('trivial')
struct MouseMotionEvent:
    var type: UInt32
    var timestamp: UInt32
    var windowID: UInt32
    var which: UInt32
    var state: UInt32
    var x: Int32
    var y: Int32
    var xrel: Int32
    var yrel: Int32

@register_passable('trivial')
struct MouseButtonEvent:
    var type: UInt32
    var timestamp: UInt32
    var windowID: UInt32
    var which: UInt32
    var button: UInt8
    var state: UInt8
    var clicks: UInt8
    var padding1: UInt8
    var x: Int32
    var y: Int32

@register_passable('trivial')
struct MouseWheelEvent:
    var type: UInt32
    var timestamp: UInt32
    var windowID: UInt32
    var which: UInt32
    var x: Int32
    var y: Int32
    var direction: UInt32
    var preciseX: Float32
    var preciseY: Float32
    var mouseX: Int32
    var mouseY: Int32

@register_passable('trivial')
struct Event:
    var type: Int32
    var _padding: SIMD[DType.uint8, 16]
    var _padding2: Int64
    var _padding3: Int64
    def __init__(out self):
        self.type = 0
        self._padding = 0
        self._padding2 = 0
        self._padding3 = 0

    def as_keyboard(self) -> Keyevent:
        return UnsafePointer(to=self).bitcast[Keyevent]()[0]

    def as_mousemotion(self) -> MouseMotionEvent:
        return UnsafePointer(to=self).bitcast[MouseMotionEvent]()[0]

    def as_mousebutton(self) -> MouseButtonEvent:
        return UnsafePointer(to=self).bitcast[MouseButtonEvent]()[0]

    def as_mousewheel(self) -> MouseWheelEvent:
        return UnsafePointer(to=self).bitcast[MouseWheelEvent]()[0]


@register_passable('trivial')
struct Keyevent:
    var type: UInt32
    var timestamp: UInt32
    var windowID: UInt32
    var state: UInt8
    var repeat: UInt8
    var padding2: UInt8
    var padding3: UInt8
    var keysym: Keysym
    
    def __init__(out self):
        #self.value = 0
        self.type = 0
        self.timestamp = 0
        self.windowID = 0
        self.state = 0
        self.repeat = 0
        self.padding2 = 0
        self.padding3 = 0
        self.keysym = Keysym(0,0,0,0)


# SDL.h
comptime c_SDL_Init = fn(w: Int32) -> Int32
comptime c_SDL_Quit = fn() -> None

# SDL_video.h
comptime c_SDL_CreateWindow = fn(UnsafePointer[Byte, origin=ImmutAnyOrigin], Int32, Int32, Int32, Int32, Int32) -> UnsafePointer[SDL_Window, origin=MutOrigin.external] 
comptime c_SDL_DestroyWindow = fn(UnsafePointer[SDL_Window, origin=MutOrigin.external]) -> None 
comptime c_SDL_UpdateWindowSurface = fn(s: UnsafePointer[Int8]) -> Int32
comptime c_SDL_GetWindowSurface = fn(s: UnsafePointer[Int8]) -> UnsafePointer[SDL_Surface, origin=MutOrigin.external]

# SDL_pixels.h
comptime c_SDL_MapRGB = fn(Int32, Int32, Int32, Int32) -> UInt32

# SDL_timer.h
comptime c_SDL_Delay = fn(Int32) -> UInt32

# SDL_event.h
comptime c_SDL_PollEvent = fn(UnsafePointer[Event, origin=MutOrigin.external]) -> Int32

# SDL_render.h
comptime c_SDL_CreateRenderer = fn(UnsafePointer[SDL_Window, origin=MutOrigin.external], Int32, UInt32) -> UnsafePointer[SDL_Renderer, origin=MutOrigin.external]
comptime c_SDL_CreateWindowAndRenderer = fn(Int32, Int32, UInt32, UnsafePointer[UnsafePointer[Int8, origin=MutOrigin.external]], UnsafePointer[UnsafePointer[SDL_Renderer, origin=MutOrigin.external]]) -> Int32
comptime c_SDL_RenderDrawPoint = fn(UnsafePointer[SDL_Renderer, origin=MutOrigin.external], Int32, Int32) -> Int32
comptime c_SDL_RenderDrawRect = fn(r: UnsafePointer[SDL_Renderer, origin=MutOrigin.external], rect: UnsafePointer[SDL_Rect]) -> Int32
comptime c_SDL_RenderDrawLine = fn(UnsafePointer[SDL_Renderer, origin=MutOrigin.external], Int32, Int32, Int32, Int32) -> Int32
comptime c_SDL_RenderPresent = fn(s: UnsafePointer[SDL_Renderer, origin=MutOrigin.external]) -> Int32
comptime c_SDL_RenderClear = fn(s: UnsafePointer[SDL_Renderer, origin=MutOrigin.external]) -> Int32
comptime c_SDL_SetRenderDrawColor = fn(UnsafePointer[SDL_Renderer, origin=MutOrigin.external], UInt8, UInt8, UInt8, UInt8) -> Int32
comptime SDL_BlendMode = Int
comptime c_SDL_SetRenderDrawBlendMode = fn(UnsafePointer[SDL_Renderer, origin=MutOrigin.external], SDL_BlendMode) -> Int32
comptime c_SDL_SetRenderTarget = fn(r: UnsafePointer[SDL_Renderer, origin=MutOrigin.external], t: Int64) -> Int32

comptime c_SDL_RenderCopy = fn(r: UnsafePointer[SDL_Renderer, origin=MutOrigin.external],
                            t: Int64,  #t: UnsafePointer[SDL_Texture],
                            s: Int64, d: Int64) -> Int32
                            #s: UnsafePointer[SDL_Rect], d: UnsafePointer[SDL_Rect]) -> Int32

# SDL_surface.h
comptime c_SDL_FillRect = fn(UnsafePointer[SDL_Surface, origin=MutOrigin.external], Int64, UInt32) -> Int32


# texture
comptime c_SDL_CreateTexture = fn(UnsafePointer[SDL_Renderer, origin=MutOrigin.external],
                               UInt32, Int32,
                               Int32, Int32) -> Int64 #UnsafePointer[SDL_Texture]



comptime SDL_WINDOWPOS_UNDEFINED = 0x1FFF0000

comptime SDL_WINDOW_SHOWN = 0x00000004


struct SDL:
    var Init: c_SDL_Init
    var Quit: c_SDL_Quit

    var CreateWindow: c_SDL_CreateWindow
    var DestroyWindow: c_SDL_DestroyWindow

    var GetWindowSurface: c_SDL_GetWindowSurface
    var UpdateWindowSurface: c_SDL_UpdateWindowSurface
    var CreateRenderer: c_SDL_CreateRenderer
    var CreateWindowAndRenderer: c_SDL_CreateWindowAndRenderer
    var RenderDrawPoint: c_SDL_RenderDrawPoint
    var RenderDrawRect: c_SDL_RenderDrawRect
    var RenderDrawLine: c_SDL_RenderDrawLine
    var SetRenderDrawColor: c_SDL_SetRenderDrawColor
    var RenderPresent: c_SDL_RenderPresent
    var RenderClear: c_SDL_RenderClear
    var CreateTexture: c_SDL_CreateTexture
    var SetRenderDrawBlendMode: c_SDL_SetRenderDrawBlendMode
    var SetRenderTarget: c_SDL_SetRenderTarget
    var RenderCopy: c_SDL_RenderCopy

    var MapRGB: c_SDL_MapRGB
    var FillRect: c_SDL_FillRect
    var Delay: c_SDL_Delay
    var PollEvent: c_SDL_PollEvent
    var SDL: OwnedDLHandle

    fn __init__(out self) raises:
        print("Binding SDL")
        self.SDL = OwnedDLHandle("libSDL2.so")
        self.Init = self.SDL.get_function[c_SDL_Init]('SDL_Init')
        self.Quit = self.SDL.get_function[c_SDL_Quit]('SDL_Quit')

        self.CreateWindow = self.SDL.get_function[c_SDL_CreateWindow]('SDL_CreateWindow')
        self.DestroyWindow = self.SDL.get_function[c_SDL_DestroyWindow]('SDL_DestroyWindow')

        self.GetWindowSurface = self.SDL.get_function[c_SDL_GetWindowSurface]('SDL_GetWindowSurface')
        self.UpdateWindowSurface = self.SDL.get_function[c_SDL_UpdateWindowSurface]('SDL_UpdateWindowSurface')

        self.CreateRenderer = self.SDL.get_function[c_SDL_CreateRenderer]('SDL_CreateRenderer')
        self.CreateWindowAndRenderer = self.SDL.get_function[c_SDL_CreateWindowAndRenderer]('SDL_CreateWindowAndRenderer')
        self.RenderDrawPoint = self.SDL.get_function[c_SDL_RenderDrawPoint]('SDL_RenderDrawPoint')
        self.RenderDrawRect = self.SDL.get_function[c_SDL_RenderDrawRect]('SDL_RenderDrawRect')
        self.RenderDrawLine = self.SDL.get_function[c_SDL_RenderDrawLine]('SDL_RenderDrawLine')
        self.SetRenderDrawColor = self.SDL.get_function[c_SDL_SetRenderDrawColor]('SDL_SetRenderDrawColor')
        self.RenderPresent = self.SDL.get_function[c_SDL_RenderPresent]('SDL_RenderPresent')
        self.RenderClear = self.SDL.get_function[c_SDL_RenderClear]('SDL_RenderClear')
        self.SetRenderDrawBlendMode = self.SDL.get_function[c_SDL_SetRenderDrawBlendMode]('SDL_SetRenderDrawBlendMode')
        self.SetRenderTarget = self.SDL.get_function[c_SDL_SetRenderTarget]('SDL_SetRenderTarget')
        self.RenderCopy = self.SDL.get_function[c_SDL_RenderCopy]('SDL_RenderCopy')

        self.CreateTexture = self.SDL.get_function[c_SDL_CreateTexture]('SDL_CreateTexture')


        self.MapRGB = self.SDL.get_function[c_SDL_MapRGB]('SDL_MapRGB')
        self.FillRect = self.SDL.get_function[c_SDL_FillRect]('SDL_FillRect')
        self.Delay = self.SDL.get_function[c_SDL_Delay]('SDL_Delay')
        self.PollEvent = self.SDL.get_function[c_SDL_PollEvent]('SDL_PollEvent')
        print("Finished SDL binding")

