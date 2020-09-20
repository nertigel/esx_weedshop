---------------------------------------
--     ESX_WEEDSHOP by Dividerz      --
-- FOR SUPPORT: Arne#7777 on Discord --
---------------------------------------

Config = {}

Config.usingWeight = true
Config.WeedItem = 'weed'
Config.WeedPrice = 5
Config.JointPrice = 50
Config.JobName = 'coffeeshop'
Config.ShopName = 'Coffee Shop'

Config.JointRollingTime = 5000
Config.WeedSellTime = 15000

Config.Weedshop = {
    job = {
        StorageCheck = vector3(380.33, -814.13, 29.30),
        CreateJoint = vector3(375.55, -824.19, 29.30),
        Register = vector3(380.15, -827.43, 29.30)
    },
    player = {
        SellLocation = vector3(372.43, -827.10, 29.29),
        Counter = vector3(377.98, -828.08, 29.30)
    },
    blip = vector3(377.44, -832.81, 29.32)
}
