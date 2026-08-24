-- Hide and disable every Cavernous Maw, including WotG and Abyssea variants.
UPDATE `npc_list`
SET
    `status` = 3,
    `widescan` = 0
WHERE `polutils_name` = 'Cavernous Maw';
