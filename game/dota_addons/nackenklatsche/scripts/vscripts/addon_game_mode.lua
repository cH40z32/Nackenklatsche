-- Generated from template
_G.RespawnTime = 10
_G.StartingLevel = 1
_G.StartingGold = 500
_G.DireRoshanAlive = false
_G.RadientRoshanAlive = false
_G.RoshanRespawnInterval = 240
_G.ItemsToDrop =
  {
    "item_baseballer",
    "item_messer",
    "item_gas_wumme"
  }
require('lib/timers')

if NackenklatscheGameMode == nil then
  NackenklatscheGameMode = class({})
end

function Precache( context )
--[[



		Precache things we know we'll use.  Possible file types include (but not limited to):



			PrecacheResource( "model", "*.vmdl", context )



			PrecacheResource( "soundfile", "*.vsndevts", context )



			PrecacheResource( "particle", "*.vpcf", context )



			PrecacheResource( "particle_folder", "particles/folder", context )



	]]
end

-- Create the game mode when we activate
function Activate()
  NackenklatscheGameMode:InitGameMode()

end

function SetPoints(keys)
  local hero = EntIndexToHScript(keys.heroindex)

  if hero:IsHero() then
    print("Adding Ability Points to Hero")
    local playerId=hero:GetPlayerID()
    hero:SetGold(tonumber(StartingGold),true);

    for variable = 1, StartingLevel - 1 , 1 do
      hero:HeroLevelUp(true)
    end
  else
    print("Not A Hero")
  end
end 


function NackenklatscheGameMode:InitGameMode()
  print( "Template addon is loaded." )
	-- local levelTable = {}
	-- local xpAmount = 10
	-- levelTable[0] = 0 -- XP table requires a leading 0
	-- for i=1,199 do
					-- levelTable[i] = xpAmount
					-- xpAmount = xpAmount + 10
					-- print( string.format( "%s %s", i, xpAmount ) )
	-- end
	
	-- GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)
	-- GameRules:GetGameModeEntity():SetCustomHeroMaxLevel(99)
	-- GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel( levelTable )

  GameRules:GetGameModeEntity().NackenklatscheGameMode = self
 

  GameRules:SetCustomGameSetupTimeout( 60 )

  GameRules:SetPreGameTime(31)

  GameRules:SetFirstBloodActive(true)
  GameRules:SetStartingGold(0)
  

 
  ListenToGameEvent( "entity_killed", Dynamic_Wrap( NackenklatscheGameMode, 'OnEntityKilled' ), self )
  ListenToGameEvent("dota_player_pick_hero", SetPoints, nil)
  ListenToGameEvent( "dota_item_picked_up", Dynamic_Wrap( NackenklatscheGameMode, "OnItemPickUp"), self )

  CustomGameEventManager:RegisterListener( "set_respawn_time", Dynamic_Wrap(NackenklatscheGameMode, 'SetRespawnTime'))
  CustomGameEventManager:RegisterListener( "set_starting_gold", Dynamic_Wrap(NackenklatscheGameMode, 'SetStartingGold'))
  CustomGameEventManager:RegisterListener( "set_starting_level", Dynamic_Wrap(NackenklatscheGameMode, 'SetStartingLevel'))
  CustomGameEventManager:RegisterListener( "apply_settings", Dynamic_Wrap(NackenklatscheGameMode, 'ApplySettings'))

  NackenklatscheGameMode:OnGameInProgress()
end



function NackenklatscheGameMode:AdjustetRespawnTime( hero )
  hero:SetTimeUntilRespawn( RespawnTime  )
end

function NackenklatscheGameMode:OnHeroKilled( hero )
  NackenklatscheGameMode:AdjustetRespawnTime( hero )
end

function NackenklatscheGameMode:OnHeroKill( hero )

end


---------------------------------------------------------------------------
-- Event: OnEntityKilled
---------------------------------------------------------------------------
function NackenklatscheGameMode:OnEntityKilled( event )
  local killedUnit = EntIndexToHScript( event.entindex_killed )

  local attackinghero = EntIndexToHScript( event.entindex_attacker )

  if killedUnit:GetUnitName() == "npc_dire_roshan" then
	DireRoshanAlive = false
    NackenklatscheGameMode:TreasureDrop( killedUnit )
  else
	  if killedUnit:GetUnitName() == "npc_radient_roshan" then
		RadientRoshanAlive = false
		NackenklatscheGameMode:TreasureDrop( killedUnit )
	  else
		if attackinghero:IsRealHero() then
		  NackenklatscheGameMode:OnHeroKill( attackinghero )
		end

		if killedUnit:IsRealHero() then
		  NackenklatscheGameMode:OnHeroKilled( killedUnit )
		end
	  end
  end
end



function NackenklatscheGameMode:SetRespawnTime( event )
  print( "SetRespawnTime to " .. event.value)
  _G.RespawnTime = event.value
end

function NackenklatscheGameMode:SetStartingGold(event )
  print( "SetStartingGold to " .. event.value)
  _G.StartingGold = event.value

end

function NackenklatscheGameMode:SetStartingLevel( event )
  print( "SetStartingLevel to " .. event.value)
  _G.StartingLevel = event.value
end



function NackenklatscheGameMode:OnGameInProgress()

  Timers:CreateTimer(RoshanRespawnInterval, function()
    NackenklatscheGameMode:SpawnRadientRoshan()
    return RoshanRespawnInterval
  end)
  
  Timers:CreateTimer(RoshanRespawnInterval, function()
    NackenklatscheGameMode:SpawnDireRoshan()
    return RoshanRespawnInterval
  end)
end  

function NackenklatscheGameMode:SpawnRadientRoshan()
	if RadientRoshanAlive == false then
	  local point = Entities:FindByName( nil, "radient_roshan_spawner"):GetAbsOrigin()
	  local unit = CreateUnitByName("npc_radient_roshan", point, true, nil, nil, DOTA_TEAM_NEUTRALS)
	  RadientRoshanAlive=true
    end
end


function NackenklatscheGameMode:SpawnDireRoshan()
	if DireRoshanAlive == false then
	  local point = Entities:FindByName( nil, "dire_roshan_spawner"):GetAbsOrigin()
	  local unit = CreateUnitByName("npc_dire_roshan", point, true, nil, nil, DOTA_TEAM_NEUTRALS)
	  DireRoshanAlive=true
	end
end


--------------------------------------------------------------------------------
-- Event: OnItemPickUp
--------------------------------------------------------------------------------
function NackenklatscheGameMode:OnItemPickUp( event )
  local item = EntIndexToHScript( event.ItemEntityIndex )
  local owner = EntIndexToHScript( event.HeroEntityIndex )
  r = 300
  --r = RandomInt(200, 400)
  if event.itemname == "item_bag_of_gold" then
    --print("Bag of gold picked up")
    PlayerResource:ModifyGold( owner:GetPlayerID(), r, true, 0 )
    SendOverheadEventMessage( owner, OVERHEAD_ALERT_GOLD, owner, r, nil )
    UTIL_Remove( item ) -- otherwise it pollutes the player inventory
  elseif event.itemname == "item_treasure_chest" then
    --print("Special Item Picked Up")
    NackenklatscheGameMode:SpecialItemAdd( event )
    UTIL_Remove( item ) -- otherwise it pollutes the player inventory
  end
end



function NackenklatscheGameMode:SpecialItemAdd( event )
  local item = EntIndexToHScript( event.ItemEntityIndex )
  local owner = EntIndexToHScript( event.HeroEntityIndex )
  local hero = owner:GetClassname()
  local ownerTeam = owner:GetTeamNumber()

  local tableindex = 0

  self.tier1ItemBucket={}
  local itemToSpawn = PickRandomShuffle( _G.ItemsToDrop, self.tier1ItemBucket )


  -- add the item to the inventory and broadcast
  owner:AddItemByName( itemToSpawn )
  EmitGlobalSound("powerup_04")
  local overthrow_item_drop =
    {
      hero_id = hero,
      dropped_item = itemToSpawn
    }
  CustomGameEventManager:Send_ServerToAllClients( "overthrow_item_drop", overthrow_item_drop )
end


function PickRandomShuffle( reference_list, bucket )
  if ( #reference_list == 0 ) then
    return nil
  end

  if ( #bucket == 0 ) then
    -- ran out of options, refill the bucket from the reference
    for k, v in pairs(reference_list) do
      bucket[k] = v
    end
  end

  -- pick a value from the bucket and remove it
  local pick_index = RandomInt( 1, #bucket )
  local result = bucket[ pick_index ]
  table.remove( bucket, pick_index )
  return result
end



function NackenklatscheGameMode:TreasureDrop( treasureCourier )

  --Create the death effect for the courier
  local spawnPoint = treasureCourier:GetAbsOrigin()
  spawnPoint.z = 400

  EmitGlobalSound( "lockjaw_Courier.Impact" )
  EmitGlobalSound( "lockjaw_Courier.gold_big" )

  --Spawn the treasure chest at the selected item spawn location
  local newItem = CreateItem( "item_treasure_chest", nil, nil )
  local drop = CreateItemOnPositionForLaunch( spawnPoint, newItem )
  drop:SetForwardVector( treasureCourier:GetRightVector() ) -- oriented differently
  newItem:LaunchLootInitialHeight( false, 0, 50, 0.25, spawnPoint )

end











