from SDL import *

comptime width = 700
comptime height = 400

fn main() raises:
    var sdl = SDL()
    
    var res = sdl.Init(0x00000020)
    var window = sdl.CreateWindow("Example".unsafe_ptr(),
                                  SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
                                  width, height, SDL_WINDOW_SHOWN)
    var renderer = sdl.CreateRenderer(window, -1, 0)
    var display = sdl.CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, width, height)

    _ = sdl.SetRenderTarget(renderer, display)


    fn redraw(sdl: SDL) raises:
        _ = sdl.SetRenderTarget(renderer, display)

        _ = sdl.SetRenderDrawColor(renderer,0, 0, 0, 255)
        _ = sdl.RenderClear(renderer)

        _ = sdl.SetRenderDrawColor(renderer, 255, 0, 0, 255)
        _ = sdl.RenderDrawPoint(renderer, 200, 200)
        _ = sdl.RenderDrawLine(renderer, 100, 100, 500, 100)

        _ = sdl.SetRenderTarget(renderer, 0)
        _ = sdl.RenderCopy(renderer, display, 0, 0)
        _ = sdl.RenderPresent(renderer)

    var event = Event()
    var running = True

    while running:
        while sdl.PollEvent(UnsafePointer(to=event).unsafe_origin_cast[MutOrigin.external]()):            
            if (event.type == SDL_MOUSEWHEEL): 
                var mwe = event.as_mousewheel()
                # var scale = (1 + mwe.preciseY.cast[DType.float64]()/20)
            if (event.type == SDL_QUIT):
                running = False
                break
        redraw(sdl)

        _= sdl.Delay(Int(1000 / 120))

    sdl.DestroyWindow(window)
    sdl.Quit()
 