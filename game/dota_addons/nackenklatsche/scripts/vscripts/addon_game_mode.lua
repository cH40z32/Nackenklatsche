-- Generated from template
_G.RespawnTime = 10
_G.StartingLevel = 1
_G.StartingGold = 500

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
  
    
  GameRules:GetGameModeEntity().NackenklatscheGameMode = self


  GameRules:SetCustomGameSetupTimeout( 60 )
  
  GameRules:SetPreGameTime(31)

  GameRules:SetFirstBloodActive(true)
  GameRules:SetStartingGold(0)
  
  ListenToGameEvent( "entity_killed", Dynamic_Wrap( NackenklatscheGameMode, 'OnEntityKilled' ), self )
  ListenToGameEvent("dota_player_pick_hero", SetPoints, nil)
  
  
  CustomGameEventManager:RegisterListener( "set_respawn_time", Dynamic_Wrap(NackenklatscheGameMode, 'SetRespawnTime'))
  CustomGameEventManager:RegisterListener( "set_starting_gold", Dynamic_Wrap(NackenklatscheGameMode, 'SetStartingGold'))
  CustomGameEventManager:RegisterListener( "set_starting_level", Dynamic_Wrap(NackenklatscheGameMode, 'SetStartingLevel'))
  CustomGameEventManager:RegisterListener( "apply_settings", Dynamic_Wrap(NackenklatscheGameMode, 'ApplySettings'))

  NackenklatscheGameMode:OnGameInProgress()
end



function NackenklatscheGameMode:SetRespawnTime( hero )
	hero:SetTimeUntilRespawn( RespawnTime  )
end

function NackenklatscheGameMode:OnHeroKilled( hero )
	NackenklatscheGameMode:SetRespawnTime( hero )
end

function NackenklatscheGameMode:OnHeroKill( hero )

end


---------------------------------------------------------------------------
-- Event: OnEntityKilled
---------------------------------------------------------------------------
function NackenklatscheGameMode:OnEntityKilled( event )
	local killedUnit = EntIndexToHScript( event.entindex_killed )

	local attackinghero = EntIndexToHScript( event.entindex_attacker )
	
	if attackinghero:IsRealHero() then
		NackenklatscheGameMode:OnHeroKill( attackinghero )
	end
	
	if killedUnit:IsRealHero() then
		NackenklatscheGameMode:OnHeroKilled( killedUnit )
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
    local repeat_interval = 30 -- Rerun this timer every *repeat_interval* game-time seconds
    local start_after = 30 -- Start this timer *start_after* game-time seconds later

    Timers:CreateTimer(start_after, function()
        NackenklatscheGameMode:SpawnCreeps()
        return repeat_interval
    end)
end

function NackenklatscheGameMode:SpawnCreeps()
    local point = Entities:FindByName( nil, "spawnerino"):GetAbsOrigin()
    local unit = CreateUnitByName("sheep", point, true, nil, nil, DOTA_TEAM_NEUTRALS)
end