------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
_G._savedEnv = getfenv()
module( "mode_generic_attack", package.seeall )
----------
Utility = require( GetScriptDirectory().."/Utility")
----------

local MinScore=0.0;
local MinHp=0.4;

function  OnStart()
	local npcBot=GetBot();
	
	if npcBot.Target==nil then
		npcBot.IsAttacking=false;
		npcBot.MyDamage=0;
		return;
	end
	
	npcBot:Action_Chat("Trying to kill "..npcBot.Target:GetUnitName(),false);
	npcBot.IsAttacking=true;
end

function OnEnd()
	local npcBot=GetBot();
	npcBot.IsAttacking=false;
end

function GetDesire()
	local npcBot=GetBot();
	
	if npcBot:GetHealth()/npcBot:GetMaxHealth()<MinHp then ---and (Utility.GetHeroLevel()~=nil or Utility.GetHeroLevel() <5)
		npcBot.IsAttacking=false;
		npcBot.Target=nil;
		npcBot.MyDamage=0;
		return 0.0;
	end
	
	if npcBot.IsAttacking==nil then
		npcBot.IsAttacking=false;
		npcBot.Target=nil;
		npcBot.MyDamage=0;
	end
	
	local WeakestHero=nil;
	local Score=0;
	local Damage=0;
	
	WeakestHero,Damage,Score = Utility.FindTarget(1400);
	npcBot.Target=WeakestHero;
	npcBot.MyDamage=Damage;
	npcBot.AttackScore=Score;
	
	if (not Utility.NotNilOrDead(WeakestHero)) or (not WeakestHero:CanBeSeen()) then
		npcBot.IsAttacking=false;
		npcBot.Target=nil;
		npcBot.MyDamage=0;
		return 0.0;
	end
	
--	print(npcBot:GetUnitName(),Damage,Score,WeakestHero:GetUnitName());
	
	if npcBot.IsAttacking then
		if npcBot.ShouldPush~=nil and npcBot.ShouldPush then
			return 0.6;
		end
		return 0.5;
	end

	local AlliesScore=Score;
	local AlliesDamage=Damage;
	
	if npcBot.AttackScore<MinScore then
		npcBot.IsAttacking=false;
		npcBot.Target=nil;
		npcBot.MyDamage=0;
		return 0.0;
	end
	
	for i=1,5,1 do
		local Ally=GetTeamMember(GetTeam(),i);
		if Utility.NotNilOrDead(Ally) and Ally.Target~=nil and Ally.Target:GetUnitName()==npcBot:GetUnitName() and GetUnitToUnitDistance(Ally,Target)<1200 and Ally:GetHealth()/Ally:GetMaxHealth()>MinHp then
			AlliesScore=AlliesScore+Ally.AttackScore;
			AlliesDamage=AlliesDamage+Ally.MyDamage;
		end
	end
	
	if AlliesDamage > npcBot.Target:GetHealth() and AlliesScore>1 then
		npcBot.IsAttacking=true;
		if npcBot.ShouldPush~=nil and npcBot.ShouldPush then
			return 0.6;
		end
		return 0.5;
	end
	
	return 0.0;
end

function Think()
	local npcBot=GetBot();
	
	local AlliesScore=npcBot.AttackScore;
	local AlliesDamage=npcBot.MyDamage;
	
	if (npcBot.Target==nil or (not npcBot.Target:CanBeSeen())) then
		return;
	end
	
	for i=1,5,1 do
		local Ally=GetTeamMember(GetTeam(),i);
		if Utility.NotNilOrDead(Ally) and Ally.Target~=nil and Ally.Target:GetUnitName()==npcBot:GetUnitName() and GetUnitToUnitDistance(Ally,Target)<1200  and Ally:GetHealth()/Ally:GetMaxHealth()>MinHp  then
			AlliesScore=AlliesScore+Ally.AttackScore;
			AlliesDamage=AlliesDamage+Ally.MyDamage;
		end
	end
	
	if AlliesScore<0.7 or npcBot.Target:GetHealth()>AlliesDamage then
		npcBot.IsAttacking=false;
		return;
	end
end

--------
for k,v in pairs( mode_generic_attack ) do	_G._savedEnv[k] = v end
