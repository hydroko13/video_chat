package main


import "odinpnp"
import "core:fmt"
import rl "vendor:raylib"

main :: proc() {
    
    capcontext := odinpnp.Cap_createContext()
    if cast(rawptr)capcontext == nil {
        fmt.println("Failed to make context")
    }
    defer odinpnp.Cap_releaseContext(capcontext)

    devices := odinpnp.Cap_getDeviceCount(capcontext)

    fmt.println("devices found", devices)

    format_id: odinpnp.CapFormatID = 0

    info: odinpnp.CapFormatInfo

    odinpnp.Cap_getFormatInfo(capcontext, 0, format_id, &info)
    


    stream := odinpnp.Cap_openStream(capcontext, 0, 0)

    defer odinpnp.Cap_closeStream(capcontext, stream)
    
    buffer := make([]byte, info.width * info.height * 3)

    defer delete(buffer)

    buffer_ptr := raw_data(buffer)

    rl.InitWindow(i32(info.width), i32(info.height), "Cam")
    defer rl.CloseWindow()

    for !rl.WindowShouldClose() {
        if odinpnp.Cap_hasNewFrame(capcontext, stream) == 1 {
            odinpnp.Cap_captureFrame(capcontext, stream, cast(rawptr)(&buffer_ptr[0]), info.width * info.height * 3)

            
            
        }

        frame_img := rl.Image{}

        frame_img.data = cast(rawptr)(&buffer_ptr[0])

        frame_img.format = .UNCOMPRESSED_R8G8B8

        frame_img.height = i32(info.height)
        frame_img.width = i32(info.width)

        frame_img.mipmaps = 1

        frame_tex := rl.LoadTextureFromImage(frame_img)
        defer rl.UnloadTexture(frame_tex)


        rl.BeginDrawing()
        rl.DrawTexture(frame_tex, 0, 0, rl.WHITE)
        rl.EndDrawing()
    }



    
    
}