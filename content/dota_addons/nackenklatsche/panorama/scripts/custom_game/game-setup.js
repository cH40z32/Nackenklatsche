
function CheckForHostPrivileges()
{
	$.Msg("check");
	var playerInfo = Game.GetLocalPlayerInfo();
	if ( !playerInfo )
	{
		$.Schedule(0.5, function()
		{
			CheckForHostPrivileges();
		});
		return false;
	}
		
	$.GetContextPanel().SetHasClass( "player_has_host_privileges", playerInfo.player_has_host_privileges );
	$.GetContextPanel().SetHasClass( "animation_started", true );
	
	
	
	return playerInfo.player_has_host_privileges;

}


function SetRespawnTime()
{ 
if(CheckForHostPrivileges())
	GameEvents.SendCustomGameEventToServer( "set_respawn_time", { value: $("#DropDownRespawnTime").Children()[0].text})
}

function SetStartingGold()
{
	if(CheckForHostPrivileges())
	GameEvents.SendCustomGameEventToServer( "set_starting_gold", { value: $("#DropDownStartingGold").Children()[0].text})

}


function SetStartingLevel()
{
	if(CheckForHostPrivileges())
	GameEvents.SendCustomGameEventToServer( "set_starting_level", { value: $("#DropDownStartingLevel").Children()[0].text})
}

(function()
{
	$.Msg("check1");
		$.Schedule(0.5, function()
		{
			CheckForHostPrivileges();
		});
	$.Msg("check2");
})();