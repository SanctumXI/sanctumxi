local zones =
{
    {
        zoneId      = xi.zone.VALKURM_DUNES,
        zoneName    = 'Valkurm_Dunes',
        region      = xi.region.ZULKHEIM,
        cooldownVar = '[Variant]103Cooldown',
        mobs =
        {
            {
                key                = 'thread_leech',
                mobName            = 'Thread_Leech',
                packetName         = 'Thread Leech',
                variantPacketName  = 'V Thread Leech',
                variantDisplayName = 'Variant Thread Leech',
                chainbreaker =
                {
                    name        = 'Valkurm_Leech_King',
                    packetName  = 'CB Leech King', -- The CB prefix activates the client name and size rules.
                    displayName = 'Valkurm Leech King',
                    groupId     = 14,
                    groupZoneId = 274,
                    specialCosmetics =
                    {
                        -- Fixed drop rates use 1000 = 100%.
                        -- { itemId = xi.item.WYRMKING_MASQUE, rate = 100 },
                    },
                },
            },
        },
    },
}

return zones
