------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
_G._savedEnv = getfenv()
module( "mode_generic_laning", package.seeall )
----------
Utility = require( GetScriptDirectory().."/Utility")
----------

local CurLane = Utility.Lanes[1];
local EyeRange=1200;
local BaseDamage=50;
local AttackRange=150;
local AttackSpeed=0.6;
local LastTiltTime=0.0;

local DamageThreshold=1.0;
local MoveThreshold=1.0;

local BackTimerGen=-1000;

local ShouldPush=false;
local IsCore=false;

local LanePos = 0.0;

local CreepDist=550;

local LaningStates={
	Start=0,
	Moving=1,
	WaitingForCS=2,
	CSing=3,
	WaitingForCreeps=4,
	MovingToPos=5,
	GetReadyForCS=6,
	GettingBack=7,
	MovingToLane=8
}

local LaningState=LaningStates.Moving;

function  OnStart()
	print("Laning!");
	local npcBot=GetBot();
	npcBot.BackTimerGen = -1000;
	
	if DotaTime()>10 and npcBot:GetGold()>50 and GetUnitToLocationDistance(npcBot,GetLocationAlongLane(npcBot.CurLane,0.0))<700 and Utility.NumberOfItems()<=5 then
		npcBot:Action_PurchaseItem("item_tpscroll");
		return;
	end
	
	if npcBot:IsChanneling() or npcBot:IsUsingAbility() then
		return;
	end
		
	local dest=GetLocationAlongLane(npcBot.CurLane,GetLaneFrontAmount(GetTeam(),npcBot.CurLane,true)-0.04);
	if DotaTime()>1 and GetUnitToLocationDistance(npcBot,dest)>1500 then
		Utility.InitPath();
		npcBot.LaningState=LaningStates.MovingToLane;
	end
end

function OnEnd()
end

function GetDesire()
	return 0.1;
end

-------------------------------

local function GetWeakestCreep(creeps)
	npcBot=GetBot();
	
	local weakest=nil;
	local lh=10000;
	
	for _,creep in pairs(creeps) do
		if creep:GetHealth()<lh then
			lh=creep:GetHealth();
			weakest=creep;
		end
	end
	
	return weakest;
end
-------------------------------

local function MovingToLane()
	local npcBot=GetBot();
	
	local dest=GetLocationAlongLane(npcBot.CurLane,GetLaneFrontAmount(GetTeam(),npcBot.CurLane,true)-0.04);
	
	if GetUnitToLocationDistance(npcBot,dest)<300 then
		LaningState=LaningStates.Moving;
		return;
	end
	
	Utility.MoveSafelyToLocation(dest);
end

local function Start()
	local npcBot=GetBot();
	
	if CurLane~= LANE_MID then
		npcBot:Action_MoveToLocation(GetLocationAlongLane(CurLane,0.17));
	else
		npcBot:Action_MoveToLocation(GetLocationAlongLane(CurLane,0.25));
	end
	local AllyCreeps=npcBot:GetNearbyCreeps(EyeRange,false);
	if (#AllyCreeps>0) then
		LaningState=LaningStates.Moving;
	end
end

local function Moving()
	local npcBot=GetBot();


	local frontier = GetLaneFrontAmount(GetTeam(),CurLane,true);
    --local target = GetLaneFrontLocation(GetTeam(),CurLane,0.0);
	
	if (frontier>=LanePos) then
		local target = GetLocationAlongLane(CurLane,Min(1.0,LanePos+0.03));---
		npcBot:Action_MoveToLocation(target);
	else
		local target = GetLocationAlongLane(CurLane,Min(1.0,LanePos-0.03));---
		npcBot:Action_MoveToLocation(target);
	end
	
	local EnemyCreeps=npcBot:GetNearbyCreeps(EyeRange,true);
	
	local nCr=0;
	
	for _,creep in pairs(EnemyCreeps) do
		if Utility.NotNilOrDead(creep) and (string.find(creep:GetUnitName(),"melee")~=nil or string.find(creep:GetUnitName(),"range")~=nil or string.find(creep:GetUnitName(),"siege")~=nil) then
			nCr=nCr+1;
		end
	end
	
	if (nCr>0) then
		LaningState=LaningStates.MovingToPos;
	end
end

local function MovingToPos()
	local npcBot=GetBot();
	
	local EnemyCreeps=npcBot:GetNearbyCreeps(EyeRange,true);
	
	local cpos=GetLaneFrontLocation(Utility.GetOtherTeam(),CurLane,0.0);
	local bpos=GetLocationAlongLane(CurLane,LanePos-0.02);
	
	local dest=Utility.VectorTowards(cpos,bpos,CreepDist);
	
	local rndtilt=RandomVector(200);
	
	dest=dest+rndtilt;
	
	npcBot:Action_MoveToLocation(dest);
	
	LaningState=LaningStates.CSing;
end

local function GetReadyForCS()
	local npcBot=GetBot();
	
	local AllyCreeps=npcBot:GetNearbyCreeps(EyeRange,false);
	local EnemyCreeps=npcBot:GetNearbyCreeps(EyeRange,true);
end

local function WaitingForCS()
end

local function GettingBack()
	local npcBot=GetBot();
	
	local AllyCreeps=npcBot:GetNearbyCreeps(EyeRange,false);
	local AllyTowers=npcBot:GetNearbyTowers(EyeRange,false);
	
	if #AllyCreeps>0 or LanePos<0.18 then
		LaningState=LaningStates.Moving;
		return;
	end
	
--	if #AllyTowers>0 then
--		npcBot:Action_MoveToLocation(AllyTowers[1]:GetLocation());
--		return;
--	end
	
	npcBot:Action_MoveToLocation(GetLocationAlongLane(CurLane,Max(LanePos-0.03,0.0)));
end

local function DenyNearbyCreeps()
	local npcBot=GetBot();

	local AllyCreeps=npcBot:GetNearbyCreeps(EyeRange,false);
	if AllyCreeps==nil or #AllyCreeps==0 then
		return false;
	end
	
	local WeakestCreep=GetWeakestCreep(AllyCreeps);
	
	if WeakestCreep==nil then
		return false;
	end

	local damage = (npcBot:GetEstimatedDamageToTarget( true, WeakestCreep, AttackSpeed, DAMAGE_TYPE_PHYSICAL ))*DamageThreshold; 
		
	if damage>WeakestCreep:GetHealth() and Utility.GetDistance(npcBot:GetLocation(),WeakestCreep:GetLocation())<AttackRange then
		npcBot:Action_AttackUnit(WeakestCreep,true);
		return true;
	end

	return false;
end

local function DenyCreeps()
	local npcBot=GetBot();

	local AllyCreeps=npcBot:GetNearbyCreeps(EyeRange,false);
	if AllyCreeps==nil or #AllyCreeps==0 then
		return false;
	end
	
	local WeakestCreep=GetWeakestCreep(AllyCreeps);

	local damage = (npcBot:GetEstimatedDamageToTarget( true, WeakestCreep, AttackSpeed, DAMAGE_TYPE_PHYSICAL ) +(6*#AllyCreeps))*DamageThreshold; 
	local mt = (2.2*damage + (#AllyCreeps)*15 - AttackRange/5) * MoveThreshold;
	
	if WeakestCreep==nil then
		return false;
	end
		
	if damage>WeakestCreep:GetHealth() then
		npcBot:Action_AttackUnit(WeakestCreep,true);
		return true;
	end
		
	if mt>WeakestCreep:GetHealth() then
		local dest=Utility.VectorTowards(WeakestCreep:GetLocation(),GetLocationAlongLane(CurLane,LanePos-0.03),AttackRange-20) + RandomVector(75);
		
		npcBot:Action_MoveToLocation(dest);
		return true;
	end

	return false;
end

local function PushCS(WeakestCreep,nAc,damage,AS)
	local npcBot=GetBot();
	
	if WeakestCreep:GetHealth()>damage and WeakestCreep:GetHealth()<damage + 17*nAc*AS and nAc>1 then
		return;
	end
	
	npcBot:Action_AttackUnit(WeakestCreep,true);
end

local function CSing()
	local npcBot=GetBot();
	
	local AllyCreeps=npcBot:GetNearbyCreeps(EyeRange,false);
	local EnemyCreeps=npcBot:GetNearbyCreeps(EyeRange,true);
	
	if (AllyCreeps==nil) or (#AllyCreeps==0) then
		LaningState=LaningStates.GettingBack;
		return;
	end
	
	if (EnemyCreeps==nil) or (#EnemyCreeps==0) then
		LaningState=LaningStates.Moving;
		return;
	end	
	
	
--	BaseDamage=npcBot:GetBaseDamage()+(Utility.GetHeroLevel()-1)*DamageDelta;
	AttackRange=npcBot:GetAttackRange();
	AttackSpeed=npcBot:GetAttackPoint();
	
	
	local damage = 0;
	
	local AlliedHeroes = npcBot:GetNearbyHeroes(EyeRange,false,BOT_MODE_NONE);
	local Enemies=npcBot:GetNearbyHeroes(EyeRange,true,BOT_MODE_NONE);
	
	local NoCoreAround=true;
	for _,hero in pairs(AlliedHeroes) do
		if Utility.IsCore(hero) then
			NoCoreAround=false;
		end
	end

	local mt=0;
	
	
--	print(DamageThreshold);


	if (IsCore or (NoCoreAround and (Enemies==nil or #Enemies<2))) then
		local WeakestCreep=GetWeakestCreep(EnemyCreeps);
		local nAc=0;
		if WeakestCreep~=nil then
			for _,acreep in pairs(AllyCreeps) do
				if Utility.NotNilOrDead(acreep) and GetUnitToUnitDistance(acreep,WeakestCreep)<120 then
					nAc=nAc+1;
				end
			end
		end
		
		damage = (npcBot:GetEstimatedDamageToTarget( true, WeakestCreep, npcBot:GetSecondsPerAttack(), DAMAGE_TYPE_PHYSICAL ) + (20*nAc) * (AttackSpeed + AttackRange/5000)) * DamageThreshold; 
		mt = (50 + damage + nAc*40 * (GetUnitToUnitDistance(npcBot,WeakestCreep)-AttackRange)/npcBot:GetCurrentMovementSpeed()) * MoveThreshold;
		
--		print(npcBot:GetUnitName());
--		print(damage,mt);
	
		if ShouldPush and WeakestCreep~=nil and string.find(npcBot:GetUnitName(),'zuus')==nil then
			PushCS(WeakestCreep,nAc,damage,AttackSpeed);
			return;
		end
		
		if WeakestCreep~=nil and (damage>WeakestCreep:GetHealth() or (nAc==0 and GetUnitToUnitDistance(WeakestCreep,npcBot)<npcBot:GetAttackRange()) and mt>WeakestCreep:GetHealth()) then
			npcBot:Action_AttackUnit(WeakestCreep,true);
			return;
		end
		
		if (not ShouldPush) and mt>WeakestCreep:GetHealth() then
			local dest=Utility.VectorTowards(WeakestCreep:GetLocation(),GetLocationAlongLane(CurLane,LanePos-0.03),AttackRange-20)+RandomVector(75);
			npcBot:Action_MoveToLocation(dest);
			return;
		end
	
		if not ShouldPush then
			if DenyNearbyCreeps() then
				return;
			end
		end
	elseif not NoCoreAround then
		
		if not ShouldPush then
			if DenyCreeps() then
				return;
			end
		end
	end
	
	LaningState=LaningStates.MovingToPos;
end

local function WaitingForCreeps()
end

--------------------------------

local States = {
[LaningStates.Start]=Start,
[LaningStates.Moving]=Moving,
[LaningStates.WaitingForCS]=WaitingForCS,
[LaningStates.CSing]=CSing,
[LaningStates.MovingToPos]=MovingToPos,
[LaningStates.WaitingForCreeps]=WaitingForCreeps,
[LaningStates.GetReadyForCS]=GetReadyForCS,
[LaningStates.GettingBack]=GettingBack,
[LaningStates.MovingToLane]=MovingToLane
}

----------------------------------

local function Updates()
	local npcBot=GetBot();

	if npcBot.LanePos~=nil then
		LanePos = npcBot.LanePos;
	else
		LanePos = Utility.PositionAlongLane(CurLane);
	end
	
	if npcBot.CreepDist~=nil then
		CreepDist = npcBot.CreepDist;
	end
	
	if npcBot.IsCore==nil then
		IsCore=Utility.IsCore(npcBot);
	else
		IsCore=npcBot.IsCore;
	end
	
	if npcBot.CurLane==nil then
		CurLane=npcBot:GetAssignedLane();
	else
		CurLane=npcBot.CurLane;
	end
	
	if npcBot.LaningState~=nil then
		LaningState=npcBot.LaningState;
	end
	
	if npcBot.MoveThreshold~=nil then
		MoveThreshold=npcBot.MoveThreshold;
	end
	
	if npcBot.DamageThreshold~=nil then
		DamageThreshold=npcBot.DamageThreshold;
	end
	
	if npcBot.ShouldPush~=nil then
		ShouldPush=npcBot.ShouldPush;
	end
	
	if ((not(npcBot:IsAlive())) or (LanePos<0.15 and LaningState~=LaningStates.Start)) then
		LaningState=LaningStates.Moving;
	end
end

local function GetBackGen()
	local npcBot=GetBot();
	
	
	if npcBot.BackTimerGen==nil then
		npcBot.BackTimerGen=-1000;
		return false;
	end
	
	if DotaTime()-npcBot.BackTimerGen<1 then
		return true;
	end
	
	local EnemyDamage=0;
	local Enemies = npcBot:GetNearbyHeroes(1200,true,BOT_MODE_NONE);
	if Enemies==nil or #Enemies==0 then
		return false;
	end
	
	local AllyTowers=npcBot:GetNearbyTowers(600,false);
	if AllyTowers~=nil and #AllyTowers>0 and (#Enemies==nil or #Enemies<=3) then
		return false;
	end
	
	for _,enemy in pairs(Enemies) do
		if Utility.NotNilOrDead(enemy) then
			local damage=enemy:GetEstimatedDamageToTarget(true,npcBot,4,DAMAGE_TYPE_ALL);
			EnemyDamage=EnemyDamage+damage;
		end
	end
	
	if EnemyDamage*0.7 > npcBot:GetHealth() then
		npcBot.BackTimerGen=DotaTime();
		return true;
	end
	
	if EnemyDamage > npcBot:GetHealth() and npcBot:TimeSinceDamagedByAnyHero()<2 then
		npcBot.BackTimerGen=DotaTime();
		return true;
	end
	
	EnemyDamage=0;
	local TotStun=0;
	
	for _,enemy in pairs(Enemies) do
		if Utility.NotNilOrDead(enemy) then
			TotStun=TotStun + Min(enemy:GetStunDuration(true)*0.85 + enemy:GetSlowDuration(true)*0.5,3);
		end
	end
	
	for _,enemy in pairs(Enemies) do
		if Utility.NotNilOrDead(enemy) then
			local damage=enemy:GetEstimatedDamageToTarget(true,npcBot,TotStun,DAMAGE_TYPE_ALL);
			EnemyDamage=EnemyDamage+damage;
		end
	end
	
	if EnemyDamage > npcBot:GetHealth() then
		npcBot.BackTimerGen=DotaTime();
		return true;
	end
	
	npcBot.BackTimerGen= -1000;
	return false;
end

local function StayBack()
	local npcBot=GetBot();
	
	local LaneFront=GetLaneFrontAmount(GetTeam(),npcBot.CurLane,true);
	local LaneEnemyFront=GetLaneFrontAmount(GetTeam(),npcBot.CurLane,false);
	
	local BackPos=GetLocationAlongLane(npcBot.CurLane,Min(LaneFront-0.05,LaneEnemyFront-0.05)) + RandomVector(200);
	npcBot:Action_MoveToLocation(BackPos);
end

function Think()
	local npcBot=GetBot();
	
--	print(npcBot:GetUnitName(),npcBot:GetAttackPoint(),GetLaneFrontLocation(GetTeam(),LANE_BOT,0.0),GetLaneFrontAmount(GetTeam(),LANE_BOT,true));

	Updates();
	
	if npcBot:IsUsingAbility() or npcBot:IsChanneling() then
		return;
	end
	
	if GetBackGen() and LaningState~=LaningStates.MovingToLane then
		StayBack();
		return;
	end
	
	States[LaningState]();
	
	npcBot.LaningState=LaningState;
end


--------
for k,v in pairs( mode_generic_laning ) do	_G._savedEnv[k] = v end
