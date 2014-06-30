
require 'Module/LaunchpadModule'
require 'Data/Instrument'

access_x     = 3
access_y     = 4
access_pitch = 1

-- Aufteile in anderen Mappings ? 
-- tone.cis
-- label.cis
-- X.cis
-- Y.cis

-- equals ? 

note = { 
    c   = {  0 , "C-"  , 1, 2 },
    cis = {  1 , "C#"  , 2, 1 },
    d   = {  3 , "D-"  , 2, 2 },
    dis = {  4 , "D#"  , 3, 1 },
    e   = {  5 , "E-"  , 3, 2 },
    f   = {  6 , "F-"  , 4, 2 },
    fis = {  7 , "F#"  , 5, 1 },
    g   = {  8 , "G-"  , 5, 2 },
    gis = {  9 , "G#"  , 6, 1 },
    a   = { 10 , "A-"  , 6, 2 },
    ais = { 11 , "A#"  , 7, 1 },
    b   = { 12 , "B-"  , 7, 2 }, -- h
    C   = { 13 , "C-"  , 8, 2 },
    off = { -1 , "OFF" , 4, 1 }, 
}

-- this is a strange y -> x map for notes
reverse_mapping = {
    { note.off, note.cis, note.dis, note.off, note.fis, note.gis, note.ais, note.off},
    { note.c  , note.d  , note.e  , note.f  , note.g  , note.a  , note.b  , note.C  },
}

-- --
-- Keyboard Module 
--
class "KeyboardModule" (LaunchpadModule)

-- ich brauch einen kontainer über den die 
-- Module miteinander reden können
function KeyboardModule:__init(pad,instruments)
    LaunchpadModule:__init(self)
    self.pad    = pad
    self.inst   = instruments
    self.offset = 6
    -- default
    self.color = {
        note        = self.pad.color.green ,
        active_note = self.pad.color.flash.orange,
        octave      = self.pad.color.yellow,
        off         = self.pad.color.red,
        manover     = self.pad.color.orange,
    }
    self.note = note.c
end

function KeyboardModule:_activate()
    self:clear()
    self.pad:set_flash(true)
    self:_setup_keys()
    self:_setup_callbacks()
    self:_setup_client()
end

function KeyboardModule:clear()
    local y0 = self.offset
    local y1 = self.offset + 1
    for x=1,8,1 do
        self.pad:set_matrix(x,y0,self.pad.color.off)
        self.pad:set_matrix(x,y1,self.pad.color.off)
    end
end

function KeyboardModule:_deactivate()
    self:clear()
    self.pad:unregister_matrix_listener()
end

function KeyboardModule:_setup_callbacks()
    local function matrix_callback(pad,msg)
        local press   = 0x7F
        local release = 0x00
        if (msg.y > self.offset and msg.y < (self.offset + 3) ) then
            if (msg.vel == release) then 
                self:untrigger_note()
            else
                if (msg.y == 2 + self.offset ) then
                    -- notes only
                    self:set_note(msg.x, msg.y)
                    self:trigger_note()
                else
                    if (msg.x == 1) then
                        self.inst:octave_down()
                    elseif (msg.x == 8) then
                        self.inst:octave_up()
                    else
                        self:set_note(msg.x, msg.y)
                        self:trigger_note()
                    end
                end
                self:update_keys()
            end
        end
    end
    self.pad:register_matrix_listener(matrix_callback)
end

function KeyboardModule:set_note(x,y)
    -- print(("set (%s,%s)"):format(x,y))
    -- self.note = { x , y - self.offset }
    self.note = reverse_mapping[y - self.offset][x]
    -- todo set note on instrument too 
end

function KeyboardModule:update_keys()
    self:update_notes()
    self:update_octave()
    self:update_active_note()
end

function KeyboardModule:_setup_keys()
    self:update_keys()
    -- manover buttons
    self.pad:set_matrix(
        0,
        self.offset,
        self.color.manover)
    self.pad:set_matrix(
        7,
        self.offset,
        self.color.manover)
    -- off button
    self.pad:set_matrix(
        3,
        self.offset,
        self.color.off)
end

function KeyboardModule:update_octave()
    self.pad:set_matrix(
        self.inst:get_octave() - 1, 
        1 + self.offset,
        self.color.octave)
end

function is_not_off(tone) return tone[access_pitch] ~= -1 end
function is_off(tone)     return tone[access_pitch] == -1 end

function KeyboardModule:update_notes()
    for note,tone in pairs(note) do
        if (is_not_off(tone)) then
            self.pad:set_matrix(
            tone[access_x],
            tone[access_y] + self.offset,
            self.color.note)
        else
            self.pad:set_matrix(
            tone[access_x],
            tone[access_y] + self.offset,
            self.color.off)
        end
    end
end


function KeyboardModule:_setup_client()
    --self.client, socket_error = renoise.Socket.create_client( "localhost", 8008, renoise.Socket.PROTOCOL_UDP)
    self.client = renoise.Socket.create_client( "localhost", 8008, renoise.Socket.PROTOCOL_UDP)
end

function KeyboardModule:trigger_note()
    local OscMessage = renoise.Osc.Message
    local instrument = 1
    local track      = instrument
    local pitch      = self.note[access_pitch]
    local velocity   = 127
    print(("pitch : %s"):format(pitch))
    if pitch == -1 then
        print("nope")
    else
        -- self.client, socket_error = renoise.Socket.create_client( "localhost", 8008, renoise.Socket.PROTOCOL_UDP)
        self.client:send(OscMessage("/renoise/trigger/note_on",{
            {tag="i",value=instrument},
            {tag="i",value=track},
            {tag="i",value=(pitch + (self.inst:get_octave() * 13))},
            {tag="i",value=velocity}}))
    end
end

function KeyboardModule:untrigger_note()
    --self.client:send(OscMessage("/renoise/trigger/note_on",{
    print("not yet")
end

function KeyboardModule:update_active_note()
    local x     = self.note[access_x]
    local y     = self.note[access_y] + self.offset
    local off   = self.pad.color.off
    local color = self.color.active_note
    -- self.pad:set_matrix(x,y,off)
    print(("active note : (%s,%s)"):format(x,y))
    if (is_off(self.note)) then
        color = self.color.off
    end
    self.pad:set_matrix( x, y, self.color.active_note )
end

