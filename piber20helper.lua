--the version of this helper mod script
local currentVersion = 12

--remove any previous versions that may exist
local callbacksAlreadyLoaded = nil
if piber20HelperMod then
	local thisVersion = 1
	if piber20HelperMod.Version ~= nil then
		thisVersion = piber20HelperMod.Version
	end
	if thisVersion < currentVersion then
		if piber20HelperMod.AddedCallback then
			callbacksAlreadyLoaded = piber20HelperMod.AddedCallback
		end
		piber20HelperMod = nil
		Isaac.DebugString("Removed older piber20 helper mod (version " .. thisVersion .. ")")
	end
end

if not piber20HelperMod then
	piber20HelperMod = RegisterMod("piber20's helper mod", 1)
	piber20HelperMod.Version = currentVersion
	piber20HelperMod.GameStarted = false
	piber20HelperMod.IsSaveGame = false
	Isaac.DebugString("Loading piber20 helper mod version " .. piber20HelperMod.Version)
	
	piber20HelperMod.AddedCallback = {}
	if callbacksAlreadyLoaded then
		piber20HelperMod.AddedCallback = callbacksAlreadyLoaded
	end
	
	----------------
	--Custom Enums--
	----------------
	piber20HelperCostumeType = {
		COLLECTIBLE = 0,
		TRINKET = 1,
		NULL = 2
	}
	piber20HelperOtherModCardType = {
		CARD_THREE_OF_WANDS = -1,
		CARD_MENDING_SALVE = -1,
		CARD_ELECTRIC_BOLT = -1,
		CARD_DIM_RITUAL = -1,
		CARD_TURN_TO_TOAD = -1,
		RUNE_NAUDIZ = -1,
		RUNE_GEBO = -1,
		RUNE_FEHU = -1,
		RUNE_SOWILO = -1
	}
	piber20HelperMod.CheckedForModContent = false
	function piber20HelperMod:checkForModContent()
		if not piber20HelperMod.CheckedForModContent then
			if not piber20HelperMod.GameStarted then
				--three of wands
				piber20HelperOtherModCardType.CARD_THREE_OF_WANDS = Isaac.GetCardIdByName("threeofwands")
				
				--sorcery the assembling
				piber20HelperOtherModCardType.CARD_MENDING_SALVE = Isaac.GetCardIdByName("MendingSalve")
				piber20HelperOtherModCardType.CARD_ELECTRIC_BOLT = Isaac.GetCardIdByName("ElectricBolt")
				piber20HelperOtherModCardType.CARD_DIM_RITUAL = Isaac.GetCardIdByName("DimRitual")
				
				--turn to toad
				piber20HelperOtherModCardType.CARD_TURN_TO_TOAD = Isaac.GetCardIdByName("c01_TurnToToad")
				
				--alphabirth pack 2
				piber20HelperOtherModCardType.RUNE_NAUDIZ = Isaac.GetCardIdByName("Naudiz")
				piber20HelperOtherModCardType.RUNE_GEBO = Isaac.GetCardIdByName("Gebo")
				piber20HelperOtherModCardType.RUNE_FEHU = Isaac.GetCardIdByName("Fehu")
				piber20HelperOtherModCardType.RUNE_SOWILO = Isaac.GetCardIdByName("Sowilo")
				
				piber20HelperMod.CheckedForModContent = true
			end
		end
	end
	
	-------------
	--RNG Stuff--
	-------------
	function piber20HelperMod:initializeRNG(rng)
		if rng ~= nil then
			local seed = Random()
			if piber20HelperMod.GameStarted then
				seed = Game():GetSeeds():GetStartSeed()
			end
			rng:SetSeed(seed, 1)
			return rng
		end
	end
	function piber20HelperMod:getInitializedRNG()
		local rng = RNG()
		return piber20HelperMod:initializeRNG(rng)
	end
	local newRNG = piber20HelperMod:getInitializedRNG()
	
	function piber20HelperMod:resetRNGSeed(rng)
		if rng ~= nil then
			local seed = Random()
			if piber20HelperMod.GameStarted then
				seed = Game():GetSeeds():GetStartSeed()
			end
			rng:SetSeed(seed, 1)
		end
	end
	
	function piber20HelperMod:getRNGNext(rng)
		if rng == nil then
			rng = newRNG
		end
		num = rng:Next()
		return num
	end
	
	function piber20HelperMod:getRandomNumber(min, max, rng)
		if rng == nil then
			rng = newRNG
		end
		local seed = tonumber(rng)
		if seed then
			rng = RNG()
			rng:SetSeed(seed, 1)
		end
		local num = nil
		if min ~= nil and max ~= nil then
			num = math.floor(rng:RandomFloat() * (max - min + 1) + min)
		elseif min ~= nil then
			num = math.floor(rng:RandomFloat() * (min + 1))
		else
			num = rng:RandomFloat()
		end
		return num
	end
	
	------------------
	--Game Functions--
	------------------
	function piber20HelperMod:isHardMode()
		local difficulty = Game().Difficulty
		if difficulty == Difficulty.DIFFICULTY_HARD or difficulty == Difficulty.DIFFICULTY_GREEDIER then
			return true
		end
		return false
	end
	
	
	------------
	--Entities--
	------------
	function piber20HelperMod:getData(entity)
		local data = entity:GetData()
		if data.piber20Helper == nil then
			data.piber20Helper = {}
		end
		return data.piber20Helper
	end

	function piber20HelperMod:replaceEntity(entity, type, variant, subType, onFirstFrame)
		if entity:Exists() then
			if subType == nil then
				subType = 0
			end
			if entity.FrameCount <= 1 or not onFirstFrame then
				local position = entity.Position
				local velocity = entity.Velocity
				local spawner = entity.SpawnerEntity
				local flags = entity:GetEntityFlags()
				entity:Remove()
				
				local newEntity = Game():Spawn(type, variant, position, velocity, spawner, subType, piber20HelperMod:getRNGNext())
				newEntity:AddEntityFlags(flags)
				
				return newEntity
			end
		end
	end
	
	-----------------
	--CurrentPlayer--
	-----------------
	--gets currentPlayer from a player entity
	function piber20HelperMod:getCurrentPlayer(player)
		local currentPlayer = 1
		for i = 1, Game():GetNumPlayers() do
			local searchPlayer = i
			local otherPlayer = Isaac.GetPlayer(searchPlayer - 1)
			
			if otherPlayer.ControllerIndex == player.ControllerIndex then
				currentPlayer = searchPlayer
			end
		end
		
		return currentPlayer
	end
	
	--gets the player entity from currentPlayer
	function piber20HelperMod:getCurrentPlayerEntity(currentPlayer)
		local player = Isaac.GetPlayer(0)
		for i = 1, Game():GetNumPlayers() do
			local searchPlayer = i
			local otherPlayer = Isaac.GetPlayer(searchPlayer - 1)
			
			if searchPlayer == piber20HelperMod:getCurrentPlayer(player) then
				player = otherPlayer
			end
		end
		
		return player
	end
	
	--------------
	--Item Pools--
	--------------
	--returns the item pool of the current room
	local getCurrentItemPoolRNG = piber20HelperMod:getInitializedRNG()
	function piber20HelperMod:getCurrentItemPool()
		local roomType = Game():GetRoom():GetType()
		local itemPool = Game():GetItemPool():GetPoolForRoom(roomType, getCurrentItemPoolRNG:Next())
		return itemPool
	end
	
	--returns a random collectible based on the room's item pool
	local getRandomCollectibleRNG = piber20HelperMod:getInitializedRNG()
	function piber20HelperMod:getRandomCollectible(pool, decrease)
		if pool == nil then
			pool = piber20HelperMod:getCurrentItemPool()
		end
		if decrease == nil then
			decrease = true
		end
		local collectible = Game():GetItemPool():GetCollectible(pool, decrease, getCurrentItemPoolRNG:Next())
		return collectible
	end
	
	--returns a random trinket
	function piber20HelperMod:getRandomTrinket()
		local trinket = Game():GetItemPool():GetTrinket()
		return trinket
	end
	
	--returns a random card
	local getRandomCardRNG = piber20HelperMod:getInitializedRNG()
	function piber20HelperMod:getRandomCard(allowPlayingCards, allowRunes, onlyRunes)
		if allowPlayingCards == nil then
			allowPlayingCards = true
		end
		if allowRunes == nil then
			allowRunes = true
		end
		if onlyRunes == nil then
			onlyRunes = false
		end
		local card = Game():GetItemPool():GetCard(getRandomCardRNG:Next(), allowPlayingCards, allowRunes, onlyRunes)
		return card
	end
	
	--returns a random pill
	local getRandomPillRNG = piber20HelperMod:getInitializedRNG()
	function piber20HelperMod:getRandomPill()
		local pill = Game():GetItemPool():GetPill(getRandomPillRNG:Next())
		return pill
	end

	------------------
	--Card Functions--
	------------------
	--returns true if the card is a tarot card
	function piber20HelperMod:isTarotCard(card)
		if card == Card.CARD_FOOL then
			return true
		elseif card == Card.CARD_MAGICIAN then
			return true
		elseif card == Card.CARD_HIGH_PRIESTESS then
			return true
		elseif card == Card.CARD_EMPRESS then
			return true
		elseif card == Card.CARD_EMPEROR then
			return true
		elseif card == Card.CARD_HIEROPHANT then
			return true
		elseif card == Card.CARD_LOVERS then
			return true
		elseif card == Card.CARD_CHARIOT then
			return true
		elseif card == Card.CARD_JUSTICE then
			return true
		elseif card == Card.CARD_HERMIT then
			return true
		elseif card == Card.CARD_WHEEL_OF_FORTUNE then
			return true
		elseif card == Card.CARD_STRENGTH then
			return true
		elseif card == Card.CARD_HANGED_MAN then
			return true
		elseif card == Card.CARD_DEATH then
			return true
		elseif card == Card.CARD_TEMPERANCE then
			return true
		elseif card == Card.CARD_DEVIL then
			return true
		elseif card == Card.CARD_TOWER then
			return true
		elseif card == Card.CARD_STARS then
			return true
		elseif card == Card.CARD_MOON then
			return true
		elseif card == Card.CARD_SUN then
			return true
		elseif card == Card.CARD_JUDGEMENT then
			return true
		elseif card == Card.CARD_WORLD then
			return true
		elseif piber20HelperOtherModCardType.CARD_THREE_OF_WANDS ~= -1 and card == piber20HelperOtherModCardType.CARD_THREE_OF_WANDS then
			return true
		end
		
		return false
	end

	--returns a random tarot card
	function piber20HelperMod:getRandomTarotCard()
		local tarotCardsPool = {
			Card.CARD_FOOL,
			Card.CARD_MAGICIAN,
			Card.CARD_HIGH_PRIESTESS,
			Card.CARD_EMPRESS,
			Card.CARD_HIEROPHANT,
			Card.CARD_LOVERS,
			Card.CARD_CHARIOT,
			Card.CARD_JUSTICE,
			Card.CARD_WHEEL_OF_FORTUNE,
			Card.CARD_STRENGTH,
			Card.CARD_HANGED_MAN,
			Card.CARD_DEATH,
			Card.CARD_TEMPERANCE,
			Card.CARD_DEVIL,
			Card.CARD_TOWER,
			Card.CARD_SUN,
			Card.CARD_JUDGEMENT,
			Card.CARD_WORLD
		}
		if not Game():IsGreedMode() then
			table.insert(tarotCardsPool, #tarotCardsPool + 1, Card.CARD_EMPEROR)
			table.insert(tarotCardsPool, #tarotCardsPool + 1, Card.CARD_HERMIT)
			table.insert(tarotCardsPool, #tarotCardsPool + 1, Card.CARD_STARS)
			table.insert(tarotCardsPool, #tarotCardsPool + 1, Card.CARD_MOON)
		end
		if piber20HelperOtherModCardType.CARD_THREE_OF_WANDS ~= -1 then
			table.insert(tarotCardsPool, #tarotCardsPool + 1, piber20HelperOtherModCardType.CARD_THREE_OF_WANDS)
		end
		return tarotCardsPool[piber20HelperMod:getRandomNumber(1, #tarotCardsPool, getRandomCardRNG)]
	end

	--function that returns true if the card is a magic card
	function piber20HelperMod:isMagicCard(card)
		if card == Card.CARD_CHAOS then
			return true
		elseif card == Card.CARD_HUGE_GROWTH then
			return true
		elseif card == Card.CARD_ANCIENT_RECALL then
			return true
		elseif card == Card.CARD_ERA_WALK then
			return true
		elseif piber20HelperOtherModCardType.CARD_MENDING_SALVE ~= -1 and card == piber20HelperOtherModCardType.CARD_MENDING_SALVE then
			return true
		elseif piber20HelperOtherModCardType.CARD_ELECTRIC_BOLT ~= -1 and card == piber20HelperOtherModCardType.CARD_ELECTRIC_BOLT then
			return true
		elseif piber20HelperOtherModCardType.CARD_DIM_RITUAL ~= -1 and card == piber20HelperOtherModCardType.CARD_DIM_RITUAL then
			return true
		elseif piber20HelperOtherModCardType.CARD_TURN_TO_TOAD ~= -1 and card == piber20HelperOtherModCardType.CARD_TURN_TO_TOAD then
			return true
		end
		
		return false
	end

	--returns a random magic card
	function piber20HelperMod:getRandomMagicCard()
		local magicCardsPool = {
			Card.CARD_CHAOS,
			Card.CARD_HUGE_GROWTH,
			Card.CARD_ANCIENT_RECALL,
			Card.CARD_ERA_WALK
		}
		if piber20HelperOtherModCardType.CARD_MENDING_SALVE ~= -1 then
			table.insert(magicCardsPool, #magicCardsPool + 1, piber20HelperOtherModCardType.CARD_MENDING_SALVE)
		end
		if piber20HelperOtherModCardType.CARD_ELECTRIC_BOLT ~= -1 then
			table.insert(magicCardsPool, #magicCardsPool + 1, piber20HelperOtherModCardType.CARD_ELECTRIC_BOLT)
		end
		if piber20HelperOtherModCardType.CARD_DIM_RITUAL ~= -1 then
			table.insert(magicCardsPool, #magicCardsPool + 1, piber20HelperOtherModCardType.CARD_DIM_RITUAL)
		end
		if piber20HelperOtherModCardType.CARD_TURN_TO_TOAD ~= -1 then
			table.insert(magicCardsPool, #magicCardsPool + 1, piber20HelperOtherModCardType.CARD_TURN_TO_TOAD)
		end
		return magicCardsPool[piber20HelperMod:getRandomNumber(1, #magicCardsPool, getRandomCardRNG)]
	end

	--function that returns true if the card is a playing card
	function piber20HelperMod:isPlayingCard(card, notSpecial)
		if card == Card.CARD_CLUBS_2 then
			return true
		elseif card == Card.CARD_DIAMONDS_2 then
			return true
		elseif card == Card.CARD_SPADES_2 then
			return true
		elseif card == Card.CARD_HEARTS_2 then
			return true
		elseif card == Card.CARD_ACE_OF_CLUBS then
			return true
		elseif card == Card.CARD_ACE_OF_DIAMONDS then
			return true
		elseif card == Card.CARD_ACE_OF_SPADES then
			return true
		elseif card == Card.CARD_ACE_OF_HEARTS then
			return true
		end
		
		if not notSpecial then
			if card == Card.CARD_JOKER then
				return true
			elseif card == Card.CARD_RULES then
				return true
			elseif card == Card.CARD_SUICIDE_KING then
				return true
			end
		end
		
		if AcesToJacksMod then
			if card == AcesToJacksCardType.CARD_JACK_OF_CLUBS then
				return true
			elseif card == AcesToJacksCardType.CARD_JACK_OF_DIAMONDS then
				return true
			elseif card == AcesToJacksCardType.CARD_JACK_OF_SPADES then
				return true
			elseif card == AcesToJacksCardType.CARD_JACK_OF_HEARTS then
				return true
			end
		end
		
		if EightOfCardsMod then
			if card == EightOfCardsCardType.CARD_CLUBS_8 then
				return true
			elseif card == EightOfCardsCardType.CARD_DIAMONDS_8 then
				return true
			elseif card == EightOfCardsCardType.CARD_SPADES_8 then
				return true
			elseif card == EightOfCardsCardType.CARD_HEARTS_8 then
				return true
			end
		end
		
		return false
	end

	--returns a random playing card
	function piber20HelperMod:getRandomPlayingCard(notSpecial)
		local playingCardsPool = {
			Card.CARD_CLUBS_2,
			Card.CARD_DIAMONDS_2,
			Card.CARD_SPADES_2,
			Card.CARD_HEARTS_2
		}
		if not notSpecial then
			table.insert(playingCardsPool, #playingCardsPool + 1, Card.CARD_RULES)
			table.insert(playingCardsPool, #playingCardsPool + 1, Card.CARD_SUICIDE_KING)
			if not Game():IsGreedMode() then
				table.insert(playingCardsPool, #playingCardsPool + 1, Card.CARD_JOKER)
			end
		end
		if AcesToJacksMod then
			table.insert(playingCardsPool, #playingCardsPool + 1, AcesToJacksCardType.CARD_JACK_OF_CLUBS)
			table.insert(playingCardsPool, #playingCardsPool + 1, AcesToJacksCardType.CARD_JACK_OF_DIAMONDS)
			table.insert(playingCardsPool, #playingCardsPool + 1, AcesToJacksCardType.CARD_JACK_OF_SPADES)
			table.insert(playingCardsPool, #playingCardsPool + 1, AcesToJacksCardType.CARD_JACK_OF_HEARTS)
		else
			table.insert(playingCardsPool, #playingCardsPool + 1, Card.CARD_ACE_OF_CLUBS)
			table.insert(playingCardsPool, #playingCardsPool + 1, Card.CARD_ACE_OF_DIAMONDS)
			table.insert(playingCardsPool, #playingCardsPool + 1, Card.CARD_ACE_OF_SPADES)
			table.insert(playingCardsPool, #playingCardsPool + 1, Card.CARD_ACE_OF_HEARTS)
		end
		if EightOfCardsMod then
			table.insert(playingCardsPool, #playingCardsPool + 1, EightOfCardsCardType.CARD_CLUBS_8)
			table.insert(playingCardsPool, #playingCardsPool + 1, EightOfCardsCardType.CARD_DIAMONDS_8)
			table.insert(playingCardsPool, #playingCardsPool + 1, EightOfCardsCardType.CARD_SPADES_8)
			table.insert(playingCardsPool, #playingCardsPool + 1, EightOfCardsCardType.CARD_HEARTS_8)
		end
		return playingCardsPool[piber20HelperMod:getRandomNumber(1, #playingCardsPool, getRandomCardRNG)]
	end

	--function that returns true if the card is a rune
	function piber20HelperMod:isRune(card)
		if card == Card.RUNE_HAGALAZ then
			return true
		elseif card == Card.RUNE_JERA then
			return true
		elseif card == Card.RUNE_EHWAZ then
			return true
		elseif card == Card.RUNE_DAGAZ then
			return true
		elseif card == Card.RUNE_ANSUZ then
			return true
		elseif card == Card.RUNE_PERTHRO then
			return true
		elseif card == Card.RUNE_BERKANO then
			return true
		elseif card == Card.RUNE_ALGIZ then
			return true
		elseif card == Card.RUNE_BLANK then
			return true
		elseif card == Card.RUNE_BLACK then
			return true
		elseif piber20HelperOtherModCardType.RUNE_NAUDIZ ~= -1 and card == piber20HelperOtherModCardType.RUNE_NAUDIZ then
			return true
		elseif piber20HelperOtherModCardType.RUNE_GEBO ~= -1 and card == piber20HelperOtherModCardType.RUNE_GEBO then
			return true
		elseif piber20HelperOtherModCardType.RUNE_FEHU ~= -1 and card == piber20HelperOtherModCardType.RUNE_FEHU then
			return true
		elseif piber20HelperOtherModCardType.RUNE_SOWILO ~= -1 and card == piber20HelperOtherModCardType.RUNE_SOWILO then
			return true
		end
		
		return false
	end

	--returns a random rune
	function piber20HelperMod:getRandomRune()
		local runesPool = {
			Card.RUNE_HAGALAZ,
			Card.RUNE_JERA,
			Card.RUNE_EHWAZ,
			Card.RUNE_DAGAZ,
			Card.RUNE_ANSUZ,
			Card.RUNE_PERTHRO,
			Card.RUNE_BERKANO,
			Card.RUNE_ALGIZ,
			Card.RUNE_BLANK,
			Card.RUNE_BLACK
		}
		if piber20HelperOtherModCardType.RUNE_NAUDIZ ~= -1 then
			table.insert(runesPool, #runesPool + 1, piber20HelperOtherModCardType.RUNE_NAUDIZ)
		end
		if piber20HelperOtherModCardType.RUNE_GEBO ~= -1 then
			table.insert(runesPool, #runesPool + 1, piber20HelperOtherModCardType.RUNE_GEBO)
		end
		if piber20HelperOtherModCardType.RUNE_FEHU ~= -1 then
			table.insert(runesPool, #runesPool + 1, piber20HelperOtherModCardType.RUNE_FEHU)
		end
		if piber20HelperOtherModCardType.RUNE_SOWILO ~= -1 then
			table.insert(runesPool, #runesPool + 1, piber20HelperOtherModCardType.RUNE_SOWILO)
		end
		return runesPool[piber20HelperMod:getRandomNumber(1, #runesPool, getRandomCardRNG)]
	end
	
	-------------------
	--Stage Functions--
	-------------------
	piber20HelperStage = {
		BASEMENT = 1,
		CELLAR = 2,
		BURNING_BASEMENT = 3,
		CAVES = 4,
		CATACOMBS = 5,
		FLOODED_CAVES = 6,
		DEPTHS = 7,
		NECROPOLIS = 8,
		DANK_DEPTHS = 9,
		WOMB = 10,
		UTERO = 11,
		SCARRED_WOMB = 12,
		BLUE_WOMB = 13,
		SHEOL = 14,
		CATHEDRAL = 15,
		DARK_ROOM = 16,
		CHEST = 17,
		VOID = 18
	}

	function piber20HelperMod:getCurrentStage(allowVoid)
		local level = Game():GetLevel()
		local stage = level:GetStage()
		local currentStage = piber20HelperStage.BASEMENT
		if Game():IsGreedMode() then
			if stage == 1 then
				currentStage = piber20HelperStage.BASEMENT
			elseif stage == 2 then
				currentStage = piber20HelperStage.CAVES
			elseif stage == 3 then
				currentStage = piber20HelperStage.DEPTHS
			elseif stage == 4 then
				currentStage = piber20HelperStage.WOMB
			elseif stage == 5 then
				currentStage = piber20HelperStage.SHEOL
			elseif stage == 6 then
				currentStage = piber20HelperStage.CHEST
			elseif stage == 7 then
				currentStage = piber20HelperStage.CHEST
			end
		elseif stage == 12 and not allowVoid then
			local room = level:GetCurrentRoom()
			local roomStage = room:GetRoomConfigStage()
			
			currentStage = piber20HelperStage.VOID
			if roomStage >= 1 and roomStage <= 17 then
				currentStage = roomStage
			end
		else
			local currentStageType = level:GetStageType()
			if stage == 1 or stage == 2 then
				if currentStageType == 0 then
					currentStage = piber20HelperStage.BASEMENT
				elseif currentStageType == 1 then
					currentStage = piber20HelperStage.CELLAR
				elseif currentStageType == 2 then
					currentStage = piber20HelperStage.BURNING_BASEMENT
				end
			elseif stage == 3 or stage == 4 then
				if currentStageType == 0 then
					currentStage = piber20HelperStage.CAVES
				elseif currentStageType == 1 then
					currentStage = piber20HelperStage.CATACOMBS
				elseif currentStageType == 2 then
					currentStage = piber20HelperStage.FLOODED_CAVES
				end
			elseif stage == 5 or stage == 6 then
				if currentStageType == 0 then
					currentStage = piber20HelperStage.DEPTHS
				elseif currentStageType == 1 then
					currentStage = piber20HelperStage.NECROPOLIS
				elseif currentStageType == 2 then
					currentStage = piber20HelperStage.DANK_DEPTHS
				end
			elseif stage == 7 or stage == 8 then
				if currentStageType == 0 then
					currentStage = piber20HelperStage.WOMB
				elseif currentStageType == 1 then
					currentStage = piber20HelperStage.UTERO
				elseif currentStageType == 2 then
					currentStage = piber20HelperStage.SCARRED_WOMB
				end
			elseif stage == 9 then
				currentStage = piber20HelperStage.BLUE_WOMB
			elseif stage == 10 then
				if currentStageType == 0 then
					currentStage = piber20HelperStage.SHEOL
				elseif currentStageType == 1 then
					currentStage = piber20HelperStage.CATHEDRAL
				end
			elseif stage == 11 then
				if currentStageType == 0 then
					currentStage = piber20HelperStage.DARK_ROOM
				elseif currentStageType == 1 then
					currentStage = piber20HelperStage.CHEST
				end
			elseif stage == 12 then
				currentStage = piber20HelperStage.VOID
			end
		end
		
		return currentStage
	end
	
	piber20HelperBackdrop = {
		BASEMENT = 1,
		CELLAR = 2,
		BURNING_BASEMENT = 3,
		CAVES = 4,
		CATACOMBS = 5,
		FLOODED_CAVES = 6,
		DEPTHS = 7,
		NECROPOLIS = 8,
		DANK_DEPTHS = 9,
		WOMB = 10,
		UTERO = 11,
		SCARRED_WOMB = 12,
		BLUE_WOMB = 13,
		SHEOL = 14,
		CATHEDRAL = 15,
		DARK_ROOM = 16,
		CHEST = 17,
		MEGA_SATAN = 18,
		LIBRARY = 19,
		SHOP = 20,
		ISAACS_ROOM = 21,
		BARREN_ROOM = 22,
		SECRET_ROOM = 23,
		DICE_ROOM = 24,
		ARCADE = 25,
		ERROR_ROOM = 26,
		BLUE_SECRET = 27,
		ULTRA_GREED = 28
	}

	function piber20HelperMod:getCurrentBackdrop()
		local room = Game():GetRoom()
		local backdrop = room:GetBackdropType()
		
		return backdrop
	end
	
	--------------------
	--Player Functions--
	--------------------
	--returns the player who is probably using an active item or card, otherwise returns Isaac.GetPlayer(0)
	function piber20HelperMod:getPlayerUsingItem()
		local player = Isaac.GetPlayer(0)
		
		local doOnce = false
		for i = 1, Game():GetNumPlayers() do
			local thisPlayer = Isaac.GetPlayer(i - 1)
			if not doOnce then
				if Input.IsActionTriggered(ButtonAction.ACTION_ITEM, thisPlayer.ControllerIndex) or Input.IsActionTriggered(ButtonAction.ACTION_PILLCARD, thisPlayer.ControllerIndex) then
					doOnce = true
					player = thisPlayer
				end
			end
		end
		
		return player
	end

	--this function returns true if the player is a ghost (true co-op feature)
	function piber20HelperMod:isPlayerGhost(player)
		if InfinityTrueCoopInterface then
			if player:GetData().TrueCoop then
				if player:GetData().TrueCoop.Save.IsGhost then
					return true
				end
			end
		end
		return false
	end
	
	function piber20HelperMod:setPlayerPositionForSingleUpdate(player, position)
		local data = piber20HelperMod:getData(player)
		data.movePlayerBackTo = player.Position
		player.Position = position
	end
	
	function piber20HelperMod:isPlayerPlayingGameFreezingAnimation()
		for i = 1, Game():GetNumPlayers() do
			local player = Isaac.GetPlayer(i - 1)
			local sprite = player:GetSprite()
			if sprite:IsPlaying("Appear") then
				return true
			elseif sprite:IsPlaying("Trapdoor") then
				return true
			elseif sprite:IsPlaying("LightTravel") then
				return true
			end
		end
		
		return false
	end
	
	function piber20HelperMod:addSmeltedTrinket(trinket, player)
		if player == nil then
			player = Isaac.GetPlayer(0)
		end

		--get the trinkets they're currently holding
		local trinket0 = player:GetTrinket(0)
		local trinket1 = player:GetTrinket(1)

		--remove them
		if trinket0 ~= 0 then
			player:TryRemoveTrinket(trinket0)
		end
		if trinket1 ~= 0 then
			player:TryRemoveTrinket(trinket1)
		end

		--make sure they don't already have it smelted
		if not player:HasTrinket(trinket) then
			player:AddTrinket(trinket) --add the trinket
			player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false, false, false, false) --smelt it
		end

		--give their trinkets back
		if trinket0 ~= 0 then
			player:AddTrinket(trinket0)
		end
		if trinket1 ~= 0 then
			player:AddTrinket(trinket1)
		end
	end
	
	function piber20HelperMod:getPlayerBlackHearts(player)
		--black heart bitmap code by echo. wtf nicalis
		local heartmap = player:GetBlackHearts()
		local blackHearts = 0
		while heartmap > 0 do
			heartmap = heartmap - 2^(math.floor(math.log(heartmap) / math.log(2)))
			blackHearts = blackHearts + 1
		end
		
		--terrible workaround to guess half vs full black hearts
		blackHearts = blackHearts * 2
		local soulHearts = player:GetSoulHearts()
		if soulHearts / 2 ~= math.floor(soulHearts / 2) then
			blackHearts = blackHearts - 1
		end
		if blackHearts < 0 then
			blackHearts = 0
		end
		
		return blackHearts
	end
	
	function piber20HelperMod:didPlayerJustLoseBlackHeart(player)
		local data = piber20HelperMod:getData(player)
		if data.justLostBlackHeart then
			return true
		end
		
		return false
	end
	
	function piber20HelperMod:canPlayerPickEternalHearts(player)
		if (player:GetEffectiveMaxHearts() + player:GetEternalHearts()) < 25 then
			return true
		end
		
		return false
	end
	
	function piber20HelperMod:getPlayerEmptyHearts(player)
		return player:GetEffectiveMaxHearts() - player:GetHearts()
	end
	
	function piber20HelperMod:didPlayerUseActiveItem(player, itemID)
		local data = piber20HelperMod:getData(player)
		if data.ItemsUsedInThisRoom == nil then
			data.ItemsUsedInThisRoom = {}
		end
		if data.ItemsUsedInThisRoom[itemID] then
			if data.ItemsUsedInThisRoom[itemID] > 0 then
				return true
			end
		end
		
		return false
	end
	
	function piber20HelperMod:didPlayerUseActiveItemNum(player, itemID)
		local data = piber20HelperMod:getData(player)
		if data.ItemsUsedInThisRoom == nil then
			data.ItemsUsedInThisRoom = {}
		end
		if data.ItemsUsedInThisRoom[itemID] == nil then
			return 0
		elseif data.ItemsUsedInThisRoom[itemID] > 0 then
			return data.ItemsUsedInThisRoom[itemID]
		end
		
		return 0
	end
	
	function piber20HelperMod:didPlayerUseCard(player, cardID)
		local data = piber20HelperMod:getData(player)
		if data.CardsUsedInThisRoom == nil then
			data.CardsUsedInThisRoom = {}
		end
		if data.CardsUsedInThisRoom[cardID] then
			if data.CardsUsedInThisRoom[cardID] > 0 then
				return true
			end
		end
		
		return false
	end
	
	function piber20HelperMod:didPlayerUseCardNum(player, cardID)
		local data = piber20HelperMod:getData(player)
		if data.CardsUsedInThisRoom == nil then
			data.CardsUsedInThisRoom = {}
		end
		if data.CardsUsedInThisRoom[cardID] == nil then
			return 0
		elseif data.CardsUsedInThisRoom[cardID] > 0 then
			return data.CardsUsedInThisRoom[cardID]
		end
		
		return 0
	end
	
	function piber20HelperMod:didPlayerUsePillEffect(player, pillEffect)
		local data = piber20HelperMod:getData(player)
		if data.PillEffectsUsedInThisRoom == nil then
			data.PillEffectsUsedInThisRoom = {}
		end
		if data.PillEffectsUsedInThisRoom[pillEffect] then
			if data.PillEffectsUsedInThisRoom[pillEffect] > 0 then
				return true
			end
		end
		
		return false
	end
	
	function piber20HelperMod:didPlayerUsePillEffectNum(player, pillEffect)
		local data = piber20HelperMod:getData(player)
		if data.PillEffectsUsedInThisRoom == nil then
			data.PillEffectsUsedInThisRoom = {}
		end
		if data.PillEffectsUsedInThisRoom[pillEffect] == nil then
			return 0
		elseif data.PillEffectsUsedInThisRoom[pillEffect] > 0 then
			return data.PillEffectsUsedInThisRoom[pillEffect]
		end
		
		return 0
	end
	
	function piber20HelperMod:isPlayerTrueCoopCharacter(player, playerType, playerName)
		if player:GetPlayerType() == playerType then
			return true
		elseif InfinityTrueCoopInterface then
			if player:GetData().TrueCoop then
				if player:GetData().TrueCoop.Save.PlayerName == playerName then
					return true
				end
			end
		end
		return false
	end
	
	function piber20HelperMod:getPlayerMantleEffects(player)
		local effects = player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_HOLY_MANTLE)
		return effects
	end
	
	function piber20HelperMod:didPlayerJustLoseMantleEffect(player)
		local data = piber20HelperMod:getData(player)
		if data.justLostMantleEffect then
			return true
		end
		
		return false
	end
	
	function piber20HelperMod:getPlayerTrinketCount(player)
		local currentTrinketCount = 0
		if player:GetTrinket(0) > 0 then
			currentTrinketCount = currentTrinketCount + 1
		end
		if player:GetTrinket(1) > 0 then
			currentTrinketCount = currentTrinketCount + 1
		end
		return currentTrinketCount
	end
	
	function piber20HelperMod:didPlayerCollectibleCountJustChange(player)
		local data = piber20HelperMod:getData(player)
		if data.didCollectibleCountJustChange then
			return true
		end
		
		return false
	end
	
	function piber20HelperMod:didPlayerTrinketCountJustChange(player)
		local data = piber20HelperMod:getData(player)
		if data.didTrinketCountJustChange then
			return true
		end
		
		return false
	end
	
	function piber20HelperMod:didPlayerEffectCountJustChange(player)
		local data = piber20HelperMod:getData(player)
		if data.didEffectCountJustChange then
			return true
		end
		
		return false
	end
	
	function piber20HelperMod:didPlayerCharacterJustChange(player)
		local data = piber20HelperMod:getData(player)
		if data.playerTypeJustChanged then
			return true
		end
		
		return false
	end
	
	function piber20HelperMod:getPlayerVisibleHearts(player)
		local visibleHearts = player:GetEffectiveMaxHearts() + player:GetSoulHearts()
		local visibleHearts = visibleHearts / 2
		local visibleHearts = math.ceil(visibleHearts)
		if visibleHearts < 1 then
			visibleHearts = 1
		end
		return visibleHearts
	end
	
	------------------------------
	--Someone/Everyone Functions--
	------------------------------
	function piber20HelperMod:someoneHasCollectible(collectibleType)
		for i = 1, Game():GetNumPlayers() do
			local player = Isaac.GetPlayer(i - 1)
			if player:HasCollectible(collectibleType) then
				return true
			end
		end
		
		return false
	end
	
	function piber20HelperMod:everyoneHasCollectibleNum(collectibleType)
		local collectibleCount = 0
		for i = 1, Game():GetNumPlayers() do
			local player = Isaac.GetPlayer(i - 1)
			if player:HasCollectible(collectibleType) then
				collectibleCount = collectibleCount + player:GetCollectibleNum(collectibleType)
			end
		end
		
		return collectibleCount
	end
	
	function piber20HelperMod:someoneHasTrinket(trinketType)
		for i = 1, Game():GetNumPlayers() do
			local player = Isaac.GetPlayer(i - 1)
			if player:HasTrinket(trinketType) then
				return true
			end
		end
		
		return false
	end
	
	function piber20HelperMod:everyoneHasTrinketNum(trinketType)
		local trinketCount = 0
		for i = 1, Game():GetNumPlayers() do
			local player = Isaac.GetPlayer(i - 1)
			if player:HasTrinket(trinketType) then
				trinketCount = trinketCount + 1
			end
		end
		
		return trinketCount
	end
	
	function piber20HelperMod:someoneHasTrinketAndMomsBox(trinketType)
		for i = 1, Game():GetNumPlayers() do
			local player = Isaac.GetPlayer(i - 1)
			if player:HasTrinket(trinketType) then
				if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
					return true
				end
			end
		end
		
		return false
	end
	
	function piber20HelperMod:everyoneHasTrinketAndMomsBoxNum(trinketType)
		local trinketCount = 0
		for i = 1, Game():GetNumPlayers() do
			local player = Isaac.GetPlayer(i - 1)
			if player:HasTrinket(trinketType) then
				if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
					trinketCount = trinketCount + 1
				end
			end
		end
		
		return trinketCount
	end
	
	function piber20HelperMod:someoneHasTrinketButNotMomsBox(trinketType)
		for i = 1, Game():GetNumPlayers() do
			local player = Isaac.GetPlayer(i - 1)
			if player:HasTrinket(trinketType) then
				if not player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
					return true
				end
			end
		end
		
		return false
	end
	
	function piber20HelperMod:everyoneHasTrinketButNotMomsBoxNum(trinketType)
		local trinketCount = 0
		for i = 1, Game():GetNumPlayers() do
			local player = Isaac.GetPlayer(i - 1)
			if player:HasTrinket(trinketType) then
				if not player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
					trinketCount = trinketCount + 1
				end
			end
		end
		
		return trinketCount
	end
	
	function piber20HelperMod:everyoneHasEqualPickups()
		for i = 1, Game():GetNumPlayers() do
			local player = Isaac.GetPlayer(i - 1)
			
			local playerCoins = player:GetNumCoins()
			local playerBombs = player:GetNumBombs()
			local playerKeys = player:GetNumKeys()
			if playerCoins ~= playerBombs or playerBombs ~= playerKeys or playerCoins ~= playerKeys then
				return false
			end
		end
		
		return true
	end
	
	function piber20HelperMod:someoneHasCard(card)
		for i = 1, Game():GetNumPlayers() do
			local player = Isaac.GetPlayer(i - 1)
			if player:GetCard(0) == card then
				return true
			end
			if player:GetCard(1) == card then
				return true
			end
		end
		
		return false
	end
	
	function piber20HelperMod:animateHappyAll()
		for i = 1, Game():GetNumPlayers() do
			local player = Isaac.GetPlayer(i - 1)
			player:AnimateHappy()
		end
	end
	
	function piber20HelperMod:animateSadAll()
		for i = 1, Game():GetNumPlayers() do
			local player = Isaac.GetPlayer(i - 1)
			player:AnimateSad()
		end
	end
	
	--------------------
	--Pickup Functions--
	--------------------
	--returns values that pickups should be (with humbling bundle etc)
	function piber20HelperMod:getPickupValues(bombs)
		local value = 1
		for i = 1, Game():GetNumPlayers() do
			local player = Isaac.GetPlayer(i - 1)
			if bombs then
				value = value + piber20HelperMod:everyoneHasCollectibleNum(CollectibleType.COLLECTIBLE_BOGO_BOMBS)
			end
			value = value + piber20HelperMod:everyoneHasCollectibleNum(CollectibleType.COLLECTIBLE_HUMBLEING_BUNDLE)
			if piber20HelperMod:everyoneHasEqualPickups() then
				value = value + piber20HelperMod:everyoneHasTrinketNum(TrinketType.TRINKET_EQUALITY)
			end
		end
		
		return value
	end

	--this function returns the player entity who's probably touching the pickup provided
	function piber20HelperMod:getPlayerTouchingPickup(pickup, ignorePrice)
		local isShopItem = pickup:IsShopItem()
		local price = 0
		if isShopItem then
			price = pickup.Price
		end
		
		--get all the players
		for i = 1, Game():GetNumPlayers() do
			local player = Isaac.GetPlayer(i - 1)
			if not piber20HelperMod:isPlayerGhost(player) then --dead players shouldn't be able to pick up stuff
				if (player.Position - pickup.Position):Length() < player.Size + pickup.Size + 3 then --check if the player is touching it
					if (isShopItem and player:GetNumCoins() >= price) or not isShopItem or ignorePrice then --check if the player can afford it if it's a shop item
						return player
					end
				end
			end
		end
		
		--try to get a player from bone club swings
		if not isShopItem then
			for _, knife in pairs(Isaac.FindByType(EntityType.ENTITY_KNIFE, -1, 4, false, false)) do
				if knife.FrameCount > 0 then
					if knife.Parent then
						local parent = knife.Parent
						if parent:ToPlayer() then
							local player = parent:ToPlayer()
							
							--find the center of the swing object
							knife = knife:ToKnife()
							local position = knife.Position
							local scale = 30 * knife.SpriteScale.X
							local offset = Vector(scale,0)
							offset = offset:Rotated(knife.Rotation)
							position = position + offset
							
							--do player checks
							if not piber20HelperMod:isPlayerGhost(player) then --dead players shouldn't be able to pick up stuff
								if (position - pickup.Position):Length() < pickup.Size + scale then --check if the player is touching it
									return player
								end
							end
						end
					end
				end
			end
		end
		
		--didnt find any player touching the pickup
		return false
	end

	--this function removes the pickup and makes it play the collect animation
	function piber20HelperMod:collectPickup(pickup)
		pickup = pickup:ToPickup()
		pickup.Velocity = Vector(0,0)
		pickup.Touched = true
		pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		pickup:GetSprite():Play("Collect", true)
		pickup:Die() --this will remove the pickup but let it continue playing the animation
	end
	
	local pickupToRestock = {}
	function piber20HelperMod:restockPickup(variant, subtype, position, price)
		if price == nil then
			price = 5
		end
		local pickupData = {
			Variant = variant,
			SubType = subtype,
			Position = position,
			Price = price,
			Frame = Isaac.GetFrameCount()
		}
		table.insert(pickupToRestock, #pickupToRestock + 1, pickupData)
	end
	
	function piber20HelperMod:buyPickup(pickup, player, doNotRestock)
		if pickup:IsShopItem() then
			local price = pickup.Price
			if price > 0 then
				local coinsToRemove = price
				if player:GetNumCoins() < coinsToRemove then
					coinsToRemove = player:GetNumCoins()
				end
				player:AddCoins(-coinsToRemove)
			else
				price = 5
			end
			
			local removedStoreCredit = false
			for i = 1, Game():GetNumPlayers() do
				local player = Isaac.GetPlayer(i - 1)
				if not removedStoreCredit then
					if player:HasTrinket(TrinketType.TRINKET_STORE_CREDIT) then
						player:TryRemoveTrinket(TrinketType.TRINKET_STORE_CREDIT)
						removedStoreCredit = true
					end
				end
			end
			
			if not doNotRestock then
				if piber20HelperMod:shouldRestock() then
					piber20HelperMod:restockPickup(pickup.Variant, pickup.SubType, pickup.Position, price)
				end
			end
			pickup:Remove()
		end
	end

	--this function returns true if someone has restock or if we're in greed mode
	function piber20HelperMod:shouldRestock()
		if Game():IsGreedMode() then
			return true
		end
		if piber20HelperMod:someoneHasCollectible(CollectibleType.COLLECTIBLE_RESTOCK) then
			return true
		end
		return false
	end
	
	------------------
	--Room Functions--
	------------------
	--returns the entity that's in the center of the room
	function piber20HelperMod:getCenterEntity()
		local room = Game():GetRoom()
		for _, entity in pairs(Isaac.GetRoomEntities()) do
			if (room:GetCenterPos() - entity.Position):Length() < 40 then
				return entity
			end
		end
		
		return nil
	end
	
	--returns true if a collectible is in the room
	function piber20HelperMod:isCollectibleInRoom()
		for _, pickup in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, -1, -1, false, false)) do
			local variant = pickup.Variant
			
			if variant == PickupVariant.PICKUP_COLLECTIBLE then
				return true
			end
		end
		
		return false
	end
	
	--returns the room index of a room of the room type provided
	local roomTypeRNG = piber20HelperMod:getInitializedRNG()
	function piber20HelperMod:getRoomTypeIndex(roomType)
		local level = Game():GetLevel()
		local roomIndex = level:QueryRoomTypeIndex(roomType, false, roomTypeRNG)
		return roomIndex
	end
	
	--teleports the players to the room index provided
	function piber20HelperMod:teleportToRoomIndex(roomIndex)
		local level = Game():GetLevel()
		level.EnterDoor = -1
		level.LeaveDoor = -1
		Game():StartRoomTransition(roomIndex, Direction.NO_DIRECTION, 3)
	end
	
	--teleports the players to a room with the room type provided
	function piber20HelperMod:teleportToRoomType(roomType)
		local roomIndex = piber20HelperMod:getRoomTypeIndex(roomType)
		piber20HelperMod:teleportToRoomIndex(roomIndex)
	end
	
	--opens all the doors
	function piber20HelperMod:openAllDoors()
		local room = Game():GetRoom()
		for door = 0, 7 do
			if room:GetDoor(door) ~= nil then
				room:GetDoor(door):Open()
			end
		end
	end
	
	--closes all the doors
	function piber20HelperMod:closeAllDoors(force)
		if force == nil then
			force = false
		end
		local room = Game():GetRoom()
		for door = 0, 7 do
			if room:GetDoor(door) ~= nil then
				room:GetDoor(door):Close(force)
			end
		end
	end
	
	--bars all the doors
	function piber20HelperMod:barAllDoors()
		local room = Game():GetRoom()
		for door = 0, 7 do
			if room:GetDoor(door) ~= nil then
				room:GetDoor(door):Bar()
			end
		end
	end
	
	--blows open all the doors
	function piber20HelperMod:blowOpenAllDoors(fromExplosion)
		if fromExplosion == nil then
			fromExplosion = false
		end
		local room = Game():GetRoom()
		for door = 0, 7 do
			if room:GetDoor(door) ~= nil then
				room:GetDoor(door):TryBlowOpen(fromExplosion)
			end
		end
	end
	
	--unlocks all the doors
	function piber20HelperMod:unlockAllDoors(force)
		if force == nil then
			force = false
		end
		local room = Game():GetRoom()
		for door = 0, 7 do
			if room:GetDoor(door) ~= nil then
				room:GetDoor(door):TryUnlock(force)
			end
		end
	end
	
	--locks all the doors
	function piber20HelperMod:lockAllDoors()
		local room = Game():GetRoom()
		for door = 0, 7 do
			if room:GetDoor(door) ~= nil then
				room:GetDoor(door):SetLocked(true)
			end
		end
	end
	
	--returns true if the room was just cleared
	local roomWasCleared = true
	local roomWasJustCleared = false
	function piber20HelperMod:wasRoomJustCleared()
		return roomWasJustCleared
	end
	
	---------------------
	--Costume Functions--
	---------------------
	local characterCostumes = {}
	function piber20HelperMod:forceCostumeWithCharacter(playerType, playerName, costume, costumeType)
		if costumeType == nil then
			costumeType = piber20HelperCostumeType.NULL
		end
		local tableToInsert = {
			ID = playerType,
			Name = playerName,
			Costume = costume,
			Type = costumeType
		}
		table.insert(characterCostumes, #characterCostumes + 1, tableToInsert)
	end
	local collectibleCostumes = {}
	function piber20HelperMod:forceCostumeWithCollectible(collectible, costume, costumeType)
		if costumeType == nil then
			costumeType = piber20HelperCostumeType.NULL
		end
		local tableToInsert = {
			ID = collectible,
			Costume = costume,
			Type = costumeType
		}
		table.insert(collectibleCostumes, #collectibleCostumes + 1, tableToInsert)
	end
	local trinketCostumes = {}
	function piber20HelperMod:forceCostumeWithTrinket(trinket, costume, costumeType)
		if costumeType == nil then
			costumeType = piber20HelperCostumeType.NULL
		end
		local tableToInsert = {
			ID = trinket,
			Costume = costume,
			Type = costumeType
		}
		table.insert(trinketCostumes, #trinketCostumes + 1, tableToInsert)
	end
	local activeItemCostumes = {}
	function piber20HelperMod:forceCostumeWithActiveItem(collectible, costume, costumeType)
		if costumeType == nil then
			costumeType = piber20HelperCostumeType.NULL
		end
		local tableToInsert = {
			ID = collectible,
			Costume = costume,
			Type = costumeType
		}
		table.insert(activeItemCostumes, #activeItemCostumes + 1, tableToInsert)
	end
	local cardCostumes = {}
	function piber20HelperMod:forceCostumeWithCard(card, costume, costumeType)
		if costumeType == nil then
			costumeType = piber20HelperCostumeType.NULL
		end
		local tableToInsert = {
			ID = card,
			Costume = costume,
			Type = costumeType
		}
		table.insert(cardCostumes, #cardCostumes + 1, tableToInsert)
	end
	local pillEffectCostumes = {}
	function piber20HelperMod:forceCostumeWithPillEffect(pillEffect, costume, costumeType)
		if costumeType == nil then
			costumeType = piber20HelperCostumeType.NULL
		end
		local tableToInsert = {
			ID = pillEffect,
			Costume = costume,
			Type = costumeType
		}
		table.insert(pillEffectCostumes, #pillEffectCostumes + 1, tableToInsert)
	end
	
	-----------------------------
	--Screen Position Functions--
	-----------------------------
	function piber20HelperMod:getScreenCenterPosition()
		local room = Game():GetRoom()
		local shape = room:GetRoomShape()
		local centerOffset = (room:GetCenterPos()) - room:GetTopLeftPos()
		local pos = room:GetCenterPos()
		if centerOffset.X > 260 then
			pos.X = pos.X - 260
		end
		if shape == RoomShape.ROOMSHAPE_LBL or shape == RoomShape.ROOMSHAPE_LTL then
			pos.X = pos.X - 260
		end
		if centerOffset.Y > 140 then
			pos.Y = pos.Y - 140
		end
		if shape == RoomShape.ROOMSHAPE_LTR or shape == RoomShape.ROOMSHAPE_LTL then
			pos.Y = pos.Y - 140
		end
		return Isaac.WorldToRenderPosition(pos, false)
	end
	
	function piber20HelperMod:getScreenBottomRight(offset, doHealthOffset)
		local pos = piber20HelperMod:getScreenCenterPosition() * 2
		
		if offset then
			local hudOffset = Vector(-offset * 1.6, -offset * 0.6)
			if doHealthOffset then
				local hudOffset = Vector((-offset * 1.6) - ((offset - 10) * 0.2), -offset * 0.6)
			end
			pos = pos + hudOffset
		end

		return pos
	end

	function piber20HelperMod:getScreenBottomLeft(offset)
		local pos = Vector(0, piber20HelperMod:getScreenBottomRight().Y)
		
		if offset then
			local hudOffset = Vector(offset * 2.2, -offset * 1.6)
			pos = pos + hudOffset
		end
		
		return pos
	end

	function piber20HelperMod:getScreenTopRight(offset, doHealthOffset)
		local pos = Vector(piber20HelperMod:getScreenBottomRight().X, 0)
		
		if offset then
			local hudOffset = Vector(-offset * 2.2, offset * 1.2)
			if doHealthOffset then
				hudOffset = Vector((-offset * 2.2) - ((offset - 10) * 0.2), offset * 1.2)
			end
			pos = pos + hudOffset
		end

		return pos
	end
	
	function piber20HelperMod:getScreenTopLeft(offset)
		local pos = Vector(0, 0)
		
		if offset then
			local hudOffset = Vector(offset * 2, offset * 1.2)
			pos = pos + hudOffset
		end
		
		return pos
	end
	
	---------------------
	--Overlay Functions--
	---------------------
	local shouldRenderStreak = false
	local streakUI = Sprite()
	streakUI:Load("gfx/ui/ui_streak.anm2", true)
	local streakFont1 = Font()
	streakFont1:Load("font/upheaval.fnt")
	local streakFont2 = Font()
	streakFont2:Load("font/pftempestasevencondensed.fnt")
	local streakTextPosition = Vector(0,0)
	local streakTextScale = Vector(0,0)
	local streakText1 = " "
	local streakText2 = " "
	local streakText3 = " "
	function piber20HelperMod:doStreak(text1, text2, text3, spritesheet)
		if text1 == nil then
			text1 = " "
		end
		streakText1 = tostring(text1)
		
		if text2 == nil then
			text2 = " "
		end
		streakText2 = tostring(text2)
		
		if text3 == nil then
			text3 = " "
		end
		streakText3 = tostring(text3)
		
		if spritesheet == nil then
			spritesheet = "gfx/ui/effect_024_streak.png"
		end
		streakUI:ReplaceSpritesheet(0, spritesheet)
		
		streakUI:LoadGraphics()
		streakUI:Play("Text", true)
		shouldRenderStreak = true
	end
	
	local shouldRenderGiantbook = false
	local giantbookUI = Sprite()
	giantbookUI:Load("gfx/ui/giantbook/giantbook.anm2", true)
	local giantbookAnimation = "Appear"
	function piber20HelperMod:doBigbook(spritesheet, sound, animationToPlay, animationFile)
		if animationToPlay == nil then
			animationToPlay = "Appear"
		end
		
		if animationFile == nil then
			animationFile = "gfx/ui/giantbook/giantbook.anm2"
			if animationToPlay == "Appear" or animationToPlay == "Shake" then
				animationFile = "gfx/ui/giantbook/giantbook.anm2"
			elseif animationToPlay == "Static" then
				animationToPlay = "Effect"
				animationFile = "gfx/ui/giantbook/giantbook_clicker.anm2"
			elseif animationToPlay == "Flash" then
				animationToPlay = "Idle"
				animationFile = "gfx/ui/giantbook/giantbook_mama_mega.anm2"
			elseif animationToPlay == "Sleep" then
				animationToPlay = "Idle"
				animationFile = "gfx/ui/giantbook/giantbook_sleep.anm2"
			elseif animationToPlay == "AppearBig" or animationToPlay == "ShakeBig" then
				if animationToPlay == "AppearBig" then
					animationToPlay = "Appear"
				elseif animationToPlay == "ShakeBig" then
					animationToPlay = "Shake"
				end
				animationFile = "gfx/ui/giantbook/giantbookbig.anm2"
			end
		end
		
		giantbookAnimation = animationToPlay
		giantbookUI:Load(animationFile, true)
		if spritesheet == nil then
			spritesheet = "gfx/ui/giantbook/GiantBook_010_Bible.png"
		end
		giantbookUI:ReplaceSpritesheet(0, spritesheet)
		giantbookUI:LoadGraphics()
		giantbookUI:Play(animationToPlay, true)
		shouldRenderGiantbook = true
		
		if sound ~= nil then
			SFXManager():Play(sound, 1, 0, false, 1)
		end
	end
	
	local shouldRenderAchievement = false
	local achievementUI = Sprite()
	achievementUI:Load("gfx/ui/achievement/achievements.anm2", true)
	local achievementUIDelay = 0
	function piber20HelperMod:doAchievement(spritesheet, sound)
		if shouldRenderAchievement then
			piber20HelperMod:schedule(120, true, piber20HelperMod.doAchievement, spritesheet, sound)
			return
		end
		
		if spritesheet == nil then
			spritesheet = "gfx/ui/achievement/paper.png"
		end
		achievementUI:ReplaceSpritesheet(3, spritesheet)
		achievementUI:LoadGraphics()
		
		achievementUI:Play("Appear", true)
		shouldRenderAchievement = true
		achievementUIDelay = 90
		
		if sound == nil then
			sound = SoundEffect.SOUND_CHOIR_UNLOCK
		end
		SFXManager():Play(sound, 1, 0, false, 1)
	end
	
	----------------------
	--Schedule Functions--
	----------------------
	local functionsToCallInOnUpdate = {}
	local functionsToCallInOnRender = {}
	function piber20HelperMod:schedule(delay, onRender, functionToCall, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
		if delay then
			if delay > 0 then
				if functionToCall then
					local tableToInsert = {
						Frame = Isaac.GetFrameCount(),
						Delay = delay,
						Function = functionToCall,
						Arg1 = arg1,
						Arg2 = arg2,
						Arg3 = arg3,
						Arg4 = arg4,
						Arg5 = arg5,
						Arg6 = arg6,
						Arg7 = arg7,
						Arg8 = arg8,
						Arg9 = arg9
					}
					if onRender then
						table.insert(functionsToCallInOnRender, #functionsToCallInOnRender + 1, tableToInsert)
					else
						table.insert(functionsToCallInOnUpdate, #functionsToCallInOnUpdate + 1, tableToInsert)
					end
				end
			end
		end
	end
	
	function piber20HelperMod:cancel(functionToCancel)
		if #functionsToCallInOnUpdate >= 1 then
			for i = 1, #functionsToCallInOnUpdate do
				if functionsToCallInOnUpdate[i].Function then
					if functionsToCallInOnUpdate[i].Function == functionToCancel then
						functionsToCallInOnUpdate[i] = nil
					end
				end
			end
		end
		if #functionsToCallInOnRender >= 1 then
			for i = 1, #functionsToCallInOnRender do
				if functionsToCallInOnRender[i].Function then
					if functionsToCallInOnRender[i].Function == functionToCancel then
						functionsToCallInOnRender[i] = nil
					end
				end
			end
		end
	end
	
	-------------
	--CALLBACKS--
	-------------
	
	function piber20HelperMod:onRoomChange()
		for i = 1, Game():GetNumPlayers() do
			local player = Isaac.GetPlayer(i - 1)
			local data = piber20HelperMod:getData(player)
			data.ItemsUsedInThisRoom = {}
			data.CardsUsedInThisRoom = {}
			data.PillEffectsUsedInThisRoom = {}
		end
		pickupToRestock = {}
	end
	
	function piber20HelperMod:onUseItem(itemID, rng)
		local player = piber20HelperMod:getPlayerUsingItem()
		local data = piber20HelperMod:getData(player)
		if data.ItemsUsedInThisRoom == nil then
			data.ItemsUsedInThisRoom = {}
		end
		if data.ItemsUsedInThisRoom[itemID] == nil then
			data.ItemsUsedInThisRoom[itemID] = 0
		end
		data.ItemsUsedInThisRoom[itemID] = data.ItemsUsedInThisRoom[itemID] + 1
	end
	
	function piber20HelperMod:onUseCard(cardID)
		local player = piber20HelperMod:getPlayerUsingItem()
		local data = piber20HelperMod:getData(player)
		if data.CardsUsedInThisRoom == nil then
			data.CardsUsedInThisRoom = {}
		end
		if data.CardsUsedInThisRoom[cardID] == nil then
			data.CardsUsedInThisRoom[cardID] = 0
		end
		data.CardsUsedInThisRoom[cardID] = data.CardsUsedInThisRoom[cardID] + 1
	end
	
	function piber20HelperMod:onUsePill(pillEffect)
		local player = piber20HelperMod:getPlayerUsingItem()
		local data = piber20HelperMod:getData(player)
		if data.PillEffectsUsedInThisRoom == nil then
			data.PillEffectsUsedInThisRoom = {}
		end
		if data.PillEffectsUsedInThisRoom[pillEffect] == nil then
			data.PillEffectsUsedInThisRoom[pillEffect] = 0
		end
		data.PillEffectsUsedInThisRoom[pillEffect] = data.PillEffectsUsedInThisRoom[pillEffect] + 1
	end
	
	function piber20HelperMod:onGameStart(isSaveGame)
		piber20HelperMod.GameStarted = true
		piber20HelperMod.IsSaveGame = false
		if isSaveGame then
			piber20HelperMod.IsSaveGame = true
		end
		piber20HelperMod:checkForModContent()
		piber20HelperMod:resetRNGSeed(newRNG)
		piber20HelperMod:resetRNGSeed(getCurrentItemPoolRNG)
		piber20HelperMod:resetRNGSeed(getRandomCollectibleRNG)
		piber20HelperMod:resetRNGSeed(getRandomCardRNG)
		piber20HelperMod:resetRNGSeed(getRandomPillRNG)
		piber20HelperMod:resetRNGSeed(roomTypeRNG)
		shouldRenderStreak = false
		shouldRenderGiantbook = false
		shouldRenderAchievement = false
		pickupToRestock = {}
	end
	
	function piber20HelperMod:onUpdate()
		local room = Game():GetRoom()
		
		--for use with wasRoomJustCleared
		roomWasJustCleared = false
		if not roomWasCleared and room:IsClear() then
			roomWasJustCleared = true
		end
		roomWasCleared = room:IsClear()
		
		for i = 1, Game():GetNumPlayers() do
			local player = Isaac.GetPlayer(i - 1)
			local data = piber20HelperMod:getData(player)
			
			--for use with setPlayerPositionForSingleUpdate
			if data.movePlayerBackTo then
				player.Position = data.movePlayerBackTo
				data.movePlayerBackTo = nil
			end
			
			--for use with didPlayerJustLoseBlackHeart
			if data.lastBlackHeartAmount == nil then
				data.lastBlackHeartAmount = 0
			end
			data.justLostBlackHeart = false
			local blackHearts = piber20HelperMod:getPlayerBlackHearts(player)
			if math.floor((blackHearts + 1) / 2) < math.floor((data.lastBlackHeartAmount + 1) / 2) then
				data.justLostBlackHeart = true
			end
			data.lastBlackHeartAmount = blackHearts
			
			--for use with didPlayerJustLoseMantleEffect
			if data.lastMantleEffectAmount == nil then
				data.lastMantleEffectAmount = 0
			end
			data.justLostMantleEffect = false
			if not piber20HelperMod:isPlayerPlayingGameFreezingAnimation() and room:GetFrameCount() > 10 then
				local mantleEffects = piber20HelperMod:getPlayerMantleEffects(player)
				if mantleEffects < data.lastMantleEffectAmount then
					data.justLostMantleEffect = true
				end
				data.lastMantleEffectAmount = mantleEffects
			end
			
			local currentCollectibleCount = player:GetCollectibleCount()
			if data.lastCollectibleCount == nil then
				data.lastCollectibleCount = currentCollectibleCount
			end
			data.didCollectibleCountJustChange = false
			if data.lastCollectibleCount ~= currentCollectibleCount then
				data.didCollectibleCountJustChange = true
			end
			data.lastCollectibleCount = currentCollectibleCount
			
			local currentTrinketCount = piber20HelperMod:getPlayerTrinketCount(player)
			if data.lastTrinketCount == nil then
				data.lastTrinketCount = currentTrinketCount
			end
			data.didTrinketCountJustChange = false
			if data.lastTrinketCount ~= currentTrinketCount then
				data.didTrinketCountJustChange = true
			end
			data.lastTrinketCount = currentTrinketCount
			
			local effects = player:GetEffects()
			local currentEffectList = effects:GetEffectsList()
			local currentEffectCount = #currentEffectList
			if data.lastEffectCount == nil then
				data.lastEffectCount = currentEffectCount
			end
			data.didEffectCountJustChange = false
			if data.lastEffectCount ~= currentEffectCount then
				data.didEffectCountJustChange = true
			end
			data.lastEffectCount = currentEffectCount
			
			local playerType = player:GetPlayerType()
			if data.lastPlayerType == nil then
				data.lastPlayerType = playerType
			end
			data.playerTypeJustChanged = false
			if data.lastPlayerType ~= playerType then
				data.playerTypeJustChanged = true
			end
			data.lastPlayerType = playerType
			
			--for use with forceCostumeWithCharacter
			if #characterCostumes >= 1 then
				if data.CharacterCostumesAdded == nil then
					data.CharacterCostumesAdded = {}
				end
				for j = 1, #characterCostumes do
					if characterCostumes[j] then
						if characterCostumes[j].ID then
							if characterCostumes[j].Name then
								if characterCostumes[j].Costume then
									if characterCostumes[j].Type then
										local playerType = characterCostumes[j].ID
										local playerName = characterCostumes[j].Name
										local costume = characterCostumes[j].Costume
										local costumeType = characterCostumes[j].Type
										if not data.CharacterCostumesAdded[j] then
											if piber20HelperMod:isPlayerTrueCoopCharacter(player, playerType, playerName) then
												if costumeType == piber20HelperCostumeType.COLLECTIBLE then
													player:AddCostume(Isaac:GetItemConfig():GetCollectible(costume), false)
												elseif costumeType == piber20HelperCostumeType.TRINKET then
													player:AddCostume(Isaac:GetItemConfig():GetTrinket(costume), false)
												else
													player:AddNullCostume(costume)
												end
												data.CharacterCostumesAdded[j] = true
											end
										elseif not piber20HelperMod:isPlayerTrueCoopCharacter(player, playerType, playerName) then
											if costumeType == piber20HelperCostumeType.COLLECTIBLE then
												player:RemoveCostume(Isaac:GetItemConfig():GetCollectible(costume))
											elseif costumeType == piber20HelperCostumeType.TRINKET then
												player:RemoveCostume(Isaac:GetItemConfig():GetTrinket(costume))
											else
												player:TryRemoveNullCostume(costume)
											end
											data.CharacterCostumesAdded[j] = false
										end
									end
								end
							end
						end
					end
				end
			end
			
			--for use with forceCostumeWithCollectible
			if #collectibleCostumes >= 1 then
				if data.CollectibleCostumesAdded == nil then
					data.CollectibleCostumesAdded = {}
				end
				for j = 1, #collectibleCostumes do
					if collectibleCostumes[j] then
						if collectibleCostumes[j].ID then
							if collectibleCostumes[j].Costume then
								if collectibleCostumes[j].Type then
									local collectible = collectibleCostumes[j].ID
									local costume = collectibleCostumes[j].Costume
									local costumeType = collectibleCostumes[j].Type
									if not data.CollectibleCostumesAdded[j] then
										if player:HasCollectible(collectible) then
											if costumeType == piber20HelperCostumeType.COLLECTIBLE then
												player:AddCostume(Isaac:GetItemConfig():GetCollectible(costume), false)
											elseif costumeType == piber20HelperCostumeType.TRINKET then
												player:AddCostume(Isaac:GetItemConfig():GetTrinket(costume), false)
											else
												player:AddNullCostume(costume)
											end
											data.CollectibleCostumesAdded[j] = true
										end
									elseif not player:HasCollectible(collectible) then
										if costumeType == piber20HelperCostumeType.COLLECTIBLE then
											player:RemoveCostume(Isaac:GetItemConfig():GetCollectible(costume))
										elseif costumeType == piber20HelperCostumeType.TRINKET then
											player:RemoveCostume(Isaac:GetItemConfig():GetTrinket(costume))
										else
											player:TryRemoveNullCostume(costume)
										end
										data.CollectibleCostumesAdded[j] = false
									end
								end
							end
						end
					end
				end
			end
			
			--for use with forceCostumeWithTrinket
			if #trinketCostumes >= 1 then
				if data.TrinketCostumesAdded == nil then
					data.TrinketCostumesAdded = {}
				end
				for j = 1, #trinketCostumes do
					if trinketCostumes[j] then
						if trinketCostumes[j].ID then
							if trinketCostumes[j].Costume then
								if trinketCostumes[j].Type then
									local trinket = trinketCostumes[j].ID
									local costume = trinketCostumes[j].Costume
									local costumeType = trinketCostumes[j].Type
									if not data.TrinketCostumesAdded[j] then
										if player:HasTrinket(trinket) then
											if costumeType == piber20HelperCostumeType.COLLECTIBLE then
												player:AddCostume(Isaac:GetItemConfig():GetCollectible(costume), false)
											elseif costumeType == piber20HelperCostumeType.TRINKET then
												player:AddCostume(Isaac:GetItemConfig():GetTrinket(costume), false)
											else
												player:AddNullCostume(costume)
											end
											data.TrinketCostumesAdded[j] = true
										end
									elseif not player:HasTrinket(trinket) then
										if costumeType == piber20HelperCostumeType.COLLECTIBLE then
											player:RemoveCostume(Isaac:GetItemConfig():GetCollectible(costume))
										elseif costumeType == piber20HelperCostumeType.TRINKET then
											player:RemoveCostume(Isaac:GetItemConfig():GetTrinket(costume))
										else
											player:TryRemoveNullCostume(costume)
										end
										data.TrinketCostumesAdded[j] = false
									end
								end
							end
						end
					end
				end
			end
			
			--for use with forceCostumeWithActiveItem
			if #activeItemCostumes >= 1 then
				if data.ActiveItemCostumesAdded == nil then
					data.ActiveItemCostumesAdded = {}
				end
				for j = 1, #activeItemCostumes do
					if activeItemCostumes[j] then
						if activeItemCostumes[j].ID then
							if activeItemCostumes[j].Costume then
								if activeItemCostumes[j].Type then
									local activeItem = activeItemCostumes[j].ID
									local costume = activeItemCostumes[j].Costume
									local costumeType = activeItemCostumes[j].Type
									if not data.ActiveItemCostumesAdded[j] then
										if piber20HelperMod:didPlayerUseActiveItem(player, activeItem) then
											if costumeType == piber20HelperCostumeType.COLLECTIBLE then
												player:AddCostume(Isaac:GetItemConfig():GetCollectible(costume), false)
											elseif costumeType == piber20HelperCostumeType.TRINKET then
												player:AddCostume(Isaac:GetItemConfig():GetTrinket(costume), false)
											else
												player:AddNullCostume(costume)
											end
											data.ActiveItemCostumesAdded[j] = true
										end
									elseif not piber20HelperMod:didPlayerUseActiveItem(player, activeItem) then
										if costumeType == piber20HelperCostumeType.COLLECTIBLE then
											player:RemoveCostume(Isaac:GetItemConfig():GetCollectible(costume))
										elseif costumeType == piber20HelperCostumeType.TRINKET then
											player:RemoveCostume(Isaac:GetItemConfig():GetTrinket(costume))
										else
											player:TryRemoveNullCostume(costume)
										end
										data.ActiveItemCostumesAdded[j] = false
									end
								end
							end
						end
					end
				end
			end
			
			--for use with forceCostumeWithCard
			if #cardCostumes >= 1 then
				if data.CardCostumesAdded == nil then
					data.CardCostumesAdded = {}
				end
				for j = 1, #cardCostumes do
					if cardCostumes[j] then
						if cardCostumes[j].ID then
							if cardCostumes[j].Costume then
								if cardCostumes[j].Type then
									local card = cardCostumes[j].ID
									local costume = cardCostumes[j].Costume
									local costumeType = cardCostumes[j].Type
									if not data.CardCostumesAdded[j] then
										if piber20HelperMod:didPlayerUseCard(player, card) then
											if costumeType == piber20HelperCostumeType.COLLECTIBLE then
												player:AddCostume(Isaac:GetItemConfig():GetCollectible(costume), false)
											elseif costumeType == piber20HelperCostumeType.TRINKET then
												player:AddCostume(Isaac:GetItemConfig():GetTrinket(costume), false)
											else
												player:AddNullCostume(costume)
											end
											data.CardCostumesAdded[j] = true
										end
									elseif not piber20HelperMod:didPlayerUseCard(player, card) then
										if costumeType == piber20HelperCostumeType.COLLECTIBLE then
											player:RemoveCostume(Isaac:GetItemConfig():GetCollectible(costume))
										elseif costumeType == piber20HelperCostumeType.TRINKET then
											player:RemoveCostume(Isaac:GetItemConfig():GetTrinket(costume))
										else
											player:TryRemoveNullCostume(costume)
										end
										data.CardCostumesAdded[j] = false
									end
								end
							end
						end
					end
				end
			end
			
			--for use with forceCostumeWithPillEffect
			if #pillEffectCostumes >= 1 then
				if data.PillEffectCostumesAdded == nil then
					data.PillEffectCostumesAdded = {}
				end
				for j = 1, #pillEffectCostumes do
					if pillEffectCostumes[j] then
						if pillEffectCostumes[j].ID then
							if pillEffectCostumes[j].Costume then
								if pillEffectCostumes[j].Type then
									local pillEffect = pillEffectCostumes[j].ID
									local costume = pillEffectCostumes[j].Costume
									local costumeType = pillEffectCostumes[j].Type
									if not data.PillEffectCostumesAdded[j] then
										if piber20HelperMod:didPlayerUsePillEffect(player, pillEffect) then
											if costumeType == piber20HelperCostumeType.COLLECTIBLE then
												player:AddCostume(Isaac:GetItemConfig():GetCollectible(costume), false)
											elseif costumeType == piber20HelperCostumeType.TRINKET then
												player:AddCostume(Isaac:GetItemConfig():GetTrinket(costume), false)
											else
												player:AddNullCostume(costume)
											end
											data.PillEffectCostumesAdded[j] = true
										end
									elseif not piber20HelperMod:didPlayerUsePillEffect(player, pillEffect) then
										if costumeType == piber20HelperCostumeType.COLLECTIBLE then
											player:RemoveCostume(Isaac:GetItemConfig():GetCollectible(costume))
										elseif costumeType == piber20HelperCostumeType.TRINKET then
											player:RemoveCostume(Isaac:GetItemConfig():GetTrinket(costume))
										else
											player:TryRemoveNullCostume(costume)
										end
										data.PillEffectCostumesAdded[j] = false
									end
								end
							end
						end
					end
				end
			end
		end
		
		--for use with schedule
		if #functionsToCallInOnUpdate >= 1 then
			for i = 1, #functionsToCallInOnUpdate do
				if functionsToCallInOnUpdate[i].Frame then
					local frame = functionsToCallInOnUpdate[i].Frame
					if functionsToCallInOnUpdate[i].Delay then
						local delay = functionsToCallInOnUpdate[i].Delay
						local frameToCall = frame + delay
						if Isaac.GetFrameCount() >= frameToCall then
							functionsToCallInOnUpdate[i].Frame = nil
							functionsToCallInOnUpdate[i].Delay = nil
							if functionsToCallInOnUpdate[i].Function then
								local arg1 = functionsToCallInOnUpdate[i].Arg1
								local arg2 = functionsToCallInOnUpdate[i].Arg2
								local arg3 = functionsToCallInOnUpdate[i].Arg3
								local arg4 = functionsToCallInOnUpdate[i].Arg4
								local arg5 = functionsToCallInOnUpdate[i].Arg5
								local arg6 = functionsToCallInOnUpdate[i].Arg6
								local arg7 = functionsToCallInOnUpdate[i].Arg7
								local arg8 = functionsToCallInOnUpdate[i].Arg8
								local arg9 = functionsToCallInOnUpdate[i].Arg9
								
								functionsToCallInOnUpdate[i].Function(_, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
							end
						end
					end
				end
			end
			local clearTable = true
			for i = 1, #functionsToCallInOnUpdate do
				if functionsToCallInOnUpdate[i].Frame then
					if functionsToCallInOnUpdate[i].Delay then
						if functionsToCallInOnUpdate[i].Function then
							clearTable = false
						end
					end
				end
			end
			if clearTable then
				functionsToCallInOnUpdate = {}
			end
		end
		
		--pickup restocking
		if #pickupToRestock >= 1 then
			for i = 1, #pickupToRestock do
				if pickupToRestock[i] ~= nil then
					if pickupToRestock[i].Position ~= nil then
						local position = pickupToRestock[i].Position
						if pickupToRestock[i].Variant ~= nil then
							if pickupToRestock[i].SubType ~= nil then
								if pickupToRestock[i].Frame ~= nil then
									if pickupToRestock[i].Price ~= nil then
										if Isaac.GetFrameCount() >= pickupToRestock[i].Frame + 60 then
											local respawnedPickup = Game():Spawn(EntityType.ENTITY_PICKUP, pickupToRestock[i].Variant, position, Vector(0,0), nil, pickupToRestock[i].SubType, piber20HelperMod:getRNGNext()):ToPickup()
											Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, position, Vector(0,0), nil, 0, piber20HelperMod:getRNGNext())
											respawnedPickup.Price = pickupToRestock[i].Price
											pickupToRestock[i] = nil
										end
									else
										pickupToRestock[i] = nil
									end
								else
									pickupToRestock[i] = nil
								end
							else
								pickupToRestock[i] = nil
							end
						else
							pickupToRestock[i] = nil
						end
					else
						pickupToRestock[i] = nil
					end
				end
			end
		end
		
		--overlays
		streakUI:Update()
		if streakUI:IsFinished("Text") then
			shouldRenderStreak = false
		end
		
		giantbookUI:Update()
		if giantbookUI:IsFinished(giantbookAnimation) then
			shouldRenderGiantbook = false
		end
		
		achievementUI:Update()
		if achievementUI:IsFinished("Appear") then
			achievementUI:Play("Idle", true)
		end
		if achievementUI:IsPlaying("Idle") then
			if achievementUIDelay > 0 then
				achievementUIDelay = achievementUIDelay - 1
			else
				achievementUIDelay = 0
				achievementUI:Play("Dissapear", true)
			end
		end
		if achievementUI:IsFinished("Dissapear") then
			shouldRenderAchievement = false
		end
	end
	
	function piber20HelperMod:onRender()
		--for use with schedule
		if #functionsToCallInOnRender >= 1 then
			for i = 1, #functionsToCallInOnRender do
				if functionsToCallInOnRender[i].Frame then
					local frame = functionsToCallInOnRender[i].Frame
					if functionsToCallInOnRender[i].Delay then
						local delay = functionsToCallInOnRender[i].Delay
						local frameToCall = frame + delay
						if Isaac.GetFrameCount() >= frameToCall then
							functionsToCallInOnRender[i].Frame = nil
							functionsToCallInOnRender[i].Delay = nil
							if functionsToCallInOnRender[i].Function then
								local arg1 = functionsToCallInOnRender[i].Arg1
								local arg2 = functionsToCallInOnRender[i].Arg2
								local arg3 = functionsToCallInOnRender[i].Arg3
								local arg4 = functionsToCallInOnRender[i].Arg4
								local arg5 = functionsToCallInOnRender[i].Arg5
								local arg6 = functionsToCallInOnRender[i].Arg6
								local arg7 = functionsToCallInOnRender[i].Arg7
								local arg8 = functionsToCallInOnRender[i].Arg8
								local arg9 = functionsToCallInOnRender[i].Arg9
								
								functionsToCallInOnRender[i].Function(_, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
							end
						end
					end
				end
			end
			local clearTable = true
			for i = 1, #functionsToCallInOnRender do
				if functionsToCallInOnRender[i].Frame then
					if functionsToCallInOnRender[i].Delay then
						if functionsToCallInOnRender[i].Function then
							clearTable = false
						end
					end
				end
			end
			if clearTable then
				functionsToCallInOnRender = {}
			end
		end
		
		if MusicManager():GetCurrentMusicID() ~= Music.MUSIC_JINGLE_BOSS then
			--overlays
			local centerPos = piber20HelperMod:getScreenCenterPosition()
			
			if shouldRenderStreak then
				streakPosition = centerPos
				streakPosition.Y = 48
				streakUI:RenderLayer(0, streakPosition)
				
				local streakFrame = streakUI:GetFrame()
				if streakFrame <= 0 then
					streakTextPosition = Vector(-800, 0)
					streakTextScale = Vector(300, 20)
				elseif streakFrame == 1 then
					streakTextPosition = Vector(-639, 0)
					streakTextScale = Vector(260, 36)
				elseif streakFrame == 2 then
					streakTextPosition = Vector(-450, 0)
					streakTextScale = Vector(220, 52)
				elseif streakFrame == 3 then
					streakTextPosition = Vector(-250, 0)
					streakTextScale = Vector(180, 68)
				elseif streakFrame == 4 then
					streakTextPosition = Vector(-70, 0)
					streakTextScale = Vector(140, 84)
				elseif streakFrame == 5 then
					streakTextPosition = Vector(10, 0)
					streakTextScale = Vector(95, 105)
				elseif streakFrame == 6 then
					streakTextPosition = Vector(6, 0)
					streakTextScale = Vector(97, 103)
				elseif streakFrame == 7 then
					streakTextPosition = Vector(3, 0)
					streakTextScale = Vector(98, 102)
				elseif streakFrame == 61 then
					streakTextPosition = Vector(-5, 0)
					streakTextScale = Vector(99, 103)
				elseif streakFrame == 62 then
					streakTextPosition = Vector(-10, 0)
					streakTextScale = Vector(98, 105)
				elseif streakFrame == 63 then
					streakTextPosition = Vector(-15, 0)
					streakTextScale = Vector(96, 108)
				elseif streakFrame == 64 then
					streakTextPosition = Vector(-20, 0)
					streakTextScale = Vector(95, 110)
				elseif streakFrame == 65 then
					streakTextPosition = Vector(144, 0)
					streakTextScale = Vector(136, 92)
				elseif streakFrame == 66 then
					streakTextPosition = Vector(308, 0)
					streakTextScale = Vector(177, 74)
				elseif streakFrame == 67 then
					streakTextPosition = Vector(472, 0)
					streakTextScale = Vector(218, 56)
				elseif streakFrame == 68 then
					streakTextPosition = Vector(636, 0)
					streakTextScale = Vector(259, 38)
				elseif streakFrame >= 69 then
					streakTextPosition = Vector(800, 0)
					streakTextScale = Vector(300, 20)
				else
					streakTextPosition = Vector(0, 0)
					streakTextScale = Vector(100, 100)
				end
				streakFont1:DrawStringScaled(streakText1, streakPosition.X + streakTextPosition.X - (streakFont1:GetStringWidth(streakText1) * 0.5), streakPosition.Y + streakTextPosition.Y - 9, (streakTextScale.X * 0.01), (streakTextScale.Y * 0.01), KColor(1,1,1,1,0,0,0), 0, true)
				streakFont2:DrawStringScaled(streakText2, streakPosition.X + streakTextPosition.X - (streakFont1:GetStringWidth(streakText2) * 0.235), streakPosition.Y + streakTextPosition.Y + 9, (streakTextScale.X * 0.01), (streakTextScale.Y * 0.01), KColor(1,1,1,1,0,0,0), 0, true)
				streakFont2:DrawStringScaled(streakText3, streakPosition.X + streakTextPosition.X - (streakFont1:GetStringWidth(streakText3) * 0.235), streakPosition.Y + streakTextPosition.Y + 21, (streakTextScale.X * 0.01), (streakTextScale.Y * 0.01), KColor(1,1,1,1,0,0,0), 0, true)
			end
			
			if shouldRenderGiantbook then
				giantbookUI:Render(centerPos, Vector(0,0), Vector(0,0))
			end
			
			if shouldRenderAchievement then
				achievementUI:Render(centerPos, Vector(0,0), Vector(0,0))
			end
		end
	end
	
	if not piber20HelperMod.AddedCallback[ModCallbacks.MC_POST_NEW_ROOM] then
		piber20HelperMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, piber20HelperMod.onRoomChange)
		piber20HelperMod.AddedCallback[ModCallbacks.MC_POST_NEW_ROOM] = true
	end
	if not piber20HelperMod.AddedCallback[ModCallbacks.MC_USE_ITEM] then
		piber20HelperMod:AddCallback(ModCallbacks.MC_USE_ITEM, piber20HelperMod.onUseItem)
		piber20HelperMod.AddedCallback[ModCallbacks.MC_USE_ITEM] = true
	end
	if not piber20HelperMod.AddedCallback[ModCallbacks.MC_USE_CARD] then
		piber20HelperMod:AddCallback(ModCallbacks.MC_USE_CARD, piber20HelperMod.onUseCard)
		piber20HelperMod.AddedCallback[ModCallbacks.MC_USE_CARD] = true
	end
	if not piber20HelperMod.AddedCallback[ModCallbacks.MC_USE_PILL] then
		piber20HelperMod:AddCallback(ModCallbacks.MC_USE_PILL, piber20HelperMod.onUsePill)
		piber20HelperMod.AddedCallback[ModCallbacks.MC_USE_PILL] = true
	end
	if not piber20HelperMod.AddedCallback[ModCallbacks.MC_POST_GAME_STARTED] then
		piber20HelperMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, piber20HelperMod.onGameStart)
		piber20HelperMod.AddedCallback[ModCallbacks.MC_POST_GAME_STARTED] = true
	end
	if not piber20HelperMod.AddedCallback[ModCallbacks.MC_POST_UPDATE] then
		piber20HelperMod:AddCallback(ModCallbacks.MC_POST_UPDATE, piber20HelperMod.onUpdate)
		piber20HelperMod.AddedCallback[ModCallbacks.MC_POST_UPDATE] = true
	end
	if not piber20HelperMod.AddedCallback[ModCallbacks.MC_POST_RENDER] then
		piber20HelperMod:AddCallback(ModCallbacks.MC_POST_RENDER, piber20HelperMod.onRender)
		piber20HelperMod.AddedCallback[ModCallbacks.MC_POST_RENDER] = true
	end
end

--piber20HelperMod:ForceError() --this function doesn't exist, we do this to cause an error intentionally