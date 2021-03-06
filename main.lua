require("piber20helper.lua")
local BatteryMod = RegisterMod("BatteryMod", 1)
local game = Game()
local sound = SFXManager()

local json = require("json")

local COSTUME_ENERGIZED = Isaac.GetCostumeIdByPath("gfx/characters/EnergizedCostume.anm2")
local COLLECTIBLE_RUSTY_BATTERY = Isaac.GetItemIdByName("Rusty Battery")

local transformItems = { 
	647, --4.5 volt
	603, --Battery pack
	116, --9 Volt
	63,  --The Battery
	356, --Car Battery
	372, --Charged Baby
	520 --Jumper Cables
}

function BatteryMod:onUpdate()
	for i = 1, game:GetNumPlayers() do
		local currplayer = game:GetPlayer(i)
			currplayer:GetData().pNum = i
			
	end		
	--Start of game
	--[[if game:GetFrameCount() == 1 then
		--print("New run started")
		
	]]--end

end

local GameState = {}

function BatteryMod:onStart(continuedRun)
	if BatteryMod:HasData() then
		GameState = json.decode(BatteryMod:LoadData() )
	end
	if GameState.Transformed == nil or continuedRun == false then GameState.Transformed = {0,0,0,0,0,0,0,0} end
	if GameState.TransformProgress == nil or continuedRun == false then GameState.TransformProgress = {0,0,0,0,0,0,0,0} end
end

function BatteryMod.onGameExit() 
	BatteryMod:SaveData(json.encode(GameState))
end
-- Check for transformations every second or so
function BatteryMod:onPlayerUpdate(player)
	local pNum = 1
	
	if not (player:GetData().pNum == nil) then 
		pNum = player:GetData().pNum
	end
	
	--Check transformation for each player
	if game:GetFrameCount() % 30 == 1 and GameState.TransformProgress ~= nil then
			BatteryMod:CheckTransformations(player, pNum)	
	end
	
	if not(GameState.Transformed == nil) and GameState.Transformed[pNum] == 1  then
		--Transform hearts into batteries
		for i, pickup in pairs(Isaac.FindInRadius(player.Position, 45, EntityPartition.PICKUP)) do
			pickup = pickup:ToPickup()
			if pickup.Variant == PickupVariant.PICKUP_HEART and pickup:GetData().EnergizedTF == nil  then		
				pickup:GetData().EnergizedTF = true
				--Replace half heart
				if pickup.SubType == HeartSubType.HEART_HALF then
					pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MICRO, true, true, false)
				--Replace full heart
				elseif pickup.SubType == HeartSubType.HEART_FULL then
					pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MICRO, true, true, false)
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MICRO, pickup.Position, Vector(0.25,-0.25), nil)
				--Replace double heart
				elseif pickup.SubType == HeartSubType.HEART_DOUBLEPACK then
					pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MICRO, true, true, false)
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MICRO, pickup.Position, Vector(0.25,-0.25), nil)
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MICRO, pickup.Position, Vector(0.25,-0.25), nil)
				end
			end
		end
	
				
		--Heal on battery pickup
		for i, ent in pairs(Isaac.FindInRadius(player.Position, 10, EntityPartition.PICKUP)) do
			--print("Check P" .. pNum .. " Transformed = " .. GameState.Transformed[pNum])
			if  ent:GetData().Picked == nil and ent.Variant == PickupVariant.PICKUP_LIL_BATTERY and GameState.Transformed[pNum] == 1 then
				if not ent:GetSprite():IsPlaying("Collect") and not player:HasFullHearts() and (not player:NeedsCharge(0) and not player:NeedsCharge(1) and not player:NeedsCharge(2) ) then
					ent:GetSprite():Play("Collect", true)
					ent:Die()
					sound:Play(SoundEffect.SOUND_BEEP)
				end
				if ent:GetSprite():IsPlaying("Collect") then
					ent:GetData().Picked = true
					if ent.SubType == BatterySubType.BATTERY_MICRO then
						player:AddHearts(1)
					else 
						player:AddHearts(2)	
					end				
				end

				
			end	
		end
	
	
end

end

function BatteryMod:CheckTransformations(player, pNum)
	--Reset Transformation Status
	GameState.TransformProgress[pNum] = 0
	for k in pairs(transformItems)  do
		local curItemCount = player:GetCollectibleNum(transformItems[k], IgnoreModifiers)
		if curItemCount > 0 then
			--print("Current item: " .. transformItems[k] ..", has " .. player:GetCollectibleNum(transformItems[k], IgnoreModifiers))
			GameState.TransformProgress[pNum] = GameState.TransformProgress[pNum] + curItemCount
		end
	end
	--Activate transformation
	if GameState.TransformProgress[pNum] >= 3 and GameState.Transformed[pNum] == 0 then
		--print("P" .. pNum .. " has transformed!")
		GameState.Transformed[pNum] = 1
		sound:Play(SoundEffect.SOUND_POWERUP_SPEWER)
		piber20HelperMod:doStreak("Energized!")
		player:AddNullCostume(COSTUME_ENERGIZED)
		--Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, COLLECTIBLE_RUSTY_BATTERY, player.Position, Vector(0,0), nil) --Spawn Rusty battery item
	--Take away transformation if player rerolls out of it or loses the items
	elseif GameState.TransformProgress[pNum] < 3 and GameState.Transformed[pNum] == 1 then
		--print("P" .. pNum .. " has untransformed :(")
		GameState.Transformed[pNum] = 0
		player:TryRemoveNullCostume(COSTUME_ENERGIZED)
	end
	--print("Transform progress" .. GameState.TransformProgress[1])
end

--Rusty Battery Item Code
function BatteryMod:onRustyBatteryUse(item, rng, player, useFlags, slot, customData)
	local rngRoll = rng:RandomInt(100)
	if rngRoll <= 25 then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MICRO, player.Position, Vector(-10 + rng:RandomInt(20),-10 + rng:RandomInt(20)), nil)
	end
	
	return true
	
end

--External Item Desc Support
if EID then
	EID:addCollectible(COLLECTIBLE_RUSTY_BATTERY, "Has a small chance to drop a micro battery when used. #If you are Energized! and don't have an active item, then you should carry this around")
	local dummySprite = Sprite()
	dummySprite:Load("gfx/eid_inline_icons.anm2", true)
	EID:addIcon("Edin_Energized!", "pickups", 9, 8, 11, -1, 0, dummySprite)	
	EID:createTransformation("Edin_Energized!", "Energized!") -- Transformation
	--Add Transformation to all items
	for k in pairs(transformItems)  do
		EID:assignTransformation("collectible", transformItems[k], "Edin_Energized!") 
	end	
end




BatteryMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, BatteryMod.onStart)
BatteryMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, BatteryMod.onPlayerUpdate)
BatteryMod:AddCallback(ModCallbacks.MC_POST_UPDATE, BatteryMod.onUpdate)
BatteryMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, BatteryMod.onGameExit)
BatteryMod:AddCallback(ModCallbacks.MC_USE_ITEM, BatteryMod.onRustyBatteryUse, COLLECTIBLE_RUSTY_BATTERY)