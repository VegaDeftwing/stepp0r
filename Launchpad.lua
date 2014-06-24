-- Launchpad functions and tests
--

function list_midi_devices () 
    print("output devices")
    for k,v in pairs(renoise.Midi.available_output_devices()) do 
        print(k,v) 
    end
    print("input devices")
    for k,v in pairs(renoise.Midi.available_input_devices()) do 
        print(k,v) 
    end
end

colors = {
    full = {
        yellow = 62,
        amber  = 63,
        green  = 60,
        red    = 15,
        orange = 47
    },
    dim = {
        red    = 13,
        green  = 28
    },
    off = 0
}

-- Launchpad class.
--
class "Launchpad"

function Launchpad:__init()
    self:_watch()
end

function Launchpad:_watch()
    for k,v in pairs(renoise.Midi.available_input_devices()) do
        if string.find(v, "Launchpad") then
            self:_connect(v)
        end
    end
end

function Launchpad:_connect(midi_device_name)
    print("connect : " ..  midi_device_name)
    -- self.midi_input  = renoise.Midi.create_input_device(device_name [,callback] [, sysex_callback])
    self.midi_out = renoise.Midi.create_output_device(midi_device_name)
end

function Launchpad:send(channel, number, value)
    --if (not self.midi_out or not self.midi_out.is_open) then
    --    print("midi is not open")
    --    return
    --end

    local message = {channel, number, value}

    print(("Launchpad : send MIDI %X %X %X"):format(message[1], message[2], message[3]))
    
    self.midi_out:send(message)
end

function Launchpad:set_matrix( x, y , color )
    if ( x < 8 and x > -1 and y < 8 and y > -1) then
        self:send(0x90 , x * 16 + y , color)
    end
end

function Launchpad:example_matrix()
    for x=0,7,1 do 
        for y=0,7,1 do 
            pad:set_matrix(x,y,x+(y*8)) 
        end 
    end 
end

function Launchpad:example_clear()
    for x=0,7,1 do 
        for y=0,7,1 do 
            pad:set_matrix(x,y,0)
        end 
    end 
end
