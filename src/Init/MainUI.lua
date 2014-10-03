


class "MainUI"

function MainUI:__init()
    self.vb = renoise.ViewBuilder()
    self.button_size = 18
    self.text_size   = 70
    self.input_size  = 200
    self.command_button_size = 80
end

function MainUI:create_ui()
    self:create_logo()
    self:create_title()
    self:create_device_row()
    self:create_osc_row()
    self:create_start_stop_button()
    self:create_quit_button()
    self:create_container()
end

function MainUI:create_device_row()
    self.device_row_button = self.vb:button{
        visible = true,
        bitmap  = "reload.bmp",
        width   = self.button_size,
        tooltip = "reload device list"
    }
    self.device_row_popup = self.vb:popup {
        width = self.input_size,
        tooltip = "Choose a Device to operate on"
    }
    self.device_row = self.vb:row{
        spacing = 3,
        self.device_row_button,
        self.vb:text{
            text = "Device",
            width = self.text_size,
        },
        self.device_row_popup,
    }
end

function MainUI:disable_device_row()
    self.device_row_button.active = false
    self.device_row_popup.active = false
end

function MainUI:enable_device_row()
    self.device_row_button.active = true
    self.device_row_popup.active = true
end

function MainUI:create_osc_row()
    self.osc_row_checkbox = self.vb:checkbox{
        visible = true,
        value   = true,
        width   = self.button_size,
        tooltip = "send notes to local osc server (UDP)"
    }
    self.osc_row_text = self.vb:text {
        text = 'none',
        width = self.input_size,
        tooltip = "port of the local osc server (UDP)",
        visible = false,
    }
    self.osc_row_textfield = self.vb:textfield {
        text = '1234',
        width = self.input_size,
        tooltip = "port of the local osc server (UDP)"
    }
    self.osc_row = self.vb:row{
        spacing = 3,
        self.osc_row_checkbox,
        self.vb:text{
            text = "OSC Port",
            width = self.text_size,
        },
        self.osc_row_textfield,
        self.osc_row_text,
    }
end

function MainUI:disable_osc_row()
    self.osc_row_checkbox.active = false
    self.osc_row_text.text = self.osc_row_textfield.text
    self.osc_row_textfield.visible = false
    self.osc_row_text.visible = true
end

function MainUI:enable_osc_row()
    self.osc_row_checkbox.active = true
    self.osc_row_text.visible = false
    self.osc_row_textfield.visible = true
end

function MainUI:create_container()
    self.container = self.vb:column{
        margin = 6,
        spacing = 8,
        self.vb:horizontal_aligner{
            mode = "center",
            self.logo,
        },
        self.vb:column {
            spacing = 4,
            margin = 4,
            self.osc_row,
            self.device_row,
        },
        self.vb:row {
            margin = 4,
            spacing = 4,
            self.start_stop_button,
            self.quit_button,
        }
    }
end

function MainUI: create_start_stop_button()
    self.start_stop_button = self.vb:button {
        text = "Start",
        width = self.command_button_size,
        notifier = function ()
            self:disable_device_row()
            self:disable_osc_row()
        end
    }
end

function MainUI:create_quit_button()
    self.quit_button = self.vb:button {
        text = "Quit",
        width = self.command_button_size,
        notifier = function ()
            self:enable_device_row()
            self:enable_osc_row()
        end
    }
end


function MainUI:create_logo()
    self.logo = self.vb:bitmap{
        bitmap = "logo.png",
        mode = "transparent",
    }
end

function MainUI:create_title()
    self.title = self.vb:text {
        text = "Awesome"
    }
end

