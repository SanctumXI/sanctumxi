--[[
* SanctumSize - Client-side size increases and decreases for all sorts of NMs and foes!
--]]

if rawget(_G, 'ashita') == nil then
    return {}
end

addon.name    = 'SanctumSize';
addon.author  = 'Steel';
addon.version = '1.3';
addon.desc    = 'Renders configured NMs and Chainbreakers at a fixed visual scale on this client.';
addon.link    = '';

require('common');

local chat = require('chat');

local scaled_mobs = {
	-------------------------------------------
    -- 200%
	-------------------------------------------
    ['Anansi'] = 2.0,
    ['Bomb King'] = 2.0,
    ['Kirin'] = 2.0,
    ['Orctrap'] = 2.0,
    ['Queen Jelly'] = 2.0,
    ['Serra'] = 2.0,
    ['Tarasque'] = 2.0,
	-------------------------------------------
    -- 150%
	-------------------------------------------
    ['Aquarius'] = 1.5,
    ['Argus'] = 1.5,
    ['Beelzebub'] = 1.5,
    ['Bloodpool Vorax'] = 1.5,
    ['Bomb Queen'] = 1.5,
    ['Buburimboo'] = 1.5,
    ['Charybdis'] = 1.5,
    ['Demonic Tiphia'] = 1.5,
    ['Flayer Franz'] = 1.5,
    ['Gargantua'] = 1.5,
    ['Giant Moa'] = 1.5,
    ['Hercules Beetle'] = 1.5,
    ['King Arthro'] = 1.5,
    ['King Behemoth'] = 1.5,
    ['Leech King'] = 1.5,
    ['Orcish Panzer'] = 1.5,
    ['Panzer Percival'] = 1.5,
    ['Sea Horror'] = 1.5,
	-------------------------------------------
    -- 120%
	-------------------------------------------
    ['Amanita'] = 1.2,
    ['Arachne'] = 1.2,
    ['Aries'] = 1.2,
    ['Awd Goggie'] = 1.2,
    ['Bedrock Barry'] = 1.2,
    ['Bigmouth Billy'] = 1.2,
    ['Bitoso'] = 1.2,
    ['Byakko'] = 1.2,
    ['Carnero'] = 1.2,
    ['Chocoboleech'] = 1.2,
    ['Colo-colo'] = 1.2,
    ['Count Bifrons'] = 1.2,
    ['Deadly Dodo'] = 1.2,
    ['Doll Factory'] = 1.2,
    ['Duke Decapod'] = 1.2,
    ['Dynast Beetle'] = 1.2,
    ['Evil Oscar'] = 1.2,
    ['Fe\'e'] = 1.2,
    ['Flauros'] = 1.2,
    ['Fungus Beetle'] = 1.2,
    ['Genbu'] = 1.2,
    ['Gerjis'] = 1.2,
    ['Goliath'] = 1.2,
    ['Guivre'] = 1.2,
    ['Haty'] = 1.2,
    ['Heavy Metal Crab'] = 1.2,
    ['Ixion'] = 1.2,
    ['Hellion'] = 1.2,
    ['Kalamainu'] = 1.2,
    ['Keeper of Halidom'] = 1.2,
    ['Kilioa'] = 1.2,
    ['Kirata'] = 1.2,
    ['Leaping Lizzy'] = 1.2,
    ['Lord of Onzozo'] = 1.2,
    ['Macan Gadangan'] = 1.2,
    ['Morbolger'] = 1.2,
    ['Morion Worm'] = 1.2,
    ['Narasimha'] = 1.2,
    ['Noble Mold'] = 1.2,
    ['Nue'] = 1.2,
    ['Oni Carcass'] = 1.2,
    ['Phoedme'] = 1.2,
    ['Queen Crawler'] = 1.2,
    ['Shen'] = 1.2,
    ['Sobbing Eyes'] = 1.2,
    ['Spiny Spipi'] = 1.2,
    ['Stinging Sophie'] = 1.2,
    ['Suzaku'] = 1.2,
    ['Swamfisk'] = 1.2,
    ['Tartaruga Gigante'] = 1.2,
    ['Tococo'] = 1.2,
    ['Tom Tit Tat'] = 1.2,
    ['Tumbling Truffle'] = 1.2,
    ['Valkurm Emperor'] = 1.2,
    ['Waraxe Beak'] = 1.2,
	-------------------------------------------
    -- 110%
	-------------------------------------------
    ['Ambusher Antlion'] = 1.1,
    ['Aspidochelone'] = 1.1,
    ['Backoo'] = 1.1,
    ['Behemoth'] = 1.1,
    ['Bloodtear Baldurf'] = 1.1,
    ['Bugbear Strongman'] = 1.1,
    ['Cactuar Cantautor'] = 1.1,
    ['Celphie'] = 1.1,
    ['Chonchon'] = 1.1,
    ['Daggerclaw Dracos'] = 1.1,
    ['Drooling Daisy'] = 1.1,
    ['Dune Widow'] = 1.1,
    ['Dvorovoi'] = 1.1,
    ['Fafnir'] = 1.1,
    ['Helldiver'] = 1.1,
    ['Huntfly'] = 1.1,
    ['Intulo'] = 1.1,
    ['Jolly Green'] = 1.1,
    ['La Velue'] = 1.1,
    ['Metsanneitsyt'] = 1.1,
    ['Nenaunir'] = 1.1,
    ['Nussknacker'] = 1.1,
    ['Old Two-Wings'] = 1.1,
    ['Opo-opo Monarch'] = 1.1,
    ['Orcish Warlord'] = 1.1,
    ['Pepper'] = 1.1,
    ['Porphyrion'] = 1.1,
    ['Roc'] = 1.1,
    ['Rose Garden'] = 1.1,
    ['Sea Hog'] = 1.1,
    ['Seiryu'] = 1.1,
    ['Serket'] = 1.1,
    ['Simurgh'] = 1.1,
    ['Steelfleece Baldarich'] = 1.1,
};

local hitbox_baseline = {};

local chainbreaker_scale = 1.25;

local scan_interval = 1.0; -- seconds between scans
local last_scan = 0;

local function apply_scale(index, ent, scale)
    local entMgr = AshitaCore:GetMemoryManager():GetEntity();

    if (math.abs(ent.ModelSize - scale) > 0.001) then
        entMgr:SetModelSize(index, scale);
    end

    if (hitbox_baseline[ent.ServerId] == nil) then
        hitbox_baseline[ent.ServerId] = ent.ModelHitboxSize;
    end

    local desired_hitbox = hitbox_baseline[ent.ServerId] * scale;
    if (math.abs(ent.ModelHitboxSize - desired_hitbox) > 0.01) then
        entMgr:SetModelHitboxSize(index, desired_hitbox);
    end
end

local function apply_visual_scale(index, ent, scale)
    if (math.abs(ent.ModelSize - scale) > 0.001) then
        AshitaCore:GetMemoryManager():GetEntity():SetModelSize(index, scale);
    end
end

ashita.events.register('load', 'sanctumsize_load_cb', function ()
    local count = 0;
    for _ in pairs(scaled_mobs) do
        count = count + 1;
    end
    print(chat.header(addon.name):append(chat.message('Loaded. Watching for ')):append(chat.color1(6, tostring(count))):append(chat.message(' configured NMs and automatic Chainbreakers.')));
end);

ashita.events.register('d3d_present', 'sanctumsize_present_cb', function ()
    local now = os.clock();
    if (now - last_scan < scan_interval) then
        return;
    end
    last_scan = now;

    local entMgr = AshitaCore:GetMemoryManager():GetEntity();
    local count  = entMgr:GetEntityMapSize();

    for index = 0, count - 1 do
        local ent = GetEntity(index);
        if (ent ~= nil and ent.ServerId ~= 0) then
            local scale = scaled_mobs[ent.Name];
            if (string.sub(ent.Name, 1, 3) == 'CB ') then
                apply_visual_scale(index, ent, chainbreaker_scale);
            elseif (scale ~= nil) then
                apply_scale(index, ent, scale);
            end
        end
    end
end);
