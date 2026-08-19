if addon == nil then
    return {}
end

addon.name      = 'sanctumnameplates'
addon.author    = 'Sanctum'
addon.version   = '0.13.0'
addon.desc      = 'Draws readable, depth-tested names over rendered entities.'

require 'common'

local chat = require 'chat'
local d3d8 = require 'd3d8'
local depth_renderer = require 'depth_renderer'
local imgui = require 'imgui'
local settings = require 'settings'

local native_name_modes = { 'none', 'all', 'players' }
local native_name_mode_labels = 'Off\0On\0Players Only\0'
local font_choices = {
    { key = 'default', label = 'Ashita Default' },
    { key = 'arial', label = 'Arial', path = 'C:\\Windows\\Fonts\\arial.ttf' },
    { key = 'arial_bold', label = 'Arial Bold', path = 'C:\\Windows\\Fonts\\arialbd.ttf' },
    { key = 'calibri', label = 'Calibri', path = 'C:\\Windows\\Fonts\\calibri.ttf' },
    { key = 'consolas', label = 'Consolas', path = 'C:\\Windows\\Fonts\\consola.ttf' },
    { key = 'consolas_bold', label = 'Consolas Bold', path = 'C:\\Windows\\Fonts\\consolab.ttf' },
    { key = 'courier_new', label = 'Courier New', path = 'C:\\Windows\\Fonts\\cour.ttf' },
    { key = 'georgia', label = 'Georgia', path = 'C:\\Windows\\Fonts\\georgia.ttf' },
    { key = 'segoe_ui', label = 'Segoe UI', path = 'C:\\Windows\\Fonts\\segoeui.ttf' },
    { key = 'tahoma', label = 'Tahoma', path = 'C:\\Windows\\Fonts\\tahoma.ttf' },
    { key = 'trebuchet', label = 'Trebuchet MS', path = 'C:\\Windows\\Fonts\\trebuc.ttf' },
    { key = 'verdana', label = 'Verdana', path = 'C:\\Windows\\Fonts\\verdana.ttf' },
}
local chainbreaker_names = {
    ['Valkurm Leech King'] = true,
    ['CB Leech King'] = true,
}

local configurable_colors = {
    { key = 'mob_unclaimed', label = 'Unclaimed mob', default = { 1.00, 0.93, 0.58 } },
    { key = 'mob_party_claimed', label = 'Party-claimed mob', default = { 1.00, 0.35, 0.35 } },
    { key = 'mob_other_claimed', label = 'Other-claimed mob', default = { 0.68, 0.45, 0.85 } },
    { key = 'mob_engaged', label = 'Party-engaged mob', default = { 1.00, 0.55, 0.18 } },
    { key = 'target_hp_bar', label = 'Target HP bar', default = { 1.00, 0.55, 0.18 } },
    { key = 'difficulty_too_weak', label = 'Too Weak', default = { 0.55, 0.55, 0.55 } },
    { key = 'difficulty_incredibly_easy', label = 'Incredibly Easy Prey', default = { 0.30, 0.70, 0.35 } },
    { key = 'difficulty_easy_prey', label = 'Easy Prey', default = { 0.40, 0.90, 0.40 } },
    { key = 'difficulty_decent', label = 'Decent Challenge', default = { 0.68, 0.86, 0.35 } },
    { key = 'difficulty_even', label = 'Even Match', default = { 1.00, 0.93, 0.38 } },
    { key = 'difficulty_tough', label = 'Tough', default = { 1.00, 0.68, 0.22 } },
    { key = 'difficulty_very_tough', label = 'Very Tough', default = { 1.00, 0.38, 0.18 } },
    { key = 'difficulty_incredibly_tough', label = 'Incredibly Tough', default = { 1.00, 0.16, 0.16 } },
}

local defaults = T{
    settings_version = 13,
    enabled = true,
    native_name_mode = 'players',
    native_restore_mode = 'all',
    max_distance = 100.0,
    font_size = 16.0,
    target_font_size = 20.0,
    close_font_size = 20.0,
    font_face = 'default',
    target_color_r = 1.00,
    target_color_g = 0.72,
    target_color_b = 0.24,
    avoid_overlaps = true,
    overlap_spacing = 3.0,
    overlap_max_shift = 96.0,
    overlap_fade_alpha = 0.18,
    rare_glimmer = true,
    glimmer_intensity = 1.05,
    auto_model_bounds = true,
    label_gap = 0.25,
    fallback_model_height = 2.0,
    outline_width = 1,
    show_mobs = true,
    show_npcs = true,
    show_players = false,
    show_distance = false,
    show_levels = true,
    difficulty_coloring = false,
    show_hp_bars = true,
    show_hp_percent = true,
    hp_show_when_targeted = true,
    hp_show_when_damaged = true,
    hp_show_when_engaged = true,
    hp_bar_max_distance = 100.0,
    hp_percent_max_distance = 100.0,
    hp_percent_font_size = 12.0,
    target_hp_percent_font_size = 14.0,
    hp_bar_width = 76.0,
    hp_bar_height = 6.0,
    target_hp_bar_width = 96.0,
    target_hp_bar_height = 8.0,
    auto_request_levels = true,
    level_request_interval = 15.0,
    scan_interval = 0.25,
}

for _, color in ipairs(configurable_colors) do
    defaults[color.key .. '_color_r'] = color.default[1]
    defaults[color.key .. '_color_g'] = color.default[2]
    defaults[color.key .. '_color_b'] = color.default[3]
end

local config = settings.load(defaults)
local state = {
    ui_open = T{ false },
    entities = {},
    last_scan = -100,
    zoning = false,
    dirty = false,
    last_error = nil,
    last_error_time = -100,
    native_name_mode = nil,
    mob_levels = {},
    model_bounds = {},
    last_level_request = -100,
    last_level_response = -100,
    fonts = {},
    font_names = { 'default' },
    font_options = 'Ashita Default\0',
}

local buffers = {}

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local function message(text)
    print(chat.header(addon.name):append(chat.message(text)))
end

local function success(text)
    print(chat.header(addon.name):append(chat.success(text)))
end

local function report_error(text)
    local now = os.clock()
    if text ~= state.last_error or now - state.last_error_time >= 30 then
        state.last_error = text
        state.last_error_time = now
        print(chat.header(addon.name):append(chat.error(text)))
    end
end

local function load_nameplate_fonts()
    state.fonts = {}
    state.font_names = { 'default' }
    local labels = { 'Ashita Default' }

    if imgui.AddFontFromFileTTF ~= nil then
        for index = 2, #font_choices do
            local choice = font_choices[index]
            if ashita.fs.exists(choice.path) then
                local ok, font = pcall(imgui.AddFontFromFileTTF, choice.path, 32)
                if ok and font ~= nil then
                    state.fonts[choice.key] = font
                    state.font_names[#state.font_names + 1] = choice.key
                    labels[#labels + 1] = choice.label
                end
            end
        end
    end

    state.font_options = table.concat(labels, '\0') .. '\0'
end

local function set_native_name_mode(mode)
    mode = tostring(mode or 'all'):lower()
    local command_modes = {
        none = 'none',
        players = 'hidenpc',
        all = 'all',
    }
    local command_mode = command_modes[mode] or 'all'
    if state.native_name_mode == mode then
        return
    end

    local chat_manager = AshitaCore:GetChatManager()
    if chat_manager == nil then
        return
    end

    chat_manager:QueueCommand(-1, ('/nameplate mode %s'):format(command_mode))
    state.native_name_mode = mode
end

local function sync_native_name_visibility()
    if config.enabled == false then
        set_native_name_mode(config.native_restore_mode)
        return
    end
    set_native_name_mode(config.native_name_mode)
end

local function sync_buffers()
    buffers.enabled = T{ config.enabled ~= false }
    local native_mode_index = 0
    for index, mode in ipairs(native_name_modes) do
        if mode == config.native_name_mode then
            native_mode_index = index - 1
            break
        end
    end
    buffers.native_name_mode = T{ native_mode_index }
    buffers.max_distance = T{ tonumber(config.max_distance) or defaults.max_distance }
    buffers.font_size = T{ tonumber(config.font_size) or defaults.font_size }
    buffers.target_font_size = T{
        tonumber(config.target_font_size) or defaults.target_font_size
    }
    buffers.close_font_size = T{
        tonumber(config.close_font_size) or defaults.close_font_size
    }
    local font_face_index = 0
    for index, name in ipairs(state.font_names) do
        if name == config.font_face then
            font_face_index = index - 1
            break
        end
    end
    buffers.font_face_index = T{ font_face_index }
    buffers.target_color = T{
        tonumber(config.target_color_r) or defaults.target_color_r,
        tonumber(config.target_color_g) or defaults.target_color_g,
        tonumber(config.target_color_b) or defaults.target_color_b,
    }
    for _, color in ipairs(configurable_colors) do
        buffers[color.key .. '_color'] = T{
            tonumber(config[color.key .. '_color_r']) or color.default[1],
            tonumber(config[color.key .. '_color_g']) or color.default[2],
            tonumber(config[color.key .. '_color_b']) or color.default[3],
        }
    end
    buffers.avoid_overlaps = T{ config.avoid_overlaps ~= false }
    buffers.overlap_spacing = T{
        tonumber(config.overlap_spacing) or defaults.overlap_spacing
    }
    buffers.overlap_max_shift = T{
        tonumber(config.overlap_max_shift) or defaults.overlap_max_shift
    }
    buffers.rare_glimmer = T{ config.rare_glimmer ~= false }
    buffers.glimmer_intensity = T{
        tonumber(config.glimmer_intensity) or defaults.glimmer_intensity
    }
    buffers.auto_model_bounds = T{ config.auto_model_bounds ~= false }
    buffers.label_gap = T{ tonumber(config.label_gap) or defaults.label_gap }
    buffers.fallback_model_height = T{
        tonumber(config.fallback_model_height) or defaults.fallback_model_height
    }
    buffers.outline_width = T{ tonumber(config.outline_width) or defaults.outline_width }
    buffers.show_mobs = T{ config.show_mobs ~= false }
    buffers.show_npcs = T{ config.show_npcs == true }
    buffers.show_players = T{ config.show_players ~= false }
    buffers.show_distance = T{ config.show_distance == true }
    buffers.show_levels = T{ config.show_levels ~= false }
    buffers.difficulty_coloring = T{ config.difficulty_coloring == true }
    buffers.show_hp_bars = T{ config.show_hp_bars ~= false }
    buffers.show_hp_percent = T{ config.show_hp_percent ~= false }
    buffers.hp_show_when_targeted = T{ config.hp_show_when_targeted ~= false }
    buffers.hp_show_when_damaged = T{ config.hp_show_when_damaged ~= false }
    buffers.hp_show_when_engaged = T{ config.hp_show_when_engaged ~= false }
    buffers.hp_bar_max_distance = T{
        tonumber(config.hp_bar_max_distance) or defaults.hp_bar_max_distance
    }
    buffers.hp_percent_max_distance = T{
        tonumber(config.hp_percent_max_distance) or defaults.hp_percent_max_distance
    }
    buffers.hp_percent_font_size = T{
        tonumber(config.hp_percent_font_size) or defaults.hp_percent_font_size
    }
    buffers.target_hp_percent_font_size = T{
        tonumber(config.target_hp_percent_font_size) or defaults.target_hp_percent_font_size
    }
    buffers.hp_bar_width = T{ tonumber(config.hp_bar_width) or defaults.hp_bar_width }
    buffers.hp_bar_height = T{ tonumber(config.hp_bar_height) or defaults.hp_bar_height }
    buffers.target_hp_bar_width = T{
        tonumber(config.target_hp_bar_width) or defaults.target_hp_bar_width
    }
    buffers.target_hp_bar_height = T{
        tonumber(config.target_hp_bar_height) or defaults.target_hp_bar_height
    }
end

local function normalize_config()
    if (tonumber(config.settings_version) or 0) < 2 then
        config.settings_version = 2
        config.hide_native_names = true
        config.show_npcs = true
    end
    if (tonumber(config.settings_version) or 0) < 3 then
        config.settings_version = 3
        config.show_levels = true
        config.show_hp_bars = true
    end
    if (tonumber(config.settings_version) or 0) < 4 then
        config.settings_version = 4
        config.auto_model_bounds = true
        config.label_gap = defaults.label_gap
        config.fallback_model_height = defaults.fallback_model_height
    end
    if (tonumber(config.settings_version) or 0) < 5 then
        config.settings_version = 5
        config.target_font_size = defaults.target_font_size
    end
    if (tonumber(config.settings_version) or 0) < 6 then
        config.settings_version = 6
        config.native_name_mode = config.hide_native_names == false and 'all' or 'players'
        config.show_players = false
        config.target_color_r = defaults.target_color_r
        config.target_color_g = defaults.target_color_g
        config.target_color_b = defaults.target_color_b
        config.show_hp_percent = true
    end
    if (tonumber(config.settings_version) or 0) < 7 then
        config.settings_version = 7
        config.font_size = defaults.font_size
        config.target_font_size = defaults.target_font_size
    end
    if (tonumber(config.settings_version) or 0) < 8 then
        config.settings_version = 8
        config.native_name_mode = 'players'
    end
    if (tonumber(config.settings_version) or 0) < 9 then
        config.settings_version = 9
        config.native_name_mode = 'players'
        config.font_face = defaults.font_face
        config.hp_percent_font_size = defaults.hp_percent_font_size
    end
    if (tonumber(config.settings_version) or 0) < 10 then
        config.settings_version = 10
        config.rare_glimmer = true
        config.glimmer_intensity = defaults.glimmer_intensity
    end
    if (tonumber(config.settings_version) or 0) < 11 then
        config.settings_version = 11
        if config.native_name_mode == 'players_pets' then
            config.native_name_mode = 'players'
        end
    end
    if (tonumber(config.settings_version) or 0) < 12 then
        config.settings_version = 12
        config.close_font_size = defaults.close_font_size
        config.glimmer_intensity = defaults.glimmer_intensity
    end
    if (tonumber(config.settings_version) or 0) < 13 then
        config.settings_version = 13
        config.avoid_overlaps = defaults.avoid_overlaps
        config.overlap_spacing = defaults.overlap_spacing
        config.overlap_max_shift = defaults.overlap_max_shift
        config.overlap_fade_alpha = defaults.overlap_fade_alpha
        config.difficulty_coloring = defaults.difficulty_coloring
        config.hp_show_when_targeted = defaults.hp_show_when_targeted
        config.hp_show_when_damaged = defaults.hp_show_when_damaged
        config.hp_show_when_engaged = defaults.hp_show_when_engaged
        config.hp_bar_max_distance = defaults.hp_bar_max_distance
        config.hp_percent_max_distance = defaults.hp_percent_max_distance
        config.target_hp_percent_font_size = defaults.target_hp_percent_font_size
        config.target_hp_bar_width = defaults.target_hp_bar_width
        config.target_hp_bar_height = defaults.target_hp_bar_height
        for _, color in ipairs(configurable_colors) do
            config[color.key .. '_color_r'] = color.default[1]
            config[color.key .. '_color_g'] = color.default[2]
            config[color.key .. '_color_b'] = color.default[3]
        end
    end

    config.native_name_mode = tostring(config.native_name_mode or defaults.native_name_mode):lower()
    if not config.native_name_mode:any('none', 'all', 'players') then
        config.native_name_mode = defaults.native_name_mode
    end
    config.font_face = tostring(config.font_face or defaults.font_face):lower()
    config.max_distance = clamp(tonumber(config.max_distance) or defaults.max_distance, 25, 100)
    config.font_size = clamp(tonumber(config.font_size) or defaults.font_size, 10, 36)
    config.target_font_size = clamp(
        tonumber(config.target_font_size) or defaults.target_font_size, 10, 42)
    config.close_font_size = clamp(
        tonumber(config.close_font_size) or defaults.close_font_size, 10, 42)
    config.hp_percent_font_size = clamp(
        tonumber(config.hp_percent_font_size) or defaults.hp_percent_font_size, 8, 24)
    config.target_hp_percent_font_size = clamp(
        tonumber(config.target_hp_percent_font_size)
            or defaults.target_hp_percent_font_size, 8, 30)
    config.target_color_r = clamp(
        tonumber(config.target_color_r) or defaults.target_color_r, 0, 1)
    config.target_color_g = clamp(
        tonumber(config.target_color_g) or defaults.target_color_g, 0, 1)
    config.target_color_b = clamp(
        tonumber(config.target_color_b) or defaults.target_color_b, 0, 1)
    for _, color in ipairs(configurable_colors) do
        local red_key = color.key .. '_color_r'
        local green_key = color.key .. '_color_g'
        local blue_key = color.key .. '_color_b'
        config[red_key] = clamp(tonumber(config[red_key]) or color.default[1], 0, 1)
        config[green_key] = clamp(tonumber(config[green_key]) or color.default[2], 0, 1)
        config[blue_key] = clamp(tonumber(config[blue_key]) or color.default[3], 0, 1)
    end
    config.overlap_spacing = clamp(
        tonumber(config.overlap_spacing) or defaults.overlap_spacing, 0, 12)
    config.overlap_max_shift = clamp(
        tonumber(config.overlap_max_shift) or defaults.overlap_max_shift, 20, 240)
    config.overlap_fade_alpha = clamp(
        tonumber(config.overlap_fade_alpha) or defaults.overlap_fade_alpha, 0, 1)
    config.glimmer_intensity = clamp(
        tonumber(config.glimmer_intensity) or defaults.glimmer_intensity, 0.2, 1.5)
    config.label_gap = clamp(tonumber(config.label_gap) or defaults.label_gap, -1, 5)
    config.fallback_model_height = clamp(
        tonumber(config.fallback_model_height) or defaults.fallback_model_height, 0.5, 10)
    config.outline_width = math.floor(clamp(tonumber(config.outline_width) or defaults.outline_width, 0, 2))
    config.hp_bar_width = clamp(tonumber(config.hp_bar_width) or defaults.hp_bar_width, 40, 180)
    config.hp_bar_height = clamp(tonumber(config.hp_bar_height) or defaults.hp_bar_height, 4, 14)
    config.target_hp_bar_width = clamp(
        tonumber(config.target_hp_bar_width) or defaults.target_hp_bar_width, 40, 240)
    config.target_hp_bar_height = clamp(
        tonumber(config.target_hp_bar_height) or defaults.target_hp_bar_height, 4, 20)
    config.hp_bar_max_distance = clamp(
        tonumber(config.hp_bar_max_distance) or defaults.hp_bar_max_distance, 0, 100)
    config.hp_percent_max_distance = clamp(
        tonumber(config.hp_percent_max_distance) or defaults.hp_percent_max_distance, 0, 100)
    config.level_request_interval = clamp(
        tonumber(config.level_request_interval) or defaults.level_request_interval, 10, 120)
    config.scan_interval = clamp(tonumber(config.scan_interval) or defaults.scan_interval, 0.1, 2)
end

local function mark_dirty()
    normalize_config()
    state.dirty = true
    state.last_scan = -100
end

local function apply_buffers()
    config.enabled = buffers.enabled[1]
    config.native_name_mode = native_name_modes[buffers.native_name_mode[1] + 1]
        or defaults.native_name_mode
    config.max_distance = buffers.max_distance[1]
    config.font_size = buffers.font_size[1]
    config.target_font_size = buffers.target_font_size[1]
    config.close_font_size = buffers.close_font_size[1]
    config.font_face = state.font_names[buffers.font_face_index[1] + 1]
        or defaults.font_face
    config.target_color_r = buffers.target_color[1]
    config.target_color_g = buffers.target_color[2]
    config.target_color_b = buffers.target_color[3]
    for _, color in ipairs(configurable_colors) do
        local buffer = buffers[color.key .. '_color']
        config[color.key .. '_color_r'] = buffer[1]
        config[color.key .. '_color_g'] = buffer[2]
        config[color.key .. '_color_b'] = buffer[3]
    end
    config.avoid_overlaps = buffers.avoid_overlaps[1]
    config.overlap_spacing = buffers.overlap_spacing[1]
    config.overlap_max_shift = buffers.overlap_max_shift[1]
    config.rare_glimmer = buffers.rare_glimmer[1]
    config.glimmer_intensity = buffers.glimmer_intensity[1]
    config.auto_model_bounds = buffers.auto_model_bounds[1]
    config.label_gap = buffers.label_gap[1]
    config.fallback_model_height = buffers.fallback_model_height[1]
    config.outline_width = buffers.outline_width[1]
    config.show_mobs = buffers.show_mobs[1]
    config.show_npcs = buffers.show_npcs[1]
    config.show_players = buffers.show_players[1]
    config.show_distance = buffers.show_distance[1]
    config.show_levels = buffers.show_levels[1]
    config.difficulty_coloring = buffers.difficulty_coloring[1]
    config.show_hp_bars = buffers.show_hp_bars[1]
    config.show_hp_percent = buffers.show_hp_percent[1]
    config.hp_show_when_targeted = buffers.hp_show_when_targeted[1]
    config.hp_show_when_damaged = buffers.hp_show_when_damaged[1]
    config.hp_show_when_engaged = buffers.hp_show_when_engaged[1]
    config.hp_bar_max_distance = buffers.hp_bar_max_distance[1]
    config.hp_percent_max_distance = buffers.hp_percent_max_distance[1]
    config.hp_percent_font_size = buffers.hp_percent_font_size[1]
    config.target_hp_percent_font_size = buffers.target_hp_percent_font_size[1]
    config.hp_bar_width = buffers.hp_bar_width[1]
    config.hp_bar_height = buffers.hp_bar_height[1]
    config.target_hp_bar_width = buffers.target_hp_bar_width[1]
    config.target_hp_bar_height = buffers.target_hp_bar_height[1]
    mark_dirty()
    sync_native_name_visibility()
end

local function get_entity_kind(spawn_flags, is_pet)
    if is_pet or spawn_flags == 0x0102 then
        return 'pet'
    end
    if bit.band(spawn_flags, 0x10) ~= 0 then
        return 'mob'
    end
    if bit.band(spawn_flags, 0x0001) ~= 0 then
        return 'player'
    end
    if bit.band(spawn_flags, 0x0002) ~= 0 then
        return 'npc'
    end
    return nil
end

local function kind_enabled(kind)
    if kind == 'mob' then
        return config.show_mobs ~= false
    end
    if kind == 'pet' then
        return config.native_name_mode ~= 'all'
    end
    if kind == 'npc' then
        return config.show_npcs == true
    end
    if kind == 'player' then
        return config.show_players ~= false
    end
    return false
end

local function get_rare_kind(name)
    local lower_name = tostring(name or ''):lower()
    if lower_name:sub(1, 8) == 'variant ' or lower_name:sub(1, 2) == 'v ' then
        return 'variant'
    end
    if lower_name:sub(1, 3) == 'cb ' or chainbreaker_names[name] == true then
        return 'chainbreaker'
    end
    return nil
end

local function is_rendered(entity_manager, index)
    local flags = entity_manager:GetRenderFlags0(index)
    return bit.band(flags, 0x200) == 0x200 and bit.band(flags, 0x4000) == 0
end

local function clean_name(name)
    if name == nil then
        return nil
    end
    name = tostring(name):gsub('%z.*$', ''):trim()
    if name == '' then
        return nil
    end
    return name
end

local function get_player_index()
    local player = GetPlayerEntity()
    if player ~= nil and player.TargetIndex ~= nil then
        return tonumber(player.TargetIndex) or 0
    end
    return 0
end

local function valid_pointer(address)
    address = tonumber(address) or 0
    return address >= 0x10000 and address <= 0xFFFFFFFF
end

local function estimate_skeleton_height(actor_pointer)
    if not valid_pointer(actor_pointer) then
        return nil
    end

    -- These are Ashita's live actor skeleton buffers; the offsets are already in world scale.
    local skeleton_base = ashita.memory.read_uint32(actor_pointer + 0x6B8)
    if not valid_pointer(skeleton_base) then
        return nil
    end
    local skeleton_offset = ashita.memory.read_uint32(skeleton_base + 0x0C)
    if not valid_pointer(skeleton_offset) then
        return nil
    end
    local skeleton = ashita.memory.read_uint32(skeleton_offset)
    if not valid_pointer(skeleton) then
        return nil
    end

    local bone_count = tonumber(ashita.memory.read_uint16(skeleton + 0x32)) or 0
    if bone_count < 1 or bone_count > 256 then
        return nil
    end

    local generators = skeleton + 0x34 + 0x1E * bone_count + 4
    if not valid_pointer(generators) then
        return nil
    end

    local top_offset = nil
    for bone = 0, bone_count - 1 do
        local vertical = tonumber(ashita.memory.read_float(generators + bone * 0x1A + 0x12))
        if vertical ~= nil and vertical == vertical and math.abs(vertical) <= 40 then
            if top_offset == nil or vertical < top_offset then
                top_offset = vertical
            end
        end
    end

    if top_offset == nil or top_offset >= -0.05 then
        return nil
    end
    return clamp(-top_offset, 0.2, 30)
end

local function get_model_height(entity_manager, index, server_id)
    local model_scale = clamp(tonumber(entity_manager:GetModelSize(index)) or 1, 0.25, 8)
    local fallback = config.fallback_model_height * model_scale
    if config.auto_model_bounds == false then
        return fallback
    end

    local actor_pointer = tonumber(entity_manager:GetActorPointer(index)) or 0
    local cached = state.model_bounds[index]
    local now = os.clock()
    if cached ~= nil
        and cached.server_id == server_id
        and cached.actor_pointer == actor_pointer
        and now - cached.checked_at < 1.5 then
        return cached.height
    end

    local same_actor = cached ~= nil
        and cached.server_id == server_id
        and cached.actor_pointer == actor_pointer
    local ok, measured = pcall(estimate_skeleton_height, actor_pointer)
    local height = ok and measured or nil
    local has_measurement = height ~= nil
    if has_measurement and same_actor and cached.has_measurement then
        height = math.max(height, cached.height)
    elseif not has_measurement and same_actor and cached.has_measurement then
        height = cached.height
        has_measurement = true
    elseif not has_measurement then
        height = fallback
    end

    state.model_bounds[index] = {
        actor_pointer = actor_pointer,
        server_id = server_id,
        height = height,
        has_measurement = has_measurement,
        checked_at = now,
    }
    return height
end

local function scan_entities()
    local memory = AshitaCore:GetMemoryManager()
    if memory == nil then
        state.entities = {}
        return
    end

    local entity_manager = memory:GetEntity()
    if entity_manager == nil then
        state.entities = {}
        return
    end

    local player_index = get_player_index()
    local count = math.min(entity_manager:GetEntityMapSize() or 0, 0x900)
    local maximum_squared = config.max_distance * config.max_distance
    local found = {}
    local active_bounds = {}
    local pet_indices = {}

    for owner_index = 1, count - 1 do
        local owner_flags = entity_manager:GetSpawnFlags(owner_index)
        if bit.band(owner_flags, 0x0001) ~= 0 then
            local pet_index = tonumber(entity_manager:GetPetTargetIndex(owner_index)) or 0
            if pet_index > 0 and pet_index < count then
                pet_indices[pet_index] = true
            end
        end
    end

    for index = 1, count - 1 do
        if index ~= player_index and is_rendered(entity_manager, index) then
            local spawn_flags = entity_manager:GetSpawnFlags(index)
            local kind = get_entity_kind(spawn_flags, pet_indices[index] == true)
            if kind ~= nil and kind_enabled(kind) then
                local distance_squared = tonumber(entity_manager:GetDistance(index)) or -1
                if distance_squared >= 0 and distance_squared <= maximum_squared then
                    local name = clean_name(entity_manager:GetName(index))
                    if name ~= nil then
                        local server_id = tonumber(entity_manager:GetServerId(index)) or 0
                        found[#found + 1] = {
                            index = index,
                            name = name,
                            kind = kind,
                            server_id = server_id,
                            model_height = get_model_height(entity_manager, index, server_id),
                        }
                        active_bounds[index] = true
                    end
                end
            end
        end
    end

    for index in pairs(state.model_bounds) do
        if not active_bounds[index] then
            state.model_bounds[index] = nil
        end
    end

    state.entities = found
end

local function get_target_index()
    local memory = AshitaCore:GetMemoryManager()
    if memory == nil then
        return 0
    end
    local target = memory:GetTarget()
    if target == nil then
        return 0
    end
    return tonumber(target:GetTargetIndex(target:GetIsSubTargetActive())) or 0
end

local function get_player_level(memory)
    local player = memory:GetPlayer()
    if player == nil then
        return 0
    end
    return tonumber(player:GetMainJobLevel()) or 0
end

local function get_party_claim_ids(memory)
    local ids = {}
    local party = memory:GetParty()
    if party == nil then
        return ids
    end
    for index = 0, 17 do
        if tonumber(party:GetMemberIsActive(index)) == 1 then
            local server_id = tonumber(party:GetMemberServerId(index)) or 0
            if server_id > 0 then
                ids[bit.band(server_id, 0xFFFF)] = true
            end
        end
    end
    return ids
end

local function get_claim_kind(entity_manager, index, party_claim_ids)
    local claim_id = bit.band(tonumber(entity_manager:GetClaimStatus(index)) or 0, 0xFFFF)
    if claim_id == 0 then
        return 'unclaimed'
    end
    if party_claim_ids[claim_id] then
        return 'party'
    end
    return 'other'
end

local function get_difficulty_kind(mob_level, player_level)
    if mob_level == nil or player_level <= 0 then
        return nil
    end
    local difference = mob_level - player_level
    if difference <= -8 then
        return 'too_weak'
    elseif difference <= -5 then
        return 'incredibly_easy'
    elseif difference <= -2 then
        return 'easy_prey'
    elseif difference == -1 then
        return 'decent'
    elseif difference == 0 then
        return 'even'
    elseif difference <= 2 then
        return 'tough'
    elseif difference <= 4 then
        return 'very_tough'
    end
    return 'incredibly_tough'
end

local function hp_conditions_match(targeted, damaged, engaged)
    local has_condition = config.hp_show_when_targeted ~= false
        or config.hp_show_when_damaged ~= false
        or config.hp_show_when_engaged ~= false
    if not has_condition then
        return true
    end
    return (config.hp_show_when_targeted ~= false and targeted)
        or (config.hp_show_when_damaged ~= false and damaged)
        or (config.hp_show_when_engaged ~= false and engaged)
end

local function ingest_widescan_level(event)
    if event.data == nil or #event.data < 8 then
        return
    end

    local packed = struct.unpack('I', event.data, 0x04 + 1)
    local index = packed % 65536
    local level = math.floor(packed / 65536) % 256
    if index <= 0 or level <= 0 then
        return
    end

    local memory = AshitaCore:GetMemoryManager()
    local entity_manager = memory ~= nil and memory:GetEntity() or nil
    if entity_manager == nil then
        return
    end

    local server_id = tonumber(entity_manager:GetServerId(index)) or 0
    if server_id <= 0 then
        return
    end

    state.mob_levels[index] = {
        level = level,
        server_id = server_id,
    }
    state.last_level_response = os.clock()
end

local function request_level_scan()
    if config.show_levels == false or config.auto_request_levels == false then
        return
    end
    if GetPlayerEntity() == nil then
        return
    end

    local now = os.clock()
    local interval = config.level_request_interval or defaults.level_request_interval
    if now - state.last_level_request < interval
        or now - state.last_level_response < interval then
        return
    end

    local packet_manager = AshitaCore:GetPacketManager()
    if packet_manager == nil then
        return
    end

    packet_manager:AddOutgoingPacket(0x0F4, { 0, 0, 0, 0, 1, 0, 0, 0 })
    state.last_level_request = now
end

local function project(view, projection, viewport, world_x, world_y, world_z)
    local vx = world_x * view._11 + world_y * view._21 + world_z * view._31 + view._41
    local vy = world_x * view._12 + world_y * view._22 + world_z * view._32 + view._42
    local vz = world_x * view._13 + world_y * view._23 + world_z * view._33 + view._43
    local vw = world_x * view._14 + world_y * view._24 + world_z * view._34 + view._44

    local cx = vx * projection._11 + vy * projection._21 + vz * projection._31 + vw * projection._41
    local cy = vx * projection._12 + vy * projection._22 + vz * projection._32 + vw * projection._42
    local cz = vx * projection._13 + vy * projection._23 + vz * projection._33 + vw * projection._43
    local cw = vx * projection._14 + vy * projection._24 + vz * projection._34 + vw * projection._44

    if cw <= 0.001 then
        return nil
    end

    local ndc_x = cx / cw
    local ndc_y = cy / cw
    local ndc_z = cz / cw
    if ndc_z < 0 or ndc_z > 1 then
        return nil
    end

    local left = tonumber(viewport.X) or 0
    local top = tonumber(viewport.Y) or 0
    local width = tonumber(viewport.Width) or 0
    local height = tonumber(viewport.Height) or 0
    local screen_x = left + (ndc_x * 0.5 + 0.5) * width
    local screen_y = top + (-ndc_y * 0.5 + 0.5) * height

    if screen_x < left - 100 or screen_x > left + width + 100
        or screen_y < top - 100 or screen_y > top + height + 100 then
        return nil
    end

    return screen_x, screen_y, ndc_z
end

local function collect_labels(view, projection, viewport)
    local memory = AshitaCore:GetMemoryManager()
    if memory == nil then
        return {}
    end
    local entity_manager = memory:GetEntity()
    if entity_manager == nil then
        return {}
    end

    local target_index = get_target_index()
    local player_level = get_player_level(memory)
    local party_claim_ids = get_party_claim_ids(memory)
    local labels = {}

    for _, cached in ipairs(state.entities) do
        local index = cached.index
        if is_rendered(entity_manager, index) then
            local distance_squared = tonumber(entity_manager:GetDistance(index)) or -1
            if distance_squared >= 0 then
                local distance = math.sqrt(distance_squared)
                if distance <= config.max_distance then
                    local world_x = entity_manager:GetLocalPositionX(index)
                    local world_y = entity_manager:GetLocalPositionZ(index)
                        - cached.model_height - config.label_gap
                    local world_z = entity_manager:GetLocalPositionY(index)
                    local screen_x, screen_y, depth = project(
                        view, projection, viewport, world_x, world_y, world_z)

                    if screen_x ~= nil then
                        local targeted = index == target_index
                        local font_size = config.font_size
                        if distance <= 5 then
                            font_size = config.close_font_size
                        end
                        if targeted then
                            font_size = config.target_font_size
                        end
                        local name_text = cached.name
                        local level_text = nil
                        local difficulty_kind = nil
                        local hp_percent = nil
                        local show_hp_bar = false
                        local show_hp_percent = false
                        local claim_kind = nil
                        local engaged = false
                        if cached.kind == 'mob' then
                            engaged = tonumber(entity_manager:GetStatus(index)) == 1
                            claim_kind = get_claim_kind(entity_manager, index, party_claim_ids)
                            local level_info = state.mob_levels[index]
                            if config.show_levels ~= false then
                                if level_info ~= nil
                                    and level_info.server_id == cached.server_id
                                    and level_info.level > 0 then
                                    level_text = ('Lv.%d'):format(level_info.level)
                                    difficulty_kind = get_difficulty_kind(
                                        level_info.level, player_level)
                                end
                            end
                            if config.show_hp_bars ~= false or config.show_hp_percent ~= false then
                                local current_hp = clamp(
                                    tonumber(entity_manager:GetHPPercent(index)) or 0, 0, 100)
                                if hp_conditions_match(targeted, current_hp < 100, engaged) then
                                    show_hp_bar = config.show_hp_bars ~= false
                                        and distance <= config.hp_bar_max_distance
                                    show_hp_percent = config.show_hp_percent ~= false
                                        and distance <= config.hp_percent_max_distance
                                    if show_hp_bar or show_hp_percent then
                                        hp_percent = current_hp
                                    end
                                end
                            end
                        end
                        if config.show_distance then
                            name_text = ('%s  %.0fy'):format(name_text, distance)
                        end
                        local text = level_text ~= nil
                            and ('%s  %s'):format(level_text, name_text) or name_text
                        labels[#labels + 1] = {
                            text = text,
                            name_text = name_text,
                            level_text = level_text,
                            difficulty_kind = difficulty_kind,
                            kind = cached.kind,
                            distance = distance,
                            x = screen_x,
                            y = screen_y,
                            depth = depth,
                            alpha = 1.0,
                            targeted = targeted,
                            font_size = font_size,
                            hp_percent = hp_percent,
                            show_hp_bar = show_hp_bar,
                            show_hp_percent = show_hp_percent,
                            claim_kind = claim_kind,
                            engaged = engaged,
                            rare_kind = get_rare_kind(cached.name),
                            rare_seed = (cached.server_id % 97) / 97,
                        }
                    end
                end
            end
        end
    end

    table.sort(labels, function(left, right)
        return left.distance > right.distance
    end)
    return labels
end

local function get_nameplate_font()
    return state.fonts[config.font_face] or imgui.GetFont()
end

local function draw_config()
    if not state.ui_open[1] then
        return
    end

    imgui.SetNextWindowSize({ 520, 720 }, ImGuiCond_FirstUseEver)
    if imgui.Begin('Sanctum Nameplates v0.13.0##sanctumnameplates', state.ui_open, ImGuiWindowFlags_None) then
        local changed = false

        changed = imgui.Checkbox('Enabled', buffers.enabled) or changed
        changed = imgui.Combo('Original nameplates', buffers.native_name_mode,
            native_name_mode_labels) or changed
        if buffers.native_name_mode[1] == 1 then
            imgui.TextColored({ 0.65, 0.65, 0.65, 1.0 },
                'All native plates are on; native pets do not use the addon font.')
        elseif buffers.native_name_mode[1] == 2 then
            imgui.TextColored({ 0.65, 0.65, 0.65, 1.0 },
                'Original player plates stay visible; pets use the addon font.')
        end
        imgui.Separator()
        changed = imgui.SliderFloat('Font size', buffers.font_size, 10, 36, '%.0f px') or changed
        changed = imgui.SliderFloat('Target font size', buffers.target_font_size,
            10, 42, '%.0f px') or changed
        changed = imgui.SliderFloat('Font size within 5 yalms', buffers.close_font_size,
            10, 42, '%.0f px') or changed
        changed = imgui.Combo('Nameplate font', buffers.font_face_index,
            state.font_options) or changed
        changed = imgui.ColorEdit3('Current target color', buffers.target_color) or changed
        changed = imgui.Checkbox('Variant and Chainbreaker glimmer',
            buffers.rare_glimmer) or changed
        if buffers.rare_glimmer[1] then
            changed = imgui.SliderFloat('Glimmer intensity', buffers.glimmer_intensity,
                0.2, 1.5, '%.2f') or changed
        end
        imgui.TextColored({ 0.65, 0.65, 0.65, 1.0 },
            'These are fixed screen sizes and do not change with distance.')
        changed = imgui.Checkbox('Automatic model-top placement', buffers.auto_model_bounds) or changed
        changed = imgui.SliderFloat('Gap above model', buffers.label_gap, -1, 5, '%.2f yalms') or changed
        changed = imgui.SliderFloat('Fallback model height', buffers.fallback_model_height,
            0.5, 10, '%.1f yalms') or changed
        changed = imgui.SliderInt('Outline width', buffers.outline_width, 0, 2, '%d px') or changed

        imgui.Separator()
        changed = imgui.SliderFloat('Maximum distance', buffers.max_distance,
            25, 100, '%.0f yalms') or changed
        changed = imgui.Checkbox('Prevent overlapping nameplates', buffers.avoid_overlaps) or changed
        if buffers.avoid_overlaps[1] then
            changed = imgui.SliderFloat('Overlap spacing', buffers.overlap_spacing,
                0, 12, '%.0f px') or changed
            changed = imgui.SliderFloat('Maximum overlap shift', buffers.overlap_max_shift,
                20, 240, '%.0f px') or changed
            imgui.TextColored({ 0.65, 0.65, 0.65, 1.0 },
                'Targeted, engaged, party-claimed, and nearby mobs take priority.')
        end

        imgui.Separator()
        changed = imgui.Checkbox('Mobs', buffers.show_mobs) or changed
        changed = imgui.Checkbox('NPCs', buffers.show_npcs) or changed
        changed = imgui.Checkbox('Other players (addon labels)', buffers.show_players) or changed
        changed = imgui.Checkbox('Show distance', buffers.show_distance) or changed

        imgui.Separator()
        changed = imgui.Checkbox('Show exact mob levels', buffers.show_levels) or changed
        changed = imgui.Checkbox('Color levels by relative difficulty',
            buffers.difficulty_coloring) or changed
        if buffers.difficulty_coloring[1]
            and imgui.CollapsingHeader('Difficulty colors') then
            for _, color in ipairs(configurable_colors) do
                if color.key:sub(1, 11) == 'difficulty_' then
                    changed = imgui.ColorEdit3(
                        color.label, buffers[color.key .. '_color']) or changed
                end
            end
        end

        if imgui.CollapsingHeader('Claim and engagement colors') then
            for _, color in ipairs(configurable_colors) do
                if color.key:sub(1, 4) == 'mob_' then
                    changed = imgui.ColorEdit3(
                        color.label, buffers[color.key .. '_color']) or changed
                end
            end
            imgui.TextColored({ 0.65, 0.65, 0.65, 1.0 },
                'Party-engaged overrides party-claimed; current target overrides both.')
        end

        changed = imgui.Checkbox('Show mob HP bars', buffers.show_hp_bars) or changed
        changed = imgui.Checkbox('Show HP percentage', buffers.show_hp_percent) or changed
        if buffers.show_hp_bars[1] or buffers.show_hp_percent[1] then
            imgui.Text('Show HP when any enabled condition matches:')
            changed = imgui.Checkbox('Targeted##hpcondition',
                buffers.hp_show_when_targeted) or changed
            changed = imgui.Checkbox('Damaged##hpcondition',
                buffers.hp_show_when_damaged) or changed
            changed = imgui.Checkbox('Engaged##hpcondition',
                buffers.hp_show_when_engaged) or changed
            imgui.TextColored({ 0.65, 0.65, 0.65, 1.0 },
                'With all three disabled, HP is always shown within its distance limit.')
        end
        if buffers.show_hp_percent[1] then
            changed = imgui.SliderFloat('HP% font size', buffers.hp_percent_font_size,
                8, 24, '%.0f px') or changed
            changed = imgui.SliderFloat('HP% maximum distance',
                buffers.hp_percent_max_distance, 0, 100, '%.0f yalms') or changed
        end
        if buffers.show_hp_bars[1] then
            changed = imgui.SliderFloat('HP bar width', buffers.hp_bar_width,
                40, 180, '%.0f px') or changed
            changed = imgui.SliderFloat('HP bar height', buffers.hp_bar_height,
                4, 14, '%.0f px') or changed
            changed = imgui.SliderFloat('HP bar maximum distance',
                buffers.hp_bar_max_distance, 0, 100, '%.0f yalms') or changed
        end

        if imgui.CollapsingHeader('Current target HP styling') then
            changed = imgui.SliderFloat('Target HP% font size',
                buffers.target_hp_percent_font_size, 8, 30, '%.0f px') or changed
            changed = imgui.SliderFloat('Target HP bar width',
                buffers.target_hp_bar_width, 40, 240, '%.0f px') or changed
            changed = imgui.SliderFloat('Target HP bar height',
                buffers.target_hp_bar_height, 4, 20, '%.0f px') or changed
            changed = imgui.ColorEdit3('Target HP bar color',
                buffers.target_hp_bar_color) or changed
            imgui.TextColored({ 0.65, 0.65, 0.65, 1.0 },
                'The current target color above is also used for its HP percentage.')
        end

        if changed then
            apply_buffers()
            sync_buffers()
        end

        imgui.Separator()
        imgui.Text(('Tracking %d rendered entities.'):format(#state.entities))
        imgui.TextColored({ 0.65, 0.65, 0.65, 1.0 },
            'Mob levels refresh from the server widescan list.')
        imgui.TextColored({ 0.65, 0.65, 0.65, 1.0 }, 'Use /snp help for command controls.')
    end
    imgui.End()
end

local function print_help()
    message('Commands:')
    message('/snp - open or close settings')
    message('/snp on | off')
    message('/snp size <10-36>')
    message('/snp targetsize <10-42>')
    message('/snp closesize <10-42> - font size within 5 yalms')
    message('/snp max <25-100>')
    message('/snp height <-1 to 5> - gap above the model')
    message('/snp autobounds <on|off>')
    message('/snp native <off|on|players>')
    message('/snp font <name> | hptextsize <8-24>')
    message('/snp glimmer <on|off> | glimmerstrength <0.2-1.5>')
    message('/snp targetcolor <red> <green> <blue> - values from 0 to 255')
    message('/snp mobs | npcs | players | levels | hp | hppercent <on|off>')
    message('/snp overlap | difficulty | hptargeted | hpdamaged | hpengaged <on|off>')
    message('/snp status | save | reset')
end

local function parse_toggle(value)
    if value == nil then
        return nil
    end
    value = value:lower()
    if value:any('on', 'true', 'yes', '1', 'show') then
        return true
    end
    if value:any('off', 'false', 'no', '0', 'hide') then
        return false
    end
    return nil
end

settings.register('settings', 'sanctumnameplates_settings', function(new_config)
    if new_config ~= nil then
        config = new_config
        normalize_config()
        sync_buffers()
        state.model_bounds = {}
        state.last_scan = -100
        sync_native_name_visibility()
    end
end)

ashita.events.register('load', 'sanctumnameplates_load', function()
    load_nameplate_fonts()
    normalize_config()
    if config.font_face ~= 'default' and state.fonts[config.font_face] == nil then
        config.font_face = 'default'
    end
    sync_buffers()
    sync_native_name_visibility()
    settings.save()
    success('Loaded. Overlap control, claim colors, difficulty colors, and HP rules active.')
end)

ashita.events.register('unload', 'sanctumnameplates_unload', function()
    set_native_name_mode(config.native_restore_mode)
    pcall(settings.save)
end)

ashita.events.register('packet_in', 'sanctumnameplates_zone', function(event)
    if event.id == 0x00B then
        state.zoning = true
        state.entities = {}
        state.mob_levels = {}
        state.model_bounds = {}
        state.last_level_response = -100
    elseif event.id == 0x00A then
        state.zoning = false
        state.last_scan = -100
        state.last_level_request = -100
    elseif event.id == 0x0F4 then
        ingest_widescan_level(event)
    end
end)

ashita.events.register('command', 'sanctumnameplates_command', function(event)
    local args = event.command:args()
    if #args == 0 or not args[1]:any('/snp', '/sanctumnameplates') then
        return
    end

    event.blocked = true
    local command = (#args >= 2) and args[2]:lower() or 'toggle'

    if command == 'toggle' then
        state.ui_open[1] = not state.ui_open[1]
        return
    end
    if command:any('help', '?') then
        print_help()
        return
    end
    if command:any('on', 'show') then
        config.enabled = true
        mark_dirty()
        sync_buffers()
        sync_native_name_visibility()
        success('Enabled.')
        return
    end
    if command:any('off', 'hide') then
        config.enabled = false
        mark_dirty()
        sync_buffers()
        sync_native_name_visibility()
        message('Disabled.')
        return
    end
    if command == 'save' then
        normalize_config()
        settings.save()
        success('Settings saved.')
        return
    end
    if command == 'reset' then
        settings.reset()
        settings.save()
        success('Settings reset.')
        return
    end
    if command == 'status' then
        message(('enabled=%s native=%s font=%s size=%.0fpx target=%.0fpx close=%.0fpx hptext=%.0fpx max=%.0fy gap=%.2fy bounds=%s entities=%d')
            :format(tostring(config.enabled), config.native_name_mode,
                config.font_face, config.font_size, config.target_font_size,
                config.close_font_size, config.hp_percent_font_size,
                config.max_distance, config.label_gap,
                tostring(config.auto_model_bounds), #state.entities))
        return
    end

    if command == 'native' and #args >= 3 then
        local requested = args[3]:lower()
        local mode = nil
        if requested:any('off', 'hide', 'hidden', 'none') then
            mode = 'none'
        elseif requested:any('player', 'players', 'pc') then
            mode = 'players'
        elseif requested:any('on', 'show', 'all') then
            mode = 'all'
        end
        if mode ~= nil then
            config.native_name_mode = mode
            mark_dirty()
            sync_buffers()
            sync_native_name_visibility()
            success(('Original nameplates set to %s.'):format(mode))
            return
        end
    end

    if command == 'font' and #args >= 3 then
        local requested = args[3]:lower()
        for _, name in ipairs(state.font_names) do
            if requested == name then
                config.font_face = name
                mark_dirty()
                sync_buffers()
                success(('Nameplate font set to %s.'):format(name))
                return
            end
        end
    end

    if command == 'targetcolor' and #args >= 5 then
        local red = tonumber(args[3])
        local green = tonumber(args[4])
        local blue = tonumber(args[5])
        if red ~= nil and green ~= nil and blue ~= nil then
            config.target_color_r = clamp(red, 0, 255) / 255
            config.target_color_g = clamp(green, 0, 255) / 255
            config.target_color_b = clamp(blue, 0, 255) / 255
            mark_dirty()
            sync_buffers()
            success('Current target color updated.')
            return
        end
    end

    local numeric_commands = {
        size = { key = 'font_size', minimum = 10, maximum = 36, suffix = 'px' },
        targetsize = { key = 'target_font_size', minimum = 10, maximum = 42, suffix = 'px' },
        closesize = { key = 'close_font_size', minimum = 10, maximum = 42, suffix = 'px' },
        hptextsize = { key = 'hp_percent_font_size', minimum = 8, maximum = 24, suffix = 'px' },
        glimmerstrength = { key = 'glimmer_intensity', minimum = 0.2, maximum = 1.5, suffix = '' },
        max = { key = 'max_distance', minimum = 25, maximum = 100, suffix = ' yalms' },
        height = { key = 'label_gap', minimum = -1, maximum = 5, suffix = ' yalms' },
    }
    local numeric = numeric_commands[command]
    if numeric ~= nil and #args >= 3 then
        local value = tonumber(args[3])
        if value ~= nil then
            config[numeric.key] = clamp(value, numeric.minimum, numeric.maximum)
            mark_dirty()
            sync_buffers()
            success(('%s set to %.1f%s.'):format(command, config[numeric.key], numeric.suffix))
            return
        end
    end

    local toggles = {
        mobs = 'show_mobs',
        npcs = 'show_npcs',
        players = 'show_players',
        distances = 'show_distance',
        levels = 'show_levels',
        hp = 'show_hp_bars',
        hppercent = 'show_hp_percent',
        hptargeted = 'hp_show_when_targeted',
        hpdamaged = 'hp_show_when_damaged',
        hpengaged = 'hp_show_when_engaged',
        difficulty = 'difficulty_coloring',
        overlap = 'avoid_overlaps',
        glimmer = 'rare_glimmer',
        autobounds = 'auto_model_bounds',
    }
    local toggle_key = toggles[command]
    if toggle_key ~= nil and #args >= 3 then
        local value = parse_toggle(args[3])
        if value ~= nil then
            config[toggle_key] = value
            mark_dirty()
            sync_buffers()
            sync_native_name_visibility()
            success(('%s %s.'):format(command, value and 'enabled' or 'disabled'))
            return
        end
    end

    report_error('Invalid command. Use /snp help.')
end)

ashita.events.register('d3d_present', 'sanctumnameplates_present', function()
    if state.dirty then
        state.dirty = false
        settings.save()
    end

    draw_config()

    if state.zoning or config.enabled == false then
        return
    end

    local level_ok, level_err = pcall(request_level_scan)
    if not level_ok then
        report_error('Level refresh failed: ' .. tostring(level_err))
    end

    local now = os.clock()
    if now - state.last_scan >= config.scan_interval then
        state.last_scan = now
        local ok, err = pcall(scan_entities)
        if not ok then
            report_error('Entity scan failed: ' .. tostring(err))
        end
    end
end)

ashita.events.register('d3d_endscene', 'sanctumnameplates_endscene', function(is_rendering_back_buffer)
    if not is_rendering_back_buffer or state.zoning or config.enabled == false then
        return
    end

    local ok, err = pcall(function()
        local device = d3d8.get_device()
        if device == nil then
            return
        end

        local _, view = device:GetTransform(2)
        local _, projection = device:GetTransform(3)
        local _, viewport = device:GetViewport()
        if view == nil or projection == nil or viewport == nil then
            return
        end

        local labels = collect_labels(view, projection, viewport)
        local rendered, render_error = depth_renderer.render(
            device, labels, viewport, get_nameplate_font(), config, os.clock())
        if not rendered then
            error(render_error)
        end
    end)
    if not ok then
        report_error('Rendering failed: ' .. tostring(err))
    end
end)
