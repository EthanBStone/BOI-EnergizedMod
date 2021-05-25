require("piber20helper.lua")
local BatteryMod = RegisterMod("BatteryMod", 1)
local game = Game()
local sound = SFXManager()

local json = require("json")

local COSTUME_ENERGIZED = Isaac.GetCostumeIdByPath("gfx/characters/EnergizedCostume.anm2")

local transformProgress = {0, 0, 0, 0}
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
	--Start of game
	if game:GetFrameCount() == 1 then
		--print("New run started")
		
	end


end

local GameState = {}
function BatteryMod:onStart()
	GameState = json.decode(BatteryMod:LoadData() )
	if GameState.RoomCount == nil then GameState.RoomCount = 0 end
	if GameState.LevelCount == nil then GameState.LevelCount = 0 end
	if GameState.Transformed == nil then GameState.Transformed = {0,0,0,0} end
	if GameState.Room == nil then GameState.Room = {0} end
end

function BatteryMod.onGameExit() 
	BatteryMod:SaveData(json.encode(GameState))
end
-- Check for transformations every second or so
function BatteryMod:onPlayerUpdate(player)
	local pNum = 1
	--Find the playernum of the current player
	for i = 1, game:GetNumPlayers() do
		if game:GetPlayer(i) == player then
			pNum = i
		end
	end	
	if game:GetFrameCount() % 30 == 1 then
		BatteryMod:CheckTransformations(player, pNum)
		--for i, ent in pairs(Isaac.FindInRadius(player.Position, 50, EntityPartition.PICKUP)) do	
			--print("Entity index = " .. ent.Index)
		--end
	end
	
	for i, ent in pairs(Isaac.FindInRadius(player.Position, 10, EntityPartition.PICKUP)) do
		if ent:GetSprite():IsPlaying("Collect") and ent:GetData().Picked == nil and ent.Variant == PickupVariant.PICKUP_LIL_BATTERY and GameState.Transformed[pNum] == 1 then
			ent:GetData().Picked = true
			
			if ent.SubType == BatterySubType.BATTERY_MICRO then
				player:AddHearts(1)
			else 
				player:AddHearts(2)	
			end
			--print("Entity picked up!")
		end	
	end
	
	
end

function BatteryMod:CheckTransformations(player, pNum)
	--Reset Transformation Status
	transformProgress[pNum] = 0
	for k in pairs(transformItems)  do
		local curItemCount = player:GetCollectibleNum(transformItems[k], IgnoreModifiers)
		if curItemCount > 0 then
			--print("Current item: " .. transformItems[k] ..", has " .. player:GetCollectibleNum(transformItems[k], IgnoreModifiers))
			transformProgress[pNum] = transformProgress[pNum] + curItemCount
		end
	end
	--Activate transformation
	if transformProgress[pNum] >= 3 and GameState.Transformed[pNum] == 0 then
		--print("P" .. pNum .. " has transformed!")
		GameState.Transformed[pNum] = 1
		sound:Play(SoundEffect.SOUND_POWERUP_SPEWER)
		piber20HelperMod:doStreak("Energized!")
		player:AddNullCostume(COSTUME_ENERGIZED)
	--Take away transformation if player rerolls out of it or loses the items
	elseif transformProgress[pNum] < 3 and GameState.Transformed[pNum] == 1 then
		--print("P" .. pNum .. " has untransformed :(")
		GameState.Transformed[pNum] = 0
	end
	--print("Transform progress" .. transformProgress[1])
end

local roomVisitCount = 0
function BatteryMod:onPickupUpdate(pickup)
	if pickup.Variant == PickupVariant.PICKUP_HEART and pickup:GetData().BatteryRolled == nil and roomVisitCount < 2 and (GameState.Transformed[1] == 1 or GameState.Transformed[2] == 1 or GameState.Transformed[3] == 1 or GameState.Transformed[4] == 1) then
		local batteryRNG = pickup:GetDropRNG()
		local rngVal = batteryRNG:RandomInt(100)
		local replaceFlag = false
		if rngVal <= 90 then
			replaceFlag = true
		end
		pickup:GetData().BatteryRolled = true		
		--Replace half heart
		if pickup.SubType == HeartSubType.HEART_HALF and replaceFlag then
			pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MICRO, true, true, false)
		--Replace full heart
		elseif pickup.SubType == HeartSubType.HEART_FULL and replaceFlag then
			pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MICRO, true, true, false)
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MICRO, pickup.Position, Vector(0.25,-0.25), nil)
		--Replace double heart
		elseif pickup.SubType == HeartSubType.HEART_DOUBLEPACK and replaceFlag then
			pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MICRO, true, true, false)
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MICRO, pickup.Position, Vector(0.25,-0.25), nil)
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MICRO, pickup.Position, Vector(0.25,-0.25), nil)
		end
	
	end


end
 
function BatteryMod:onNewRoom()
	roomVisitCount = game:GetLevel():GetCurrentRoomDesc().VisitedCount
	StageRoomCount = 0
	if GameState.Room[1] == nil or GameState.Room[1] == 0 then
		StageRoomCount = 0
	else
		for i, ind in pairs(GameState.Room) do 
			StageRoomCount = StageRoomCount + 1
		end
	end
	local isDupe = false
	for i, ind in pairs(GameState.Room) do
		if(game:GetLevel():GetCurrentRoomDesc().ListIndex) == ind then
			isDupe = true
		end
	
	end
	if not isDupe then
		GameState.Room[StageRoomCount + 1] = game:GetLevel():GetCurrentRoomDesc().ListIndex
		print("New room added " .. game:GetLevel():GetCurrentRoomDesc().ListIndex)
	else
		print("Dupe found, not adding " .. game:GetLevel():GetCurrentRoomDesc().ListIndex)
	end
	
end

function BatteryMod:onNewLevel()
	GameState.Room = {0}
end
BatteryMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, BatteryMod.onStart)
BatteryMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, BatteryMod.onPlayerUpdate)
BatteryMod:AddCallback(ModCallbacks.MC_POST_UPDATE, BatteryMod.onUpdate)
BatteryMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, BatteryMod.onPickupUpdate)
BatteryMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, BatteryMod.onNewRoom)
BatteryMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, BatteryMod.onNewLevel)
BatteryMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, BatteryMod.onGameExit)