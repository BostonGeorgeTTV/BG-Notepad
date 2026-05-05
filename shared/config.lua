Config = Config or {}

-- Item name used by every supported inventory/framework.
Config.Item = 'notepad'

-- Framework options: 'auto', 'esx', 'qbcore', 'qbox', 'standalone'
Config.Framework = 'auto'

-- Inventory options: 'auto', 'ox_inventory', 'qb_inventory', 'framework'
-- auto will prefer ox_inventory, then qb/lj/ps inventory, then the framework add-item function.
Config.Inventory = 'auto'

-- When true the script tries to register the item as usable on ESX, QBCore and qbox.
-- For ox_inventory you can still use the client export shown in the README.
Config.RegisterUsableItem = true

Config.defaultTitle = 'NOMESERVER'

-- Useful while installing on a new framework.
Config.Debug = false