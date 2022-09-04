-- Static
FRAMES_BETWEEN_CHECK = 10
LAST_TIME_DELTA = 0
WORLD_LIMITS = {1,1}
VERSION_WITH_CLASSMETHODCHECK_FUNCTION = "137.15" -- dev version. Update before uploading to steam!!

-- Internal Databases
OBJECTS_IN_FLIGHT = {}
SWITCHES_TURNED_OFF = {} -- key = '>some name'. use pairs().
TIMEOUT_DB = {}

-- Internal Caching
LINK_UIDS = {}
STORAGE_UIDS = {}

-- Multiple Types
BALANCER_TYPES = {'Balancer (SL)', 'Balancer Long (SL)'}
PUMP_TYPES = {'Pump (SL)', 'Pump Long (SL)'}
OVERFLOW_TYPES = {'Overflow Pump (SL)', 'Overflow Pump Long (SL)'}
RECEIVER_TYPES = {'Receiver (SL)'}
TRANSMITTER_TYPES = {'Transmitter (SL)'}

-- Unlock a level when this is built
GOOD_UNLOCK_BUILDINGS = {'MortarMixerCrude', 'MortarMixerGood'}
SUPER_UNLOCK_BUILDINGS = {'MetalWorkbench'}
SECONDS_BETWEEN_UNLOCK_CHECKS = 5
UNLOCK_TIMER_SECOND = 0

-- Levels of speed
CRUDE_CHECKS_PER_SECOND = 0.25
GOOD_CHECKS_PER_SECOND = 1
SUPER_CHECKS_PER_SECOND = 1 -- but we transfer way more per check!

-- Tracking timers (these change with each OnUpdate() call)
CRUDE_TIMER_SECOND = 0
GOOD_TIMER_SECOND = 0
SUPER_TIMER_SECOND = 0
FIVE_SECOND_TIMER = 0


-- Variables that can change
FRAME_COUNTER = 0
DEBUG_ENABLED = false
USE_EVENT_STYLE = false

-- Wishlist
-- OVERFLOW PIPE (/pressure relief) -> when source side is full, move one if possible.
-- Transmitter Priority by name "Priority 1", "Priority 2"... 1 being most important.
-- Receiver Priority "Priority 1", "Priority 2"...etc
-- Priority: - Unprioritized? use level 50.

function SteamDetails()
	
    -- Setting of Steam details
    ModBase.SetSteamWorkshopDetails("Storage Links", [[
A set of links that can hook storages together. This is a great minimal mod.

=== Crude, Good, Super ===
 - Crude _____ are available at all times, can move up to 1 item every 5 seconds.
 - Good _____ are available once a Mortar Mixer is built and can move up to 5 items every second.
 - Super _____ are available once a Steam Hammer is built and can move unlimited items per second.
 - All levels have the capability to be SWITCHED on or off using the 'Super Switch (SL)'

=== Balancer (SL) ===
 - Keeps two storages of similiar type balanced.
 - Long version functions exactly the same.

=== Pump (SL) ===
 - Pumps product into the storage indicated by the arrow.
 - Long version functions exactly the same.
 
=== Overflow Pump (SL) ===
 - Only operates if the source side is at max capacity.
 - Removes the qty as defined below:
 - Crude: 1% (rounded up).
 - Good: 5% (rounded up).
 - Super: 10% (rounded up).
 
=== Receiver (SL) ===
 - Requests and will receive whatever it can of the type that fits into this storage.
 - If there are multiple receivers per type of item stored, the emptiest storage is always dealt with first.
 
=== Transmitter (SL) ===
 - Transmits any requested types, if it can from the attached storage.
 
=== Magnet (SL) ===
 - Attach to a storage. Collects items that fit in storage, within 10x10 around magnet.
 - If you can name the magnet, setting name to '80x80' will collect items 80 tiles wide by 80 tiles tall.
 
=== Switch (SL) ===
 - Name the link you wish to control with a name like "sw[GROUP NAME]" (Use "L" key.).
 - Build the switch anywhere.
 - Name the SWITCH like ">GROUP NAME". (always start with ">")
 - You can only have one switch per group name. (use anything you want for group name)

~~ Future ~~
 - Be able to transfer to/from train carriages. As of 136.24, the Modding API does not support interacting with train carriages.


~= Enjoy =~

	]], {"transport", "storage"}, "logo.jpg")
    
end

function Expose()
	if ModBase.GetGameVersion() == 'Version  136.17.2' or ModBase.GetGameVersion() == 'Version 136.17.2' or ModBase.GetGameVersion() == '136.17.2' then
		return
	end

	ModBase.ExposeVariable("Enable Debug Mode", false, ExposedVariableCallback)
	ModBase.ExposeKeybinding("Debug: Move", 8, ExposedKeyCallback)
end

function ExposedKeyCallback(name)
	if ModBase.GetGameState() ~= 'Normal' then return end
	if (name == 'Debug: Move') then
		locateLinks('Crude')
		locateLinks('Good')
		locateLinks('Super')
	end
end

function ExposedVariableCallback(value, name)
	if (name == 'Enable Debug Mode') then DEBUG_ENABLED = value end
end

function Creation()

	
	-- Pump
	ModBuilding.CreateBuilding("Crude Pump (SL)"	  	, {"Log","Pole"}							   	, {1, 2}	, "PumpCrude" 		, {0,0} , {0,0}, null, true )
	ModBuilding.CreateBuilding("Good Pump (SL)"	  		, {"Mortar","Pole"}					   		   	, {4, 8}   	, "PumpGood" 		, {0,0} , {0,0}, null, true )
	ModBuilding.CreateBuilding("Super Pump (SL)"	  	, {"MetalPlateCrude","MetalPoleCrude","Rivets"}	, {4, 8, 8}	, "PumpSuper"  		, {0,0} , {0,0}, null, true )
	ModBuilding.CreateBuilding("Super Pump Long (SL)"	, {"MetalPlateCrude","MetalPoleCrude","Rivets"}	, {4, 8, 8}	, "PumpSuperLong"  	, {0,0} , {0,0}, null, true )
	
	-- Overflow Pump
	ModBuilding.CreateBuilding("Crude Overflow Pump (SL)"	, {"Log","Pole"}							   	, {1, 2}	, "OverflowCrude" 		, {0,0} , {0,0}, null, true )
	ModBuilding.CreateBuilding("Good Overflow Pump (SL)"	, {"Mortar","Pole"}					   		   	, {4, 8}   	, "OverflowGood" 		, {0,0} , {0,0}, null, true )
	ModBuilding.CreateBuilding("Super Overflow Pump (SL)"	, {"MetalPlateCrude","MetalPoleCrude","Rivets"}	, {4, 8, 8}	, "OverflowSuper"		, {0,0} , {0,0}, null, true )
	
	-- Balancer
	ModBuilding.CreateBuilding("Crude Balancer (SL)"	, {"Log","Pole"}							   	, {1, 2}	, "BalCrude" 		, {0,0} , {0,0}, null, true )
	ModBuilding.CreateBuilding("Good Balancer (SL)"	  	, {"Mortar","Pole"}					   		   	, {4, 8}   	, "BalGood" 		, {0,0} , {0,0}, null, true )
	ModBuilding.CreateBuilding("Super Balancer (SL)"	, {"MetalPlateCrude","MetalPoleCrude","Rivets"}	, {4, 8, 8}	, "BalSuper"		, {0,0} , {0,0}, null, true )
	ModBuilding.CreateBuilding("Super Balancer Long (SL)",{"MetalPlateCrude","MetalPoleCrude","Rivets"}	, {4, 8, 8}	, "BalSuperLong"	, {0,0} , {0,0}, null, true )
	
	-- Transmitter
	ModBuilding.CreateBuilding("Crude Transmitter (SL)"	, {"Log","Pole","TreeSeed"}					  	, {2, 3, 1}	, "TransmitterCrude", {0,0} , {0,0}, null, true )
	ModBuilding.CreateBuilding("Good Transmitter (SL)"	, {"Mortar","Pole","TreeSeed"}				  	, {4, 10, 1}, "TransmitterGood"	, {0,0} , {0,0}, null, true )
	ModBuilding.CreateBuilding("Super Transmitter (SL)"	, {"MetalPlateCrude","MetalPoleCrude","Rivets", "UpgradeWorkerCarrySuper"}, {4, 6, 6, 1}, "TransmitterSuper" 	, {0,0} , {0,0}, null, true )

	-- Receiver
	ModBuilding.CreateBuilding("Crude Receiver (SL)"	, {"Log","Pole","TreeSeed"}						, {2, 3, 1}	, "ReceiverCrude" 	, {0,0} , {0,0}, null, true )
	ModBuilding.CreateBuilding("Good Receiver (SL)"		, {"Mortar","Pole","TreeSeed"}				  	, {4, 10, 1}, "ReceiverGood" 	, {0,0} , {0,0}, null, true )
	ModBuilding.CreateBuilding("Super Receiver (SL)"	, {"MetalPlateCrude","MetalPoleCrude","Rivets", "UpgradeWorkerCarrySuper"}, {4, 6, 6, 1}, "ReceiverSuper"  		, {0,0} , {0,0}, null, true )

	-- Magnet
	ModBuilding.CreateBuilding("Crude Magnet (SL)"		, {"Rock","TreeSeed"}							, {2, 1}	, "MagnetCrude"  	, {0,0} , {0,0}, null, true )
	ModBuilding.CreateBuilding("Good Magnet (SL)"		, {"Rock","StringBall"}							, {4, 3}	, "MagnetGood"  	, {0,0} , {0,0}, null, true )
	ModBuilding.CreateBuilding("Super Magnet (SL)"		, {"MetalPlateCrude","MetalPoleCrude","Rivets", "UpgradeWorkerCarrySuper"}, {2, 2, 4, 1}, "MagnetSuper"  	, {0,0} , {0,0}, null, true )

	-- Switch
	ModBuilding.CreateBuilding("Super Switch (SL)"		, {"MetalPlateCrude","Plank"}					, {1, 3}, "Switch"  	  , {0,0} , {0,0}, null, true )
	ModDecorative.CreateDecorative("Switch On Symbol (SL)", {"TreeSeed",}								, {1}, "SwitchOn"  	  , true )
	
	-- Misc Symbols
	ModDecorative.CreateDecorative("Broken Symbol (SL)"	  , {"TreeSeed"}								, {1}, "BrokenSymbol", true )
	
	-- Buildings that can be walked through
	ModBuilding.SetBuildingWalkable("Super Switch (SL)", true)
	
	-- Discontinuing these names -- here so they show up in existing games
	ModBuilding.CreateBuilding("Storage Pump (SL)"	  		, {"MetalPlateCrude","MetalPoleCrude","Rivets"}	, {4, 8, 8}	, "PumpSuper"  		, {0,0} , {0,0}, null, true )
	ModBuilding.CreateBuilding("Storage Pump XL (SL)"	  	, {"MetalPlateCrude","MetalPoleCrude","Rivets"}	, {4, 8, 8}	, "PumpSuperLong"  	, {0,0} , {0,0}, null, true )
	ModBuilding.CreateBuilding("Storage Transmitter (SL)"	, {"MetalPlateCrude","MetalPoleCrude","Rivets", "UpgradeWorkerCarrySuper"}, {4, 6, 6, 1}, "TransmitterSuper" 	, {0,0} , {0,0}, null, true )
	ModBuilding.CreateBuilding("Storage Receiver (SL)"	  	, {"MetalPlateCrude","MetalPoleCrude","Rivets", "UpgradeWorkerCarrySuper"}, {4, 6, 6, 1}, "ReceiverSuper"  		, {0,0} , {0,0}, null, true )
	ModBuilding.CreateBuilding("Storage Magnet (SL)"		, {"MetalPlateCrude","MetalPoleCrude","Rivets", "UpgradeWorkerCarrySuper"}, {2, 2, 4, 1}, "MagnetSuper"  	, {0,0} , {0,0}, null, true )
	ModBuilding.CreateBuilding("Storage Balancer (SL)"		, {"MetalPlateCrude","MetalPoleCrude","Rivets"}	, {4, 8, 8}	, "BalSuper"		, {0,0} , {0,0}, null, true )
	ModBuilding.CreateBuilding("Storage Balancer XL (SL)"	, {"MetalPlateCrude","MetalPoleCrude","Rivets"}	, {4, 8, 8}	, "BalSuperLong"	, {0,0} , {0,0}, null, true )
	
	-- Set some overall globals that determine if we want to use a TIMER, or callbacks.
	if ModBase.IsGameVersionGreaterThanEqualTo(VERSION_WITH_CLASSMETHODCHECK_FUNCTION) then
		if ModBase.ClassAndMethodExist('ModBuilding','RegisterForBuildingRenamedCallback') then
			USE_EVENT_STYLE = true
		end
	end
	
end

function OnUpdate(timeDelta)
	
	-- Called on every cycle!
	updateFlightPositions()
	everyFrame(timeDelta)
	
	-- Every Five SECONDS_BETWEEN_UNLOCK_CHECKS
	FIVE_SECOND_TIMER = FIVE_SECOND_TIMER + timeDelta
	if FIVE_SECOND_TIMER >= 5 then
		-- discoverUnknownMagnets()
		FIVE_SECOND_TIMER = 0
	end
	
	if DEBUG_ENABLED == false then
	
		--local secondsDiff = timeDelta + LAST_TIME_DELTA
		--LAST_TIME_DELTA = timeDelta -- time is in decimal seconds
		
		-- Update timing trackers
		CRUDE_TIMER_SECOND = CRUDE_TIMER_SECOND + timeDelta
		GOOD_TIMER_SECOND = GOOD_TIMER_SECOND + timeDelta
		SUPER_TIMER_SECOND = SUPER_TIMER_SECOND + timeDelta
		UNLOCK_TIMER_SECOND = UNLOCK_TIMER_SECOND + timeDelta
		
		
		-- Crude Level
		if CRUDE_TIMER_SECOND >= (1 / CRUDE_CHECKS_PER_SECOND) then
			locateLinks('Crude')
			CRUDE_TIMER_SECOND = 0
		end
		
		-- Good Level
		if GOOD_TIMER_SECOND >= (1 / GOOD_CHECKS_PER_SECOND) then
			locateLinks('Good')
			GOOD_TIMER_SECOND = 0
		end
		
		-- Super Level
		if SUPER_TIMER_SECOND >= (1 / SUPER_CHECKS_PER_SECOND) then
			locateLinks('Super')
			SUPER_TIMER_SECOND = 0
		end
		
		-- UnlockCheck
		-- if UNLOCK_TIMER_SECOND >= SECONDS_BETWEEN_UNLOCK_CHECKS then
			-- checkUnlockLevels()
			-- UNLOCK_TIMER_SECOND = 0
		-- end
		
	end
	
end

function BeforeLoad()
	
	-- -- Pump
	-- ModVariable.SetVariableForBuildingUpgrade("Crude Pump (SL)", "Good Pump (SL)" )
	-- ModVariable.SetVariableForBuildingUpgrade("Good Pump (SL)" , "Super Pump (SL)")
	
	-- -- Overflow Pump
	-- ModVariable.SetVariableForBuildingUpgrade("Crude Overflow Pump (SL)", "Good Overflow Pump (SL)" )
	-- ModVariable.SetVariableForBuildingUpgrade("Good Overflow Pump (SL)" , "Super Overflow Pump (SL)")
	
	
	-- -- Balancer
	-- ModVariable.SetVariableForBuildingUpgrade("Crude Balancer (SL)", "Good Balancer (SL)" )
	-- ModVariable.SetVariableForBuildingUpgrade("Good Balancer (SL)" , "Super Balancer (SL)")
	
	-- -- Magnet
	-- ModVariable.SetVariableForBuildingUpgrade("Crude Magnet (SL)", "Good Magnet (SL)" )
	-- ModVariable.SetVariableForBuildingUpgrade("Good Magnet (SL)" , "Super Magnet (SL)")
	
	-- -- Transmitter
	-- ModVariable.SetVariableForBuildingUpgrade("Crude Transmitter (SL)", "Good Transmitter (SL)" )
	-- ModVariable.SetVariableForBuildingUpgrade("Good Transmitter (SL)" , "Super Transmitter (SL)")
	
	-- -- Receiver
	-- ModVariable.SetVariableForBuildingUpgrade("Crude Receiver (SL)", "Good Receiver (SL)" )
	-- ModVariable.SetVariableForBuildingUpgrade("Good Receiver (SL)" , "Super Receiver (SL)")
	
	-- Access Points
	-- ModBuilding.ShowBuildingAccessPoint("Crude Pump (SL)"			, true)
	-- ModBuilding.ShowBuildingAccessPoint("Good Pump (SL)" 			, true)
	-- ModBuilding.ShowBuildingAccessPoint("Crude Overflow Pump (SL)"	, true)
	-- ModBuilding.ShowBuildingAccessPoint("Good Overflow Pump (SL)" 	, true)
	-- ModBuilding.ShowBuildingAccessPoint("Crude Balancer (SL)"		, true)
	-- ModBuilding.ShowBuildingAccessPoint("Good Balancer (SL)"		, true)
	-- ModBuilding.ShowBuildingAccessPoint("Crude Magnet (SL)"			, true)
	-- ModBuilding.ShowBuildingAccessPoint("Good Magnet (SL)"			, true)
	-- ModBuilding.ShowBuildingAccessPoint("Crude Transmitter (SL)"	, true)
	-- ModBuilding.ShowBuildingAccessPoint("Good Transmitter (SL)"		, true)
	-- ModBuilding.ShowBuildingAccessPoint("Crude Receiver (SL)"		, true)
	-- ModBuilding.ShowBuildingAccessPoint("Good Receiver (SL)"		, true)
	
	-- Hide old names
	ModVariable.SetVariableForObjectAsInt("Storage Pump (SL)","Unlocked",0 )
	ModVariable.SetVariableForObjectAsInt("Storage Pump XL (SL)","Unlocked",0 )
	ModVariable.SetVariableForObjectAsInt("Storage Transmitter (SL)","Unlocked",0 )
	ModVariable.SetVariableForObjectAsInt("Storage Receiver (SL)","Unlocked",0 )
	ModVariable.SetVariableForObjectAsInt("Storage Magnet (SL)","Unlocked",0 )
	ModVariable.SetVariableForObjectAsInt("Storage Balancer (SL)","Unlocked",0 )
	ModVariable.SetVariableForObjectAsInt("Storage Balancer XL (SL)","Unlocked",0 )
	
	-- Hide symbols
	ModVariable.SetVariableForObjectAsInt("Switch On Symbol (SL)","Unlocked", 0)
	ModVariable.SetVariableForObjectAsInt("Broken Symbol (SL)"   ,"Unlocked", 0)
	
	--lockLevels()
	checkUnlockLevels()
	
end

function AfterLoad() -- Once a game has loaded key functionality, this is called.
	swapOldNamesToNew()
end

function AfterLoad_CreatedWorld() -- Only called when creating a game. 
	
end

function AfterLoad_LoadedWorld() -- Only called on loading a game.
	lockLevels()
	checkUnlockLevels()
	WORLD_LIMITS = ModTiles.GetMapLimits()
	
	-- Reset caches
	LINK_UIDS = {}
	STORAGE_UIDS = {}
	
	-- When world is loaded, find Magnets!
	discoverUnknownMagnets()
end

function lockLevels()
	ModVariable.SetVariableForObjectAsInt("Good Pump (SL)","Unlocked", 0)
	ModVariable.SetVariableForObjectAsInt("Good Pump Long (SL)","Unlocked", 0)
	ModVariable.SetVariableForObjectAsInt("Good Balancer (SL)","Unlocked", 0)
	ModVariable.SetVariableForObjectAsInt("Good Transmitter (SL)","Unlocked", 0)
	ModVariable.SetVariableForObjectAsInt("Good Receiver (SL)","Unlocked", 0)
	ModVariable.SetVariableForObjectAsInt("Good Magnet (SL)","Unlocked", 0)
	
	-- ModVariable.SetVariableForObjectAsInt("Super Pump (SL)","Unlocked", 0)
	-- ModVariable.SetVariableForObjectAsInt("Super Pump Long (SL)","Unlocked", 0)
	-- ModVariable.SetVariableForObjectAsInt("Super Overflow Pump (SL)","Unlocked", 0)
	-- ModVariable.SetVariableForObjectAsInt("Super Balancer (SL)","Unlocked", 0)
	-- ModVariable.SetVariableForObjectAsInt("Super Balancer Long (SL)","Unlocked", 0)
	-- ModVariable.SetVariableForObjectAsInt("Super Transmitter (SL)","Unlocked", 0)
	-- ModVariable.SetVariableForObjectAsInt("Super Receiver (SL)","Unlocked", 0)
	-- ModVariable.SetVariableForObjectAsInt("Super Magnet (SL)","Unlocked", 0)
	-- ModVariable.SetVariableForObjectAsInt("Super Switch (SL)","Unlocked", 0)
end

function checkUnlockLevels()
	-- Is one of the GOOD_UNLOCK_BUILDINGS built?
	if ModVariable.GetVariableForObjectAsInt('Good Pump (SL)', 'Unlocked') == 0 then
		if isABuildingInTableOnMap(GOOD_UNLOCK_BUILDINGS) then
			ModVariable.SetVariableForObjectAsInt("Good Pump (SL)","Unlocked", 1)
			ModVariable.SetVariableForObjectAsInt("Good Overflow Pump (SL)","Unlocked", 1)
			ModVariable.SetVariableForObjectAsInt("Good Balancer (SL)","Unlocked", 1)
			ModVariable.SetVariableForObjectAsInt("Good Transmitter (SL)","Unlocked", 1)
			ModVariable.SetVariableForObjectAsInt("Good Receiver (SL)","Unlocked", 1)
			ModVariable.SetVariableForObjectAsInt("Good Magnet (SL)","Unlocked", 1)
		end
	end
	
	-- Is one of the SUPER_UNLOCK_BUILDINGS built?
	if ModVariable.GetVariableForObjectAsInt('Super Pump (SL)', 'Unlocked') == 0 then
		if isABuildingInTableOnMap(SUPER_UNLOCK_BUILDINGS) then
			ModVariable.SetVariableForObjectAsInt("Super Pump (SL)","Unlocked", 1)
			ModVariable.SetVariableForObjectAsInt("Super Pump Long (SL)","Unlocked", 1)
			ModVariable.SetVariableForObjectAsInt("Super Overflow Pump (SL)","Unlocked", 1)
			ModVariable.SetVariableForObjectAsInt("Super Balancer (SL)","Unlocked", 1)
			ModVariable.SetVariableForObjectAsInt("Super Balancer Long (SL)","Unlocked", 1)
			ModVariable.SetVariableForObjectAsInt("Super Transmitter (SL)","Unlocked", 1)
			ModVariable.SetVariableForObjectAsInt("Super Receiver (SL)","Unlocked", 1)
			ModVariable.SetVariableForObjectAsInt("Super Magnet (SL)","Unlocked", 1)
			ModVariable.SetVariableForObjectAsInt("Super Switch (SL)","Unlocked", 1)
		end
	end
end

function swapOldNamesToNew()

	-- swapOldNameToNew('Storage Pump (SL)','Super Pump (SL)')
	-- swapOldNameToNew('Storage Pump XL (SL)','Super Pump Long (SL)')
	-- swapOldNameToNew('Storage Transmitter (SL)','Super Transmitter (SL)')
	-- swapOldNameToNew('Storage Receiver (SL)','Super Receiver (SL)')
	-- swapOldNameToNew('Storage Balancer (SL)','Super Balancer (SL)')
	-- swapOldNameToNew('Storage Balancer XL (SL)','Super Balancer Long (SL)')
	
end

function swapOldNameToNew(oldName,newName)
	local oldB = ModTiles.GetObjectsOfTypeInAreaUIDs(oldName, 0, 0, WORLD_LIMITS[1]-1, WORLD_LIMITS[2]-1)
	if oldB == nil or oldB == -1 or oldB[1] == nil or oldB[1] == -1 then return false end
	local props, newUID, rot
	for _, uid in ipairs(oldB) do
		props = ModObject.GetObjectProperties(uid) -- Properties [1]=Type, [2]=TileX, [3]=TileY, [4]=Rotation, [5]=Name,
		rot = ModBulding.GetRotation(uid)
		if ModObject.DestroyObject(uid)	then
			newUID = ModBase.SpawnItem(newName, props[2], props[3], false, true, false)
			if newUID == -1 or newUID == nil then
				ModDebug.Log('Could not re-create the ', props[1], ' @ ', props[2], ':', props[3])
			else
				ModBuilding.SetRotation(newUID, rot)
				ModBuilding.SetBuildingNam(newUID, props[5])
			end
			
		end -- of if object destroyed
	end -- of oldB loop
end

function locateLinks(levelPrefix)
	if ModBase.GetGameState() ~= 'Normal' then return end
	
	setTimeout(locateSwitches,					{levelPrefix},	0	)
	setTimeout(locatePumps,						{levelPrefix},	150	)
	setTimeout(locateOverflowPumps,				{levelPrefix},	300	)
	setTimeout(locateBalancers,					{levelPrefix},	450	)
	setTimeout(locateReceiversAndTransmitters,	{levelPrefix},	600	)
	-- setTimeout(locateMagnets,					{levelPrefix},	750	)
	
	-- new style - this should only look for types that fit in attached storage, in area
	setTimeout(fireAllMagnets,					{levelPrefix},	750	)
end

function locateBalancers(levelPrefix)
	-- Find all Balancers
	local tmpUIDs = {}
	local balancerUIDs = {}
	for _, bType in ipairs(BALANCER_TYPES) do
		tmpUIDs = ModBuilding.GetAllBuildingsUIDsOfType(levelPrefix .. ' ' .. bType, 1, 1, WORLD_LIMITS[1]-1, WORLD_LIMITS[2]-1)
		for _2, tUID in ipairs(tmpUIDs) do
			balancerUIDs[#balancerUIDs+1] = tUID
		end
	end
	--Legacy
	if levelPrefix == 'Super' then
		tmpUIDs = ModBuilding.GetAllBuildingsUIDsOfType('Storage Balancer (SL)', 1, 1, WORLD_LIMITS[1]-1, WORLD_LIMITS[2]-1)
		for _2, tUID in ipairs(tmpUIDs) do
			balancerUIDs[#balancerUIDs+1] = tUID
		end
	end
	-- END Legacy
	-- quit if none
	if balancerUIDs == nil or balancerUIDs[1] == nil or balancerUIDs[1] == -1 then return end
	-- List the balancer's found
	for _, uid in ipairs(balancerUIDs) do
		if DEBUG_ENABLED then ModDebug.Log(' locateBalancers: ', uid ) end
	end
	-- Handle Each Balancer
	for _, uid in ipairs(balancerUIDs)
	do
		locateStoragesForLink(uid,'both', levelPrefix)
	end
end

function locatePumps(levelPrefix)
	-- Find all Pumps
	local tmpUIDs = {}
	local pumpUIDs = {}
	for _, pType in ipairs(PUMP_TYPES) do
		tmpUIDs = ModBuilding.GetAllBuildingsUIDsOfType(levelPrefix .. ' ' .. pType, 1, 1, WORLD_LIMITS[1]-1, WORLD_LIMITS[2]-1)
		for _2, tUID in ipairs(tmpUIDs) do
			pumpUIDs[#pumpUIDs+1] = tUID
		end
	end
	-- LEGACY
	if levelPrefix == 'Super' then
		tmpUIDs = ModBuilding.GetAllBuildingsUIDsOfType('Storage Pump (SL)', 1, 1, WORLD_LIMITS[1]-1, WORLD_LIMITS[2]-1)
		for _2, tUID in ipairs(tmpUIDs) do
			pumpUIDs[#pumpUIDs+1] = tUID
		end
		tmpUIDs = ModBuilding.GetAllBuildingsUIDsOfType('Storage Pump XL (SL)', 1, 1, WORLD_LIMITS[1]-1, WORLD_LIMITS[2]-1)
		for _2, tUID in ipairs(tmpUIDs) do
			pumpUIDs[#pumpUIDs+1] = tUID
		end
	end
	-- END LEGACY
	-- quit if none
	if pumpUIDs == nil or pumpUIDs[1] == nil or pumpUIDs[1] == -1 then return end
	-- List the pumps's found
	for _, uid in ipairs(pumpUIDs) do
		if DEBUG_ENABLED then ModDebug.Log(' locatePumps: ', uid ) end
	end
	-- handle each pump
	for _, uid in ipairs(pumpUIDs)
	do
		if uid ~= -1 then
			locateStoragesForLink(uid,'one', levelPrefix)
		end
	end
end

function locateOverflowPumps(levelPrefix)
	-- Find all Pumps
	local tmpUIDs = {}
	local pumpUIDs = {}
	for _, pType in ipairs(OVERFLOW_TYPES) do
		tmpUIDs = ModBuilding.GetAllBuildingsUIDsOfType(levelPrefix .. ' ' .. pType, 1, 1, WORLD_LIMITS[1]-1, WORLD_LIMITS[2]-1)
		for _2, tUID in ipairs(tmpUIDs) do
			pumpUIDs[#pumpUIDs+1] = tUID
		end
	end
	-- quit if none
	if pumpUIDs == nil or pumpUIDs[1] == nil or pumpUIDs[1] == -1 then return end
	-- List the pumps's found
	for _, uid in ipairs(pumpUIDs) do
		if DEBUG_ENABLED then ModDebug.Log(' locatePumps: ', uid ) end
	end
	-- handle each pump
	for _, uid in ipairs(pumpUIDs)
	do
		if uid ~= -1 then
			locateStoragesForLink(uid, 'one', levelPrefix, true)
		end
	end
end

-- Switches
function locateSwitches(levelPrefix)
	-- Find all Pumps
	local tmpUIDs = {}
	local switchUIDs = {}
	
	tmpUIDs = ModBuilding.GetAllBuildingsUIDsOfType(levelPrefix .. ' Switch (SL)', 1, 1, WORLD_LIMITS[1]-1, WORLD_LIMITS[2]-1)
	for _2, tUID in ipairs(tmpUIDs) do
		switchUIDs[#switchUIDs+1] = tUID
	end
	-- quit if none
	if switchUIDs == nil or switchUIDs[1] == nil or switchUIDs[1] == -1 then return end
	-- List the switches's found
	if DEBUG_ENABLED then
		for _, uid in ipairs(switchUIDs) do ModDebug.Log(' localSwitches: ', uid ) end
	end
	-- handle each of switchUIDs
	for _, switchUID in ipairs(switchUIDs)
	do
		if switchUID ~= -1 then
			determineSwitchTargetState(switchUID, ModPlayer.GetLocation())
		end
	end
end

function determineSwitchTargetState(switchUID, playerXY)
	-- If "farmerPlayer" or "Worker" is on tile, state should be OnUpdate
	-- otherwise OFF.
	local switchProps = ModObject.GetObjectProperties(switchUID) -- [1]=Type, [2]=TileX, [3]=TileY, [4]=Rotation, [5]=Name,
	
	-- Ignore this switch if it's name does not start with ">"
	local ms, me = string.find(switchProps[5],'>.+')
	if ms == nil then return end
	
	-- Do we have multiple with the same name?
	local switchXY = {switchProps[2], switchProps[3]}
	local numBrokenSymbols = ModTiles.GetAmountObjectsOfTypeInArea('Broken Symbol (SL)', switchXY[1], switchXY[2], switchXY[1], switchXY[2])
	local switchesByName = ModBuilding.GetAllBuildingsUIDsFromName(switchProps[5])	
	if switchesByName ~= nil and switchesByName[1] ~= nil and switchesByName[1] ~= -1 and #switchesByName > 1 then
		if numBrokenSymbols == 0 then
			ModBase.SpawnItem('Broken Symbol (SL)', switchXY[1], switchXY[2], false, true, false)
			ModUI.ShowPopup('Oops','Each switch must have a unique name! This switch will be disabled until you rename it.')
		end
		return false
	else
		if numBrokenSymbols > 0 then
			clearTypesInArea('Broken Symbol (SL)', switchXY, switchXY)
		end
	end
	
	-- Are bots or player on tile?
	local numBotsOnTile = ModTiles.GetAmountObjectsOfTypeInArea('Worker', switchXY[1], switchXY[2], switchXY[1], switchXY[2])
	if numBotsOnTile > 0 or (switchXY[1] == playerXY[1] and switchXY[2] == playerXY[2]) then
		setSwitchState(switchUID, switchProps, true)
	else
		setSwitchState(switchUID, switchProps, false)
	end
end

function setSwitchState(switchUID, switchProps, turnOn)
	local xy = {switchProps[2], switchProps[3]}
	local onSymbols = ModTiles.GetAmountObjectsOfTypeInArea('Switch On Symbol (SL)', xy[1], xy[2], xy[1], xy[2])
	
	if turnOn then
		if DEBUG_ENABLED then ModDebug.Log(' switch @ ' .. xy[1]  .. ':' .. xy[2] .. ' is ON.') end
		if onSymbols == 0 then ModBase.SpawnItem('Switch On Symbol (SL)', xy[1], xy[2], false, true, false) end
		if SWITCHES_TURNED_OFF[switchProps[5]] then SWITCHES_TURNED_OFF[switchProps[5]] = nil end
	else
		if DEBUG_ENABLED then ModDebug.Log(' switch @ ' .. xy[1]  .. ':' .. xy[2] .. ' is OFF.') end
		if onSymbols > 0 then clearTypesInArea('Switch On Symbol (SL)', xy, xy) end
		if SWITCHES_TURNED_OFF[switchProps[5]] == nil then SWITCHES_TURNED_OFF[switchProps[5]] = true end
	end
end

function linkIsSwitchedOff(linkName)
	-- Find switches
	if linkName == nil then return false end
	-- extract switchname
	local ms, me = string.find(linkName,'.*sw%[.+%]') -- string.find('sw[48847]','.*sw%[.+%]') = 1, 9
	if ms == nil or me == nil then return false end
	-- assemble switchname
	local switchName = '>' .. string.sub(linkName, ms + 3, me - 1)
	if DEBUG_ENABLED then ModDebug.Log(' linkIsSwitchedOff? ', switchName, ':', SWITCHES_TURNED_OFF[switchName]  ) end
	-- If it does not exist, then we are golden
	if SWITCHES_TURNED_OFF[switchName] == nil then return false end
	-- It must exist
	if DEBUG_ENABLED then ModDebug.Log(' linkIsSwitchedOff: true ' ) end
	return true
end

-- Magnets

function discoverUnknownMagnets()
	locateMagnets('Crude')
	locateMagnets('Good')
	locateMagnets('Super')
end

function locateMagnets(levelPrefix)
	
	-- Create EVENT to catch when new ones are added
	if ModBase.IsGameVersionGreaterThanEqualTo(VERSION_WITH_CLASSMETHODCHECK_FUNCTION) then
		if ModBase.ClassAndMethodExist('ModBuilding','RegisterForBuildingTypeSpawnedCallback') then
			ModBuilding.RegisterForBuildingTypeSpawnedCallback(levelPrefix .. ' Magnet (SL)', onMagnetSpawn)
		end
	end
	
	-- Find all Magnets
	local magnetUIDs = ModBuilding.GetAllBuildingsUIDsOfType(levelPrefix .. ' Magnet (SL)', 0, 0, WORLD_LIMITS[1]-1, WORLD_LIMITS[2]-1)
	
	-- Legacy
	if levelPrefix == 'Super' then
		local oldMagnetUIDs = ModBuilding.GetAllBuildingsUIDsOfType('Storage Magnet (SL)', 0, 0, WORLD_LIMITS[1]-1, WORLD_LIMITS[2]-1)
		if oldMagnetUIDs ~= nil and oldMagnetUIDs[1] ~= -1 and oldMagnetUIDs[1] ~= nil then
			for _, uid in ipairs(oldMagnetUIDs) do
				magnetUIDs[#magnetUIDs + 1] = uid
			end
		end
	end
	-- END Legacy
	
	-- quit if none
	if magnetUIDs == nil or magnetUIDs[1] == nil then return end
	
	-- List the magnets if in debug mode
	if DEBUG_ENABLED then 
		for _, uid in ipairs(magnetUIDs) do ModDebug.Log(' locateMagnets: ', uid ) end
	end
	
	if reset == nil then reset = false end
	
	-- handle each magnet
	for _, uid in ipairs(magnetUIDs)
	do
		if LINK_UIDS[uid] == nil then
			locateStorageForMagnet(uid, levelPrefix)
		end
	end
	
end

function onMagnetSpawn(BuildingUID, BuildingType, IsBlueprint, IsDragging)
	if DEBUG_ENABLED then ModDebug.Log(' ** onMagnetSpawn: ', BuildingUID, ' ',  BuildingType) end
	if IsDragging then return end
	if IsBlueprint then return end
	local levelPrefix = BuildingType:match("(%w+)(.+)")
	locateStorageForMagnet(magUID, levelPrefix)
end

function locateStorageForMagnet(magUID, levelPrefix)
	local storageUID, dir
	local magStorage = {}
	
	-- Cache the Link
	local bType, tileX, tileY, rotation, name = unpack(ModObject.GetObjectProperties(magUID)) -- [1]=Type, [2]=TileX, [3]=TileY, [4]=Rotation, [5]=Name
	rotation = math.floor(rotation + 0.5) -- round the rotation to a whole number
	local dir
	if rotation == 270 	then dir = 'n' end -- the only place for detecting rotation of magnet.
	if rotation == 0	then dir = 'e' end
	if rotation == 90  	then dir = 's' end
	if rotation == 180 	then dir = 'w' end
	local x, y = tileXYFromDir({tileX, tileY}, dir)
	LINK_UIDS[magUID] = {bType=bType, tileX=tileX, tileY=tileY, rotation=rotation, name=name, levelPrefix=levelPrefix, connectToXY={x,y}}
	
	
	if ModBase.IsGameVersionGreaterThanEqualTo(VERSION_WITH_CLASSMETHODCHECK_FUNCTION) then
		-- Make sure we have a callback for when magnet is renamed
		if ModBase.ClassAndMethodExist('ModBuilding','RegisterForBuildingRenamedCallback') then
			ModBuilding.RegisterForBuildingRenamedCallback(magUID, magnetNameUpdated)
		end
		-- Make sure we have a callback for when a magnet is moved / rotated
		if ModBase.ClassAndMethodExist('ModBuilding','RegisterForBuildingRepositionedCallback') then
			ModBuilding.RegisterForBuildingRepositionedCallback(magUID, magnetRepositioned)
		end
		-- And if the magnet is destroyed?
		if ModBase.ClassAndMethodExist('ModBuilding','RegisterForBuildingDestroyedCallback') then
			ModBuilding.RegisterForBuildingDestroyedCallback(magUID, linkDestroyed)
		end
	end
	
	addStorageForMagnet(magUID)
end

function addStorageForMagnet(magUID)
	if DEBUG_ENABLED then ModDebug.Log(' locateStorageForMagnet: magnetRotation: ', rotation ) end
	local storageUID = storageUidOnTileWithCallbacks(LINK_UIDS[magUID].connectToXY[1], LINK_UIDS[magUID].connectToXY[2])
	
	if storageUID == nil then return false end -- no storage there.

	addStorageToMagnet(magUID, storageUID)
end

function addStorageToMagnet(magUID, storageUID)
	if DEBUG_ENABLED then ModDebug.Log(' locateStorageForMagnet: magnetRotation: ', rotation ) end
	local sProps = ModStorage.GetStorageProperties(storageUID)
	
	-- if sProps[2] == nil then return false end -- Was not actually a storage.
	
	-- Cache the storageUID
	local bType, tileX, tileY, rotation, name = unpack(ModObject.GetObjectProperties(storageUID))
	rotation = math.floor(rotation + 0.5) -- round the rotation to a whole number
	-- Create if needed
	if STORAGE_UIDS[storageUID] == nil then STORAGE_UIDS[storageUID] = { linkUIDs = {} } end
	-- Set properties
	STORAGE_UIDS[storageUID].bType 		= bType
	STORAGE_UIDS[storageUID].tileX 		= tileX
	STORAGE_UIDS[storageUID].tileY 		= tileY
	STORAGE_UIDS[storageUID].rotation 	= rotation
	STORAGE_UIDS[storageUID].name 		= name
	STORAGE_UIDS[storageUID].sType 		= sProps[1] -- type stored or NIL if no type yet...
	STORAGE_UIDS[storageUID].linkUIDs	= addToTableIfDoesNotExist(STORAGE_UIDS[storageUID].linkUIDs, magUID) -- each storage might have multiple links of any kind
	
	
	-- Put storage UID in magnets cache.
	LINK_UIDS[magUID].storageUID = storageUID
	magnetNameUpdated(magUID, LINK_UIDS[magUID].name) -- this sets up the area
	
	-- Make sure we have a callback for when the storage is moved/rotated/destroyed
	if ModBase.IsGameVersionGreaterThanEqualTo(VERSION_WITH_CLASSMETHODCHECK_FUNCTION) then
		if ModBase.ClassAndMethodExist('ModBuilding','RegisterForBuildingRepositionedCallback') then
			ModBuilding.RegisterForBuildingRepositionedCallback(storageUID, storageRepositioned)
		end
		if ModBase.ClassAndMethodExist('ModBuilding','RegisterForBuildingDestroyedCallback') then
			ModBuilding.RegisterForBuildingDestroyedCallback(storageUID, storageDestroyed)
		end
		if ModBase.ClassAndMethodExist('ModBuilding','RegisterForStorageItemChangedCallback') then
			ModBuilding.RegisterForStorageItemChangedCallback(storageUID, storageItemChanged)
		end
	end
	
	if DEBUG_ENABLED then ModDebug.Log(' locateStorageForMagnet: sProps[1] ', sProps[1], ' of ', storageUID) end
end

function magnetNameUpdated(magUID, objName)
	if DEBUG_ENABLED then ModDebug.Log(' magnetNameUpdated: magUID: ', magUID, ' : ', objName ) end
	-- Does the magnet exist in the tracker?
	if LINK_UIDS[magUID] == nil then return false end
	
	-- Update in tracker
	LINK_UIDS[magUID].name = objName -- '40x40'
	
	-- Does storageUID exist for magnet?
	if LINK_UIDS[magUID].storageUID == nil then return false end
	
	-- Update area for storage UID!
	-- {left = left, top = top, right = right, bottom = bottom}
	LINK_UIDS[magUID].area = getAreaForMagnetStorage(LINK_UIDS[magUID], STORAGE_UIDS[LINK_UIDS[magUID].storageUID])
end

function magnetRepositioned(MagnetUID, BuildingType, Rotation, TileX, TileY, IsBlueprint, IsDragging)
	if IsDragging then return false end
	if IsBlueprint then return false end
	if DEBUG_ENABLED then ModDebug.Log(' magnetRepositioned: MagnetUID ', MagnetUID) end
	resetCachedLink(MagnetUID) 
end

function fireAllMagnets(levelPrefix)
	if DEBUG_ENABLED then ModDebug.Log(' fireAllMagnets: levelPrefix: ', levelPrefix) end
	-- loop over cached magnets
	for uid, props in pairs(LINK_UIDS) do
		if props.bType == (levelPrefix .. ' Magnet (SL)') then
			if props.storageUID ~= nil then
				-- Is there now a storage there?
			end
			fireMagnetByUID(uid, levelPrefix)
		end
	end
end

function fireMagnetByUID(magnetUID, levelPrefix)
	if DEBUG_ENABLED then ModDebug.Log(' fireMagnetByUID: (a) ', magnetUID) end
	-- looking in area for items that can be picked up.
	if USE_EVENT_STYLE == false then
		updateLinkPropsAsNeeded(magnetUID)
		-- Does it still exist?
		if LINK_UIDS[magnetUID] == nil then return end
		if DEBUG_ENABLED then ModDebug.Log(' fireMagnetByUID: (b) ', magnetUID) end
		-- no more storage attached?
		if LINK_UIDS[magnetUID].storageUID == nil then addStorageForMagnet(magnetUID) end -- Heavy calcs here...
		-- Still no storage? then we quit.
		if LINK_UIDS[magnetUID].storageUID == nil then return end 
		if DEBUG_ENABLED then ModDebug.Log(' fireMagnetByUID: (c) ', magnetUID) end
		-- What if the storage itself moved?
		updateStoragePropsAsNeeded(LINK_UIDS[magnetUID].storageUID)
		if DEBUG_ENABLED then ModDebug.Log(' fireMagnetByUID: (d) ', magnetUID) end
	end
	-- If there are no storages here, exit!
	if LINK_UIDS[magnetUID].storageUID == nil then return end
	-- How many can we put in crate?
	local maxQty = getQtyToGrabForMagnet(magnetUID)
	-- Get them
	findAndCollectHoldablesIntoMagneticStorage(magnetUID, maxQty)
	if DEBUG_ENABLED then ModDebug.Log(' fireMagnetByUID: (g) ', magnetUID) end
end

function getQtyToGrabForMagnet(magnetUID)
	-- LINK_UIDS[magnetUID] = {bType=bType, tileX=tileX, tileY=tileY, rotation=rotation, name=name, levelPrefix=levelPrefix, area={top,left,bottom,right}, storageUID}
	
	-- Figure out how many are already moving through the air, and if that is greater than allowed by the level, then return 0;
	local alreadyFlyingForStorage = listInFlightWithProp('storageUID', LINK_UIDS[magnetUID].storageUID, true)
	local alreadyFlyingQty
	if alreadyFlyingForStorage == nil or alreadyFlyingForStorage[1] == nil then
		alreadyFlyingQty = 0
	else
		alreadyFlyingQty = #alreadyFlyingForStorage
	end
	
	-- query storage for min/max
	local sProps = ModStorage.GetStorageProperties(LINK_UIDS[magnetUID].storageUID)	-- [1]=type-stored, [2] = on-hand, [3] = max-qty, [4] = storage container type
	
	if sProps == nil or sProps == -1 then return 0 end
	if sProps[2] == nil then return 0 end
	if sProps[3] == nil then return 0 end
	
	-- if crate is full, return 0
	if sProps[2] >= sProps[3] then return 0 end
	
	-- Adjust max to be "how many could actually fit into crate"
	local maxQtyToCollect = sProps[3] - sProps[2] - alreadyFlyingQty
	
	-- if qty flying will fill up crate, return 0
	if maxQtyToCollect <= 0 then return 0 end
	
	-- Adjust based on level prefix
	if LINK_UIDS[magnetUID].levelPrefix == 'Crude' then
		maxQtyToCollect = 1
	elseif LINK_UIDS[magnetUID].levelPrefix == 'Good' then
		maxQtyToCollect = 5
	end
	
	return maxQtyToCollect
end

function getAreaForMagnetStorage(magProps, storProps)
	if DEBUG_ENABLED then ModDebug.Log(' getAreaForMagnetStorage: magnet Name: "', magProps.name, '"' ) end
	
	-- Calculate AREA or SIZE from the name. default to 10x10
	local w1, w2 = string.find(magProps.name,'%d+x')
	local h1, h2 = string.find(magProps.name,'x%d+')
	local width  = 10 -- default height
	local height = 10 -- default width
	
	if DEBUG_ENABLED then ModDebug.Log(' getAreaForMagnetStorage: w1 w2: ', w1, ' ', w2 ) end
	if DEBUG_ENABLED then ModDebug.Log(' getAreaForMagnetStorage: h1 h2: ', h1, ' ', h2 ) end
	
	if w1 ~= nil then width  = tonumber(string.sub(magProps.name, w1    , w2 - 1)) end
	if h1 ~= nil then height = tonumber(string.sub(magProps.name, h1 + 1, h2    )) end
	
	local left = storProps.tileX - math.floor(width/2)
	local top = storProps.tileY  - math.floor(height/2)
	local right = left + width
	local bottom = top + height
	
	-- Limit to map limits!!
	if top    < 0 			 	 then top  = 0 					end
	if left   < 0 				 then left = 0 					end
	if bottom > WORLD_LIMITS[2] - 1 then bottom = WORLD_LIMITS[2] - 1 end
	if right  > WORLD_LIMITS[1] - 1 then right  = WORLD_LIMITS[1] - 1 end
	
	if DEBUG_ENABLED then ModDebug.Log(' getAreaForMagnetStorage: area: ', left, ':', top, ', to ', right, ':', bottom ) end
	
	return {left = left, top = top, right = right, bottom = bottom}
end

function findAndCollectHoldablesIntoMagneticStorage(magnetUID, maxQty)
	if DEBUG_ENABLED then ModDebug.Log(' findAndCollectHoldablesIntoMagneticStorage: (a)', table.show(LINK_UIDS[magnetUID].area) ) end
	if LINK_UIDS[magnetUID] == nil then return end
	if STORAGE_UIDS[LINK_UIDS[magnetUID].storageUID] == nil then return end
	
	-- Get all items of sType in area
	local holdables = ModTiles.GetObjectsOfTypeInAreaUIDs(
		STORAGE_UIDS[LINK_UIDS[magnetUID].storageUID].sType,
		LINK_UIDS[magnetUID].area.left,
		LINK_UIDS[magnetUID].area.top,
		LINK_UIDS[magnetUID].area.right,
		LINK_UIDS[magnetUID].area.bottom
	)
	if DEBUG_ENABLED then ModDebug.Log(' findAndCollectHoldablesIntoMagneticStorage: holdables ', holdables ) end
	if DEBUG_ENABLED then ModDebug.Log(' findAndCollectHoldablesIntoMagneticStorage: holdables ', table.show(holdables) ) end
	if holdables == nil or holdables[1] == -1 or #holdables == 0 then return false end
	if DEBUG_ENABLED then ModDebug.Log(' findAndCollectHoldablesIntoMagneticStorage: #holdables ', #holdables ) end
	if maxQty == 0 then
		if DEBUG_ENABLED then ModDebug.Log(' findAndCollectHoldablesIntoMagneticStorage: 0 max qty??? ') end
		return false
	end
	
	local s = STORAGE_UIDS[LINK_UIDS[magnetUID].storageUID]
	for _, uid in ipairs(holdables) 
	do
		if _ > maxQty then return false end -- already requested max Qty
		if OBJECTS_IN_FLIGHT[uid] ~= nil then return false end -- already flying
		if uid ~= -1 then -- Is a valid UID
			ModObject.StartMoveTo(uid, s.tileX, s.tileY, 15, 10)
			OBJECTS_IN_FLIGHT[uid] = { arch=true, wobble=false, storageUID = LINK_UIDS[magnetUID].storageUID, onFlightComplete = onFlightCompleteForMagnets }
			--ModObject.SetObjectActive(uid, false)
			if DEBUG_ENABLED then ModDebug.Log(' findAndCollectHoldablesIntoMagneticStorage: moving! uid:', uid ) end
		end
	end
	
end

function calcQtyToGrabForMagneticStorage(magStorage, levelPrefix)
	-- {storageUID = storageUID, magUID = magUID, linkProps = linkProps, storageProps = storageProps}
	-- storageProps [1]=type-stored, [2] = on-hand, [3] = max-qty, [4] = storage container type
	local alreadyFlyingForStorage = listInFlightWithProp('storageUID', magStorage.storageUID, true)
	local alreadyFlyingQty
	if alreadyFlyingForStorage == nil or alreadyFlyingForStorage[1] == nil then
		alreadyFlyingQty = 0
	else
		alreadyFlyingQty = #alreadyFlyingForStorage
	end
	local maxQtyToCollect = magStorage.storageProps[3] - magStorage.storageProps[2] - alreadyFlyingQty
	
	-- If this is "Crude" or "Good" level
	if levelPrefix == 'Crude' then
		maxQtyToCollect = 1
	elseif levelPrefix == 'Good' then
		maxQtyToCollect = 5
	end
	
	if maxQtyToCollect == 0 then return false end
	
	calcAreaForMagneticStorage(magStorage, maxQtyToCollect, alreadyFlyingForStorage)
end

function calcAreaForMagneticStorage(magStorage, maxQtyToCollect, alreadyFlyingForStorage)
	local stXY = ModObject.GetObjectTileCoord(magStorage.storageUID)
	
	if DEBUG_ENABLED then ModDebug.Log(' calcQtyToGrabForMagneticStorage: magnet Name: "', magStorage.magProps[5], '"' ) end
	
	-- Calculate AREA or SIZE from the name. default to 10x10
	local w1, w2 = string.find(magStorage.magProps[5],'%d+x')
	local h1, h2 = string.find(magStorage.magProps[5],'x%d+')
	local width  = 10 -- default height
	local height = 10 -- default width
	
	if DEBUG_ENABLED then ModDebug.Log(' collectGoodsIntoMagneticStorage: w1 w2: ', w1, ' ', w2 ) end
	if DEBUG_ENABLED then ModDebug.Log(' collectGoodsIntoMagneticStorage: h1 h2: ', h1, ' ', h2 ) end
	
	if w1 ~= nil then width  = tonumber(string.sub(magStorage.magProps[5], w1    , w2 - 1)) end
	if h1 ~= nil then height = tonumber(string.sub(magStorage.magProps[5], h1 + 1, h2    )) end
	
	local left = stXY[1] - math.floor(width/2)
	local top = stXY[2]  - math.floor(height/2)
	local right = left + width
	local bottom = top + height
	
	-- Limit to map limits!!
	if top    < 0 			 	 then top  = 0 					end
	if left   < 0 				 then left = 0 					end
	if bottom > WORLD_LIMITS[2] - 1 then bottom = WORLD_LIMITS[2] - 1 end
	if right  > WORLD_LIMITS[1] - 1 then right  = WORLD_LIMITS[1] - 1 end
	
	if DEBUG_ENABLED then ModDebug.Log(' calcAreaForMagneticStorage: area: ', left, ':', top, ', to ', right, ':', bottom ) end

	collectGoodsIntoMagneticStorage(magStorage, maxQtyToCollect, stXY, {left=left, top=top, right=right, bottom=bottom}, alreadyFlyingForStorage)
end

function collectGoodsIntoMagneticStorage(magStorage, maxQtyToCollect, stXY, area, alreadyFlyingForStorage)
	if DEBUG_ENABLED then ModDebug.Log(' collectGoodsIntoMagneticStorage: (a)' ) end
	
	-- Clip to max area on map
	local pickables = ModTiles.GetObjectsOfTypeInAreaUIDs(magStorage.storageProps[1], area.left, area.top, area.right, area.bottom)
	if pickables == nil or pickables[1] == -1 or #pickables == 0 then return false end
	if DEBUG_ENABLED then ModDebug.Log(' collectGoodsIntoMagneticStorage: #pickables ', #pickables ) end
	
	for _, uid in ipairs(pickables) 
	do
		if _ > maxQtyToCollect then return false end -- done requestiong.
		if hasValue(alreadyFlyingForStorage, uid) == false and uid ~= -1 then -- Not already in flight for area
			ModObject.StartMoveTo(uid, stXY[1], stXY[2], 15, 10)
			OBJECTS_IN_FLIGHT[uid] = { arch=true, wobble=false, storageUID = magStorage.storageUID, onFlightComplete = onFlightCompleteForMagnets }
			if DEBUG_ENABLED then ModDebug.Log(' collectGoodsIntoMagneticStorage: moving! uid:', uid ) end
		end
	end
	
end

function onFlightCompleteForMagnets(flyingUID, ob)
	-- ob has arrived!
	if ModObject.IsValidObjectUID(flyingUID) and ModObject.IsValidObjectUID(ob.storageUID) then -- both UID and storageUID are valid
		-- Use 'AddToStorage' only if it has durability.
		local maxUsage = ModVariable.GetVariableForObjectAsInt(ModObject.GetObjectType(flyingUID),'MaxUsage')
		if maxUsage == nil or maxUsage == 0 then -- No durability, just up storage qty
			local sProps = ModStorage.GetStorageProperties(ob.storageUID) -- [2] = current amount, [3] = max
			if sProps ~= nil and sProps[1] ~= -1 and sProps[2] ~= nil then
				if sProps[2] < 0 then
					sProps[2] = 0
					ModStorage.SetStorageQuantityStored(ob.storageUID, 0)
				end
				ModStorage.SetStorageQuantityStored(ob.storageUID, sProps[2] + 1)
			end
		else-- Durability present, use their method.
			ModStorage.AddToStorage(ob.storageUID, flyingUID) 
		end
	end
	-- still valid?
	if ModObject.IsValidObjectUID(flyingUID) then ModObject.DestroyObject(flyingUID) end -- make sure!
end

-- Caching
function storageRepositioned(StorageUID, BuildingType, Rotation, TileX, TileY, IsBlueprint, IsDragging)
	if IsDragging then return false end
	if IsBlueprint then return false end
	if DEBUG_ENABLED then ModDebug.Log(' storageRepositioned: StorageUID ', StorageUID) end
	resetAttachedLinksCache(StorageUID)
end

function storageDestroyed(StorageUID)
	if DEBUG_ENABLED then ModDebug.Log(' storageDestroyed: StorageUID ', StorageUID) end
	-- Remove callbacks!
	if ModBase.ClassAndMethodExist('ModBuilding','UnegisterForBuildingRenamedCallback') then
		ModBuilding.UnegisterForBuildingRenamedCallback(StorageUID)
	end
	if ModBase.ClassAndMethodExist('ModBuilding','UnegisterForBuildingRepositionedCallback') then
		ModBuilding.UnegisterForBuildingRepositionedCallback(StorageUID)
	end
	if ModBase.ClassAndMethodExist('ModBuilding','UnegisterForBuildingDestroyedCallback') then
		ModBuilding.UnegisterForBuildingDestroyedCallback(StorageUID)
	end
	-- Remove references to it from anywhere in the cache.
	removeStorageUIDFromLinksCache(StorageUID)
end

function linkDestroyed(LinkUID)
	if DEBUG_ENABLED then ModDebug.Log(' linkDestroyed: LinkUID ', LinkUID) end
	if ModObject.IsValidObjectUID(LinkUID) == false then
		removeLinkUIDFromStorageCache(LinkUID)
		LINK_UIDS[LinkUID] = nil
	end
end

function storageItemChanged(StorageUID, NewStoringType)
	if IsDragging then return false end
	if IsBlueprint then return false end
	if DEBUG_ENABLED then ModDebug.Log(' storageItemChanged: StorageUID: ', StorageUID, ' into ', NewStoringType ) end
	
	if STORAGE_UIDS[storageUID] ~= nil then 
		STORAGE_UIDS[storageUID].sType = NewStoringType
	end
end

function updateLinkPropsAsNeeded(uid)
	if ModObject.IsValidObjectUID(uid) == false then
		removeLinkUIDFromStorageCache(uid)
		LINK_UIDS[uid] = nil
		return
	end
	
	local bType, tileX, tileY, rotation, name = unpack(ModObject.GetObjectProperties(uid))
	local newProps = {bType=bType, tileX=tileX, tileY=tileY, rotation=rotation, name=name}
	
	if standardPropsMatch(LINK_UIDS[uid],newProps) == false then 
		resetCachedLink(uid) 
	end
end

function updateStoragePropsAsNeeded(storageUID)
	-- Is this still a valid storage?
	if ModObject.IsValidObjectUID(storageUID) == false then
		removeStorageUIDFromLinksCache(storageUID)
		STORAGE_UIDS[storageUID] = nil
		return
	end
	
	-- Has the storage stayed in the same x and y?
	local bType, tileX, tileY, rotation, name = unpack(ModObject.GetObjectProperties(storageUID))
	local newProps = {bType=bType, tileX=tileX, tileY=tileY, rotation=rotation, name=name}
	
	if storagePropsMatch(STORAGE_UIDS[storageUID],newProps) == false then
		-- storage moved?
		resetAttachedLinksCache(storageUID)
	else
		-- resetAttachedLinksCache resets this, so no reason to check both.
		-- Has it changed type? hate to do this every call!
		local sProps = ModStorage.GetStorageProperties(storageUID)
		if STORAGE_UIDS[storageUID].sType ~= sProps[1] then
			STORAGE_UIDS[storageUID].sType = sProps[1]
		end
	end
	
end

function resetAttachedLinksCache(storageUID)
	if STORAGE_UIDS[storageUID] == nil then return end
	
	-- Local copy of link UID (s) to handle
	local linkUID = STORAGE_UIDS[storageUID].linkUID
	local linkUIDs = STORAGE_UIDS[storageUID].linkUIDs
	
	-- Remove the StorageUID cache object, just in case there were some links partially linked.
	removeStorageUIDFromLinksCache(storageUID)
	
	-- remove it from the cache completely.
	STORAGE_UIDS[storageUID] = nil
	
	if linkUID ~= nil then
		resetCachedLink(linkUID)
	elseif linkUID ~= nil and #linkUID > 0 then 
		for _, lUID in ipairs(linkUIDs) do
			resetCachedLink(lUID)
		end
	end
end

function addStorageToLinksWatchingTile(BuildingUID, TileXY)
	for uid, linkOb in pairs(LINK_UIDS) do
		if linkOb.connectToXY[1] == TileXY[1] and linkOb.connectToXY[2] == TileXY[2] then
			-- Update if magnet
			if string.find(linkOb.bType, "Magnet") ~= nil then
				addStorageToMagnet(uid, BuildingUID) 
			end
		end
	end
end

function resetCachedLink(uid)
	if DEBUG_ENABLED then ModDebug.Log(' resetCachedLink: (a) ', uid) end
	if LINK_UIDS[uid] == nil then return false end
	local levelPrefix = LINK_UIDS[uid].bType:match("(%w+)(.+)")
	if DEBUG_ENABLED then ModDebug.Log(' resetCachedLink: (b) levelPrefix: ', levelPrefix) end
	
	-- Update if magnet
	if string.find(LINK_UIDS[uid].bType, "Magnet") ~= nil then
		removeLinkUIDFromStoragesCache(uid)
		if DEBUG_ENABLED then ModDebug.Log(' resetCachedLink: (c) ', uid) end
		locateStorageForMagnet(uid, levelPrefix) 
	end
end

function removeStorageUIDFromLinksCache(storageUID)
	-- Is there only one?
	if STORAGE_UIDS[storageUID].linkUID ~= nil then
		removeStorageUIDFromLinkCache(STORAGE_UIDS[storageUID].linkUID , storageUID)
	elseif STORAGE_UIDS[storageUID].linkUIDs ~= nil and #STORAGE_UIDS[storageUID].linkUIDs > 0 then 
		for _, lUID in ipairs(STORAGE_UIDS[storageUID].linkUIDs) do
			removeStorageUIDFromLinkCache(lUID, storageUID)
		end
	end
end

function removeStorageUIDFromLinkCache(linkUID, storageUID)
	if LINK_UIDS[linkUID] == nil then return end
	-- only one?
	if LINK_UIDS[linkUID].storageUID ~= nil and LINK_UIDS[linkUID].storageUID == storageUID then
		LINK_UIDS[linkUID].storageUID = nil
	elseif LINK_UIDS[linkUID].storageUIDs ~= nil then
		-- more than one
		for idx, s_uid in ipairs(LINK_UIDS[linkUID].storageUIDs) do
			if s_uid == storageUID then table.remove(LINK_UIDS[linkUID].storageUIDs, idx) end
		end
	end
end

function removeLinkUIDFromStoragesCache(linkUID)
	if DEBUG_ENABLED then ModDebug.Log(' removeLinkUIDFromStoragesCache: (a)', linkUID ) end
	if LINK_UIDS[uid] == nil then return end
	-- Is there only one?
	if LINK_UIDS[uid].storageUID ~= nil then
		removeLinkUIDFromStorageCache(LINK_UIDS[uid].storageUID, linkUID)
	elseif LINK_UIDS[uid].storageUIDs ~= nil and #LINK_UIDS[uid].storageUIDs > 0 then 
		for _, sUID in ipairs(LINK_UIDS[uid].storageUIDs) do
			removeLinkUIDFromStorageCache(sUID, linkUID)
		end
	end
end

function removeLinkUIDFromStorageCache(storageUID, linkUID)
	if STORAGE_UIDS[storageUID] == nil then return end
	-- only one?
	if STORAGE_UIDS[storageUID].linkUID ~= nil and LINK_UIDS[storageUID].linkUID == linkUID then
		STORAGE_UIDS[storageUID].linkUID = nil
	elseif STORAGE_UIDS[storageUID].linkUIDs ~= nil then
		-- more than one?
		for idx, l_uid in ipairs(STORAGE_UIDS[storageUID].linkUIDs) do
			if l_uid == storageUID then table.remove(STORAGE_UIDS[storageUID].linkUIDs, idx) end
		end
	end
end

function standardPropsMatch(oldProps, newProps)
	
	if  	oldProps.bType 		== newProps.bType 
		and oldProps.tileX 		== newProps.tileX 
		and oldProps.tileY 		== newProps.tileY 
		and oldProps.rotation 	== newProps.rotation 
		and oldProps.name 		== newProps.name 
	then 
		return true 
	end
	
	return false
end

function storagePropsMatch(oldProps, newProps)

	if  	oldProps.tileX 		== newProps.tileX 
		and oldProps.tileY 		== newProps.tileY
	then 
		return true 
	end
	
	return false
end

function addToTableIfDoesNotExist(tab, val)
	local found = false
	
	for _, v in ipairs(tab) do
		if v == val then
			found = true
			break
		end
	end
	
	if found then return tab end
	
	tab[#tab + 1] = val
	
	return tab
end

-- Receivers and transmitters
function locateReceiversAndTransmitters(levelPrefix)
	-- Find all receivers
	local tmpUIDs = {}
	
	-- Locate Receivers
	local rUIDs = {}
	for _, rType in ipairs(RECEIVER_TYPES) do
		tmpUIDs = ModBuilding.GetAllBuildingsUIDsOfType(levelPrefix .. ' ' .. rType, 1, 1, WORLD_LIMITS[1]-1, WORLD_LIMITS[2]-1)
		for _2, tUID in ipairs(tmpUIDs) do
			rUIDs[#rUIDs+1] = tUID
		end
	end
	-- Legacy
	if levelPrefix == 'Super' then
		tmpUIDs = ModBuilding.GetAllBuildingsUIDsOfType('Storage Receiver (SL)', 1, 1, WORLD_LIMITS[1]-1, WORLD_LIMITS[2]-1)
		for _2, tUID in ipairs(tmpUIDs) do
			rUIDs[#rUIDs+1] = tUID
		end
	end
	-- END Legacy
	-- quit if no receivers
	if rUIDs == nil or rUIDs[1] == nil then return end
	
	-- Locate Transmitters
	local tUIDs = {}
	for _, tType in ipairs(TRANSMITTER_TYPES) do
		tmpUIDs = ModBuilding.GetAllBuildingsUIDsOfType(levelPrefix .. ' ' .. tType, 1, 1, WORLD_LIMITS[1]-1, WORLD_LIMITS[2]-1)
		for _2, tUID in ipairs(tmpUIDs) do
			tUIDs[#tUIDs+1] = tUID
		end
	end
	-- legacy
	tmpUIDs = ModBuilding.GetAllBuildingsUIDsOfType('Storage Transmitter (SL)', 1, 1, WORLD_LIMITS[1]-1, WORLD_LIMITS[2]-1)
	for _2, tUID in ipairs(tmpUIDs) do
		tUIDs[#tUIDs+1] = tUID
	end
	-- END Legacy
	-- quit if no transmitters
	if tUIDs == nil or tUIDs[1] == nil or tUIDs[1] == -1 then return end
	
	
	-- List the receivers found
	if DEBUG_ENABLED then
		for _, uid in ipairs(rUIDs) do ModDebug.Log(levelPrefix, ' locateReceivers: ', uid ) end
	end
	-- List the transmitters found
	if DEBUG_ENABLED then 
		for _, uid in ipairs(tUIDs) do ModDebug.Log(levelPrefix, ' locateTransmitters: ', uid ) end
	end
	
	locateStoragesForReceiversAndTransmitters(rUIDs, tUIDs, levelPrefix)
end

function locateStoragesForReceiversAndTransmitters(recUIDs, transUIDs, levelPrefix)
	
	local linkProps, linkXY, linkRotation, storageUID, storageProps, dir, props, bOnTile
	local recStorages = {}
	local transStorages = {} -- { linkUID = uid, sUID = storageUID, typeStored='Clay', onHand=23 }
	-- ModObject.GetObjectProperties(uid) -- [1]=Type, [2]=TileX, [3]=TileY, [4]=Rotation, [5]=Nam
	-- ModStorage.GetStorageProperties(uid) -- [1]=Object It Stores, [2]=Amount Stored, [3]=Capacity, [4]=Type Of Storage (Returns [1] as -1 if unassigned storage)
	
	if DEBUG_ENABLED then ModDebug.Log(' locateStoragesForReceiversAndTransmitters (a) ' ) end
	
	-- Find ALL STORAGES for receivers
	for _, uid in ipairs(recUIDs)
	do
		linkProps = ModObject.GetObjectProperties(uid)
		linkXY = ModObject.GetObjectTileCoord(uid)
		linkRotation = math.floor(linkProps[4] + 0.5)
		
		if linkIsSwitchedOff(linkProps[5]) == false then
			if DEBUG_ENABLED then ModDebug.Log(' locateStoragesForReceiversAndTransmitters Receiver @ ', linkXY[1], ':', linkXY[2] ) end
			
			if linkRotation == 180 then dir = 'n' end -- twisted 180 from the transmitters
			if linkRotation == 270 then dir = 'e' end
			if linkRotation == 0   then dir = 's' end
			if linkRotation == 90  then dir = 'w' end
			bOnTile = findStorageOrConverterInDirection(linkXY, dir) -- { kind = "storage/converter", uid = uid, props = props!}
			-- FIXME cmopare two nill values on 808???? so the .props is nill??? hmmmm
			if bOnTile ~= nil then
				if bOnTile.kind == 'storage' and bOnTile.props[2] < bOnTile.props[3] then -- [2] = amountStored, [3] = maxCapacity
					recStorages[#recStorages + 1] = { linkUID = uid, storageUID = bOnTile.uid, typeStored = bOnTile.props[1], storageProps = bOnTile.props, kind = bOnTile.kind }
				elseif bOnTile.kind == 'converter' then
					recStorages[#recStorages + 1] = { linkUID = uid, converterUID = bOnTile.uid, typeStored = '*', storageProps = bOnTile.props, kind = bOnTile.kind  }
				end
			end
		end
	end
	
	-- Find ALL STORAGES for transmitters
	for _, uid in ipairs(transUIDs)
	do
		linkProps = ModObject.GetObjectProperties(uid)
		linkXY = ModObject.GetObjectTileCoord(uid)
		linkRotation = math.floor(linkProps[4] + 0.5)
		
		if linkIsSwitchedOff(linkProps[5]) == false then 
			if DEBUG_ENABLED then ModDebug.Log(' locateStoragesForReceiversAndTransmitters Transmitter @ ', linkXY[1], ':', linkXY[2] ) end
			
			if linkRotation == 0   then dir = 'n' end
			if linkRotation == 90  then dir = 'e' end
			if linkRotation == 180 then dir = 's' end
			if linkRotation == 270 then dir = 'w' end
			storageUID = findStorageInDirection(linkXY, dir) -- should be north?
			if storageUID ~= nil then
				storageProps = ModStorage.GetStorageProperties(storageUID)
				if storageProps ~= nil and storageProps[1] ~= -1 and storageProps[2] > 0 then -- [2] = amountStored, [3] = maxCapacity
					transStorages[#transStorages + 1] = { linkUID = uid, storageUID = storageUID, typeStored = storageProps[1], storageProps = storageProps  }
				end
			end
		end
	end
	
	if DEBUG_ENABLED then ModDebug.Log(' #recStorages: ', #recStorages ) end
	if DEBUG_ENABLED then ModDebug.Log(' #transStorages: ', #transStorages ) end
	
	groupReceiversAndTransmitters(recStorages, transStorages, levelPrefix)
end

function groupReceiversAndTransmitters(receivers, transmitters, levelPrefix)
	-- [ { linkUID = uid, storageUID = storageUID, typeStored = storageProps[1], storageProps  } ]
	-- Group by the TYPE of object being stored.
	local recGroups = {}
	local transGroups = {}
	
	-- Group receivers
	for _, rec in ipairs(receivers)
	do
		-- if DEBUG_ENABLED then ModDebug.Log(' groupReceiversAndTransmitters: receiver: ', table.show(rec) ) end
		if recGroups[rec.typeStored] == nil then recGroups[rec.typeStored] = { } end
		recGroups[rec.typeStored][#recGroups[rec.typeStored] + 1] = rec
	end
	
	-- Group transmitters
	for _, trans in ipairs(transmitters)
	do
		-- if DEBUG_ENABLED then ModDebug.Log(' groupReceiversAndTransmitters: trans: ', table.show(trans) ) end
		if transGroups[trans.typeStored] == nil then transGroups[trans.typeStored] = { } end
		transGroups[trans.typeStored][#transGroups[trans.typeStored] + 1] = trans
	end
	
	if DEBUG_ENABLED then ModDebug.Log(' groupReceiversAndTransmitters: recGroups: ', table.show(recGroups) ) end
	if DEBUG_ENABLED then ModDebug.Log(' groupReceiversAndTransmitters: transGroups: ', table.show(transGroups) ) end
	
	-- Are there no receiving groups?
	if next(recGroups) == nil then return false end
	
	-- For each receiving group (Clay, Sticks, TreeSeeds...etc)
	for _, recGroup in pairs(recGroups)
	do
		handleReceiverGroup(recGroup, transGroups, levelPrefix)
	end
end

function handleReceiverGroup(recGroup, transGroups, levelPrefix)
	-- recGroup = [ { linkUID = uid, storageUID = storageUID, typeStored = storageProps[1], storageProps, kind  } ]
	
	if recGroup[1].typeStored == '*' then
		for _, rec in ipairs(recGroup)
		do
			-- For each receiver in the group
			transGroup = handleOneConverterReceiver(rec, transGroups, levelPrefix)
		end
	else
		-- For this recGroup type, are there any transmitting groups that match?
		if transGroups[recGroup[1].typeStored] == nil then return false end
		local transGroup = transGroups[recGroup[1].typeStored]
		
		if DEBUG_ENABLED then ModDebug.Log(' handleReceiverGroup: transGroup: ', table.show(transGroup) ) end
		
		-- SORT the RECEIVERS by onHandQty (small to large)
		recGroup = table.sort(recGroup, compareSmallerOnHandQty)
		
		-- Sort the TRANSMITTERS by onHandQty (large to small)
		transGroup = table.sort(transGroup, compareLargerOnHandQty)
		
		for _, rec in ipairs(recGroup)
		do
			-- For each receiver in the group
			transGroup = handleOneReceiver(rec, transGroup, levelPrefix)
		end
	end -- if this is a normal storage
end

function handleOneConverterReceiver(rec, trxGroups, levelPrefix)

	-- If this is "Crude" or "Good" level
	local levelCap = 10000
	if levelPrefix == 'Crude' then
		levelCap = 1
	elseif levelPrefix == 'Good' then
		levelCap = 5
	end
	
	if linkIsSwitchedOff(rec.storageProps[5]) then return trxGroups end
	
	if DEBUG_ENABLED then ModDebug.Log(' handleOneConverterReceiver(a): trxGroups ', type(trxGroups) ) end
	
	-- Add as many as we can as Ingredients
	trxGroups = addAnyPossibleIngredientsFromTransmittersToConverter(rec, trxGroups, levelPrefix, levelCap)
	if DEBUG_ENABLED then ModDebug.Log(' handleOneConverterReceiver(b): trxGroups ', type(trxGroups) ) end
	-- Add as many as we can as Water
	trxGroups = addWaterFromTransmittersToConverter(rec, trxGroups, levelPrefix, levelCap)
	if DEBUG_ENABLED then ModDebug.Log(' handleOneConverterReceiver(c): trxGroups ',type(trxGroups) ) end
	-- Add as many as we can as Fuel (sort by fuelAmount first)
	trxGroups = addFuelFromTransmittersToConverter(rec, trxGroups, levelPrefix, levelCap)
	if DEBUG_ENABLED then ModDebug.Log(' handleOneConverterReceiver(d): trxGroups ', type(trxGroups) ) end
	return trxGroups
end

function addAnyPossibleIngredientsFromTransmittersToConverter(rec, trxGroups, levelPrefix, levelCap)
	if trxGroups == nil then return nil end
	-- Loop over ingredients within 'Transmitters' and see if any of them can be added via the 'AddIngredient' method.
	local added, ing
	for ingredient, tGrp in pairs(trxGroups) do
		if tGrp[1].storageProps[2] > 0 then
			added = ModConverter.AddIngredientToSpecifiedConverter(rec.converterUID, ingredient)
			if added then
				ing = ingredient
				break
			end
		end
		if added then break end
	end
	
	if added then
		local thisStorageQty = 0
		local qtyAdded = 1
		local doneAdding = false
		-- Grab it from the first in tGrp
		if trxGroups[ing][1].storageProps[2] < 0 then
			trxGroups[ing][1].storageProps[2] = 0
			ModStorage.SetStorageQuantityStored(trxGroups[ing][1].storageUID, 0)
		end
		ModStorage.SetStorageQuantityStored(trxGroups[ing][1].storageUID, trxGroups[ing][1].storageProps[2] - 1)
		-- Reset the props
		trxGroups[ing][1].storageProps = ModStorage.GetStorageProperties(trxGroups[ing][1].storageUID)
		-- resort the trxGroup
		trxGroups[ing] = table.sort(trxGroups[ing], compareLargerOnHandQty)
		-- Now loop and add as many as we can until 
		--	(a) we run out of transmitters, or
		--	(b) we hit levelCap, or
		--	(c) this receiver can't take any more of ing.
		-- Loop over all transmitters/storages in this group
		for _, trxStorage in ipairs(trxGroups[ing]) do
			-- Qty this storage can provide?
			thisStorageQty = trxStorage.storageProps[2]
			-- Loop over the stored qty
			for s = 1, thisStorageQty, 1 do
				if qtyAdded >= levelCap then break end
				if ModConverter.AddIngredientToSpecifiedConverter(rec.converterUID, ing) == false then break end
				-- Remove from storage
				if trxStorage.storageProps[2] <= 0 then trxStorage.storageProps[2] = 0 end
				ModStorage.SetStorageQuantityStored(trxStorage.storageUID, trxStorage.storageProps[2] - 1)
				-- Track how many we've added
				qtyAdded = qtyAdded + 1
			end
			if qtyAdded >= levelCap then break end
			-- reset props for storage we just used up
			trxGroups[ing][_].storageProps = ModStorage.GetStorageProperties(trxGroups[ing][_].storageUID)
		end
		-- resort the trxGroup
		trxGroups[ing] = table.sort(trxGroups[ing], compareLargerOnHandQty)
		
	end
	
	return trxGroups
end

function addWaterFromTransmittersToConverter(rec, trxGroups, levelPrefix, levelCap)
	if trxGroups == nil then return trxGroups end
	-- Can this building take water?
	local buildingProps = ModObject.GetObjectProperties(rec.converterUID)
	local waterAmount = ModVariable.GetVariableForObjectAsInt(buildingProps[1], 'WaterCapacity')
	if waterAmount == nil or waterAmount == 0 then return trxGroups end
	
	-- Are any of the transmitters hooked into water?
	local added
	local qtyTakenFromStorage = 0
	for storedType, trxGrp in pairs(trxGroups) do
		if storedType == 'Water' then
			for _, trx in ipairs(trxGrp) do
				if qtyTakenFromStorage >= levelCap then break end
				for i = trx.storageProps[2], 0, -1 do
					if qtyTakenFromStorage >= levelCap then break end
					added = ModBuilding.AddWater(rec.converterUID, 1)
					if added then 
						trxGroups[storedType][_].storageProps[2] = trx.storageProps[2] - 1
						qtyTakenFromStorage = qtyTakenFromStorage + 1
					else
						trxGroups[storedType] = table.sort(trxGroups[storedType], compareLargerOnHandQty)
						return trxGroups
					end
				end
			end
			trxGroups[storedType] = table.sort(trxGroups[storedType], compareLargerOnHandQty)
		end
	end
	return trxGroups
end

function addFuelFromTransmittersToConverter(rec, trxGroups, levelPrefix, levelCap)
	if trxGroups == nil then return trxGroups end
	-- Is this building set up for fuel?
	-- ModVariable.GetVariableForObjectAsInt(ModObject.GetObjectType(rec.converterUID), )
	
	-- Create mapping of the 'FuelValue' for each of the transmitter storages. (so we can sort)
	local fuelMap = {}
	local fuelAmount 
	for storedType, trxGrp in pairs(trxGroups) do
		fuelAmount = ModVariable.GetVariableForObjectAsInt(storedType, 'Fuel')
		if fuelAmount ~= nil and fuelAmount > 0 then
			fuelMap[#fuelMap+1] = {storedType = storedType, fuelAmount = fuelAmount}
		end
	end
	
	-- Can any be used as fuel?
	if #fuelMap == 0 then return trxGroups end
	
	-- Sort the map of possible fuels, biggest first
	fuelMap = table.sort(fuelMap, function(a,b)
		return a.fuelAmount > b.fuelAmount
	end)
	
	-- ONLY use the 'biggest' fuel.
	
	
	-- Add until we can add no more!
	local fuelType
	local fuelAmountPerItem
	local qtyTakenFromStorages = 0
	for fkey, fuelOb in ipairs(fuelMap) do
		if fkey > 3 then break end -- use top three fuels only
		fuelType = fuelOb.storedType
		fuelAmountPerItem = fuelOb.fuelAmount
		for gkey, trx in ipairs(trxGroups[fuelType]) do -- each transmitter with that fuelType
			if qtyTakenFromStorages >= levelCap then break end
			for i = trx.storageProps[2], 0, -1 do
				if DEBUG_ENABLED then ModDebug.Log(' addFuelFromTransmittersToConverter: loop qtyTakenFromStorages:',qtyTakenFromStorages, ', levelCap:', levelCap) end
				if qtyTakenFromStorages >= levelCap then break end
				if DEBUG_ENABLED then ModDebug.Log(' addFuelFromTransmittersToConverter adding ',fuelAmountPerItem, ' to #', rec.converterUID) end
				if ModBuilding.AddFuel(rec.converterUID, fuelAmountPerItem) == false and ModConverter.AddFuelToSpecifiedConverter(rec.converterUID, fuelAmountPerItem) == false then break end
				trxGroups[fuelType][gkey].storageProps[2] = trx.storageProps[2] - 1
				qtyTakenFromStorages = qtyTakenFromStorages + 1
				if DEBUG_ENABLED then ModDebug.Log(' addFuelFromTransmittersToConverter: total taken ', qtyTakenFromStorages, ', left in trx storage: ', trxGroups[fuelType][gkey].storageProps[2] ) end
			end
			if trxGroups[fuelType][gkey].storageProps[2] <= 0 then trxGroups[fuelType][gkey].storageProps[2] = 0 end
			ModStorage.SetStorageQuantityStored(trx.storageUID, trxGroups[fuelType][gkey].storageProps[2])
		end
		trxGroups[fuelType] = table.sort(trxGroups[fuelType], compareLargerOnHandQty)
	end
	return trxGroups
end

function addAnythingPossibleToColonistHouse(rec, trxGroups, levelPrefix, levelCap)
	if trxGroups == nil then return trxGroups end
	-- Is this a house?
	local typeOfTarget = ModObject.GetObjectType(rec.converterUID)
	if typeOfTarget ~= 'Hut' 
		and typeOfTarget ~= 'BrickHut' 
		and typeOfTarget ~= 'LogCabin' 
		and typeOfTarget ~= 'Mansion' 
		and typeOfTarget ~= 'StoneCottage' 
		and typeOfTarget ~= 'Castle'
	then return trxGroups end
	
	-- ModObject.AddObjectToColonistHouse
	
end

function handleOneReceiver(rec, tGrp, levelPrefix)
	-- rec = { linkUID = 444, storageUID = 111, typeStored = 'Clay', storageProps}
	if tGrp == nil or tGrp[1] == nil then return {} end
	
	-- Skip this receiver if it's the same UID! (no reason to transmit/receive to itself)
	if tGrp[1].storageUID == rec.storageUID then return tGrp end
	
	local originalTransmitterOnHandQty = tGrp[1].storageProps[2]
	
	if DEBUG_ENABLED then ModDebug.Log(' handleOneReceiver: rec: ', table.show(rec) ) end
	
	-- Transfer as many as possible from fullest (first) transmitter.
	calculateQtyToTransfer(tGrp[1].linkUID, tGrp[1].storageProps, rec.storageProps, tGrp[1].storageUID, rec.storageUID, 'one', levelPrefix)
	
	-- Regrab the transmitter storage properties (should have less on-hand now!)
	tGrp[1].storageProps = ModStorage.GetStorageProperties(tGrp[1].storageUID)
	
	if DEBUG_ENABLED then ModDebug.Log(' handleOneReceiver: (a) ' ) end
	
	-- If nothing was transferred, we should drop this like a hot potatoe!
	local qtyTransferred = originalTransmitterOnHandQty - tGrp[1].storageProps[2]
	if qtyTransferred == 0 then return tGrp end
	
	if DEBUG_ENABLED then ModDebug.Log(' handleOneReceiver: (b) ' ) end
	
	-- Prune empty transmitters from list
	local newTransmitterGroup = {}
	for _, t in ipairs(tGrp)
	do
		if t.storageProps[2] > 0 then newTransmitterGroup[#newTransmitterGroup + 1] = t end
	end
	
	-- If there are no more transmitters, drop and run!
	if newTransmitterGroup == nil or newTransmitterGroup[1] == nil then return {} end
	
	if DEBUG_ENABLED then ModDebug.Log(' handleOneReceiver: (c) ' ) end
	
	-- Sort transmitter list again.
	newTransmitterGroup = table.sort(newTransmitterGroup, compareLargerOnHandQty)
	
	-- If receiver is not full, transfer again from fullest (first) transmitter.
	if levelPrefix == 'Super' and rec.storageProps[2] + qtyTransferred < rec.storageProps[3] then
		rec.storageProps = ModStorage.GetStorageProperties(rec.storageUID)
		if DEBUG_ENABLED then ModDebug.Log(' handleOneReceiver: (d.1) {rec} ', table.show(rec) ) end
		if DEBUG_ENABLED then ModDebug.Log(' handleOneReceiver: (d.1) {grp} ', table.show(newTransmitterGroup) ) end
		return handleOneReceiver(rec, newTransmitterGroup, levelPrefix)
	end
	
	if DEBUG_ENABLED then ModDebug.Log(' handleOneReceiver: (d.2) ' ) end
	
	return newTransmitterGroup
end

-- Everything else
function locateStoragesForLink(linkUID,direction, levelPrefix, onlyIfSourceFull)
	if linkUID == -1 then return end
	if DEBUG_ENABLED then ModDebug.Log(' locateStoragesForLink: ', linkUID, ',', direction ) end
	-- direction = 'one' or 'both'.
	local linkXY = ModObject.GetObjectTileCoord(linkUID)
	local linkProp = ModObject.GetObjectProperties(linkUID)	--  [1]=Type, [2]=TileX, [3]=TileY, [4]=Rotation, [5]=Name,
	local rotation = math.floor(linkProp[4] + 0.5) -- 0, 90, 180, 270
	local side1Storage, side2Storage
	local inv
	
	if linkIsSwitchedOff(linkProp[5]) then return false end
	
	if DEBUG_ENABLED then ModDebug.Log(' locateStoragesForLink: checking rotations ', linkUID, ',', direction ) end
	
	if rotation == 90 or rotation == 270 then
		side1Storage = findStorageInDirection(linkXY, 'e')
		side2Storage = findStorageInDirection(linkXY, 'w')
	else
		side1Storage = findStorageInDirection(linkXY, 'n')
		side2Storage = findStorageInDirection(linkXY, 's')
	end
	
	if side1Storage == nil or side2Storage == nil then return end
	
	-- 'one' = pump.
	if direction == 'one' and (rotation == 270 or rotation == 180) then -- with 270 and 0, east/west work, north/south fail
		-- Swap sides
		local side3Storage = side1Storage
		side1Storage = side2Storage
		side2Storage = side3Storage
		side3Storage = nil
	end
	
	checkStorageCompatability(linkUID, side1Storage, side2Storage, direction, levelPrefix, onlyIfSourceFull)
end

function checkStorageCompatability(linkUID, side1Storage, side2Storage, direction, levelPrefix, onlyIfSourceFull)
	if DEBUG_ENABLED then ModDebug.Log(' checkStorageCompatability: ', linkUID, ', ', direction ) end
	-- direction = 'one' or 'both'.
	local side1Prop = ModStorage.GetStorageProperties(side1Storage)
	local side2Prop = ModStorage.GetStorageProperties(side2Storage)
	-- [1]=Object It Stores, [2]=Amount Stored, [3]=Capacity, [4]=Type Of Storage
	
	if DEBUG_ENABLED then ModDebug.Log(' checkStorageCompatability: side1: ', side1Prop[4], '(', side1Prop[1], '), side2: ', side2Prop[4], '(', side2Prop[1], ') ' ) end
	if DEBUG_ENABLED then ModDebug.Log(' checkStorageCompatability: side2: uid(type) ', side2Storage, '(', ModObject.GetObjectType(side2Storage), ')') end
	
	if side1Prop[1] ~= side2Prop[1] then return false end
	
	calculateQtyToTransfer(linkUID, side1Prop, side2Prop, side1Storage, side2Storage, direction, levelPrefix, onlyIfSourceFull)
end

function calculateQtyToTransfer(linkUID, side1Prop, side2Prop, side1Storage, side2Storage, direction, levelPrefix, onlyIfSourceFull)
	if DEBUG_ENABLED then ModDebug.Log(levelPrefix, ' calculateQtyToTransfer: ', linkUID, ',', direction ) end
	-- direction = 'one' or 'both'.
	-- Prop = [1]=Object It Stores, [2]=Amount Stored, [3]=Capacity, [4]=Type Of Storage
	-- If direction == 'one', we go from side1 to side2. Otherwise we can go either way.
	
	local qty1 = side1Prop[2]
	local qty2 = side2Prop[2]
	local max1 = side1Prop[3]
	local max2 = side2Prop[3]
	local qtyTo2 = 0
	
	if qty1 == nil or qty2 == nil then return false end
	
	if direction == 'both' then
		qtyTo2 = math.floor((qty1 - qty2) / 2)
	else
		qtyTo2 = qty1 -- Everything in storage bin 1 (cap it later)
		if qtyTo2 < 0 then return end -- abort, this is a one way transfer, should not be negative!
	end
	
	local levelCap = 5000
	-- If this is "Crude" or "Good" level
	if levelPrefix == 'Crude' then
		levelCap = 1
	elseif levelPrefix == 'Good' then
		levelCap = 5
	end
	
	if onlyIfSourceFull ~= nil and onlyIfSourceFull then
		if qty1 < max1 then return false end
		levelCap = math.ceil(max1 / 10)
	end
	
	if qtyTo2 < 0 then 
		-- Moving stuff from side2 to side1
		local qtyToMove = math.abs(qtyTo2)
		if qtyToMove > levelCap then qtyToMove = levelCap end
		calculateStyleOfTransfer(linkUID, qtyToMove, side2Prop, side1Prop, side2Storage, side1Storage)
	else
		-- Moving stuff from side1 to side2
		if qtyTo2 > levelCap then qtyTo2 = levelCap end
		calculateStyleOfTransfer(linkUID, qtyTo2, side1Prop, side2Prop, side1Storage, side2Storage)
	end
end

function calculateStyleOfTransfer(linkUID, qty, sourceProp, targetProp, sourceUID, targetUID)
	if DEBUG_ENABLED then ModDebug.Log(' calculateStyleOfTransfer: ', linkUID, ', ', qty ) end
	-- Prop = [1]=Object It Stores, [2]=Amount Stored, [3]=Capacity, [4]=Type Of Storage
	-- Can we adjust levels, or do we need to spawn?
	local oType = sourceProp[1]
	local maxUsage = ModVariable.GetVariableForObjectAsInt(oType, 'MaxUsage')
	local targetSpace = targetProp[3] - targetProp[2]
	
	-- Cap the transfer amount to the available space
	if qty > targetSpace then qty = targetSpace end
	
	-- If we aren't transfering anything, abort.
	if qty <= 0 then return end
	
	if DEBUG_ENABLED then ModDebug.Log(' calculateStyleOfTransfer: maxUsage: ', linkUID, ', ', maxUsage ) end
	
	if maxUsage == nil or maxUsage == 0 then
		transferByAdjusting(linkUID, qty, sourceProp, targetProp, sourceUID, targetUID)
	else
		transferBySpawning(linkUID, qty, sourceProp, targetProp, sourceUID, targetUID)
	end
end

-- Here we split. One or the other!
function transferByAdjusting(linkUID, qty, sourceProp, targetProp, sourceUID, targetUID)
	if DEBUG_ENABLED then ModDebug.Log(' transferByAdjusting: link:', linkUID, ', qty:', qty, ', src:', sourceUID, ', dst:', targetUID ) end
	-- Prop = [1]=Object It Stores, [2]=Amount Stored, [3]=Capacity, [4]=Type Of Storage
	local newTargetProp, newSourceProp
	
	-- Correct if current qty < 0!!
	if sourceProp[2] < 0 then
		sourceProp[2] = 0
		ModStorage.SetStorageQuantityStored(sourceUID, 0)
	end
	if targetProp[2] < 0 then
		targetProp[2] = 0
		ModStorage.SetStorageQuantityStored(targetUID, 0)
	end
	
	local newTotalInSrc = sourceProp[2] - qty
	local newTotalInTgt = targetProp[2] + qty
	
	-- Check for new below 0 and above max
	if newTotalInSrc < 0 then return false end -- don't go below 0!!
	if newTotalInTgt > targetProp[3] then return false end -- don't go over max!!
	
	-- Put in target
	if ModStorage.SetStorageQuantityStored(targetUID, newTotalInTgt) then
		if DEBUG_ENABLED then newTargetProp = ModStorage.GetStorageProperties(targetUID) end
		if DEBUG_ENABLED then ModDebug.Log(' transferByAdjusting: dst:', targetUID, ', increased from:', targetProp[2],' to:', targetProp[2] + qty) end
		if DEBUG_ENABLED then ModDebug.Log(' transferByAdjusting: check dst:', targetUID, ', now at:', newTargetProp[2]) end
	
		-- Remove from source
		ModStorage.SetStorageQuantityStored(sourceUID, newTotalInSrc)
		if DEBUG_ENABLED then newSourceProp = ModStorage.GetStorageProperties(sourceUID) end
		if DEBUG_ENABLED then ModDebug.Log(' transferByAdjusting: src:', sourceUID, ', lowered from:', sourceProp[2],' to:', sourceProp[2] - qty) end
		if DEBUG_ENABLED then ModDebug.Log(' transferByAdjusting: check src:', sourceUID, ', now at:', newSourceProp[2]) end
	else
		if DEBUG_ENABLED then ModDebug.Log(' Error transferByAdjusting! SetStorageQty in target faled!') end
		return false
	end
	
	return true
end

function transferBySpawning(linkUID, qty, sourceProp, targetProp, sourceUID, targetUID)
	if DEBUG_ENABLED then ModDebug.Log(' transferBySpawning: ', linkUID, ', ', qty ) end
	-- Prop = [1]=Object It Stores, [2]=Amount Stored, [3]=Capacity, [4]=Type Of Storage
	
	freshUIDs = ModStorage.TakeFromStorage(sourceUID, qty, 1, 1)
	
	for _, freshUID in ipairs(freshUIDs) 
	do
	  -- put in target storage 
	  ModStorage.AddToStorage(targetUID, freshUID)
	  if ModObject.IsValidObjectUID(freshUID) then ModObject.DestroyObject(freshUID) end
    end
end


-- Non flow functions (used multiple times)
function clearTypesInArea(typeName, xy1, xy2)
	local uids = ModTiles.GetObjectsOfTypeInAreaUIDs(typeName, xy1[1], xy1[2], xy2[1], xy2[2])
	if uids ~= nil and uids[1] ~= nil then
		for _, uid in ipairs(uids) do
			if uid ~= -1 and ModObject.IsValidObjectUID(uid) then ModObject.DestroyObject(uid) end
		end
	end
end

function findStorageInDirection(srcXY, dir)
	
	if DEBUG_ENABLED then ModDebug.Log(' findStorageInDirection - checking ', dir, srcXY[1], ':', srcXY[2]) end
	
	local storage, x, y
	
	x, y = tileXYFromDir(srcXY, dir)
	
	storage = storageUidOnTileWithCallbacks(x, y)
	
	-- if dir == 'n' then storage = storageUidOnTile(srcXY[1]	  , srcXY[2] - 1) end
	-- if dir == 's' then storage = storageUidOnTile(srcXY[1]	  , srcXY[2] + 1) end
	-- if dir == 'w' then storage = storageUidOnTile(srcXY[1] - 1, srcXY[2]	) end
	-- if dir == 'e' then storage = storageUidOnTile(srcXY[1] + 1, srcXY[2]	) end
	
	if storage ~= nil then
		return storage
	end
	
	return nil
end

function storageUidOnTileWithCallbacks(x, y)
	local types
	local uids
	local buildingUID
	local found = false
	
	uids = ModTiles.GetObjectUIDsOnTile(x,y)
	for _, uid in ipairs(uids) do
		if ModObject.GetObjectSubcategory(uid) == 'BuildingsStorage' then 
			found = true
			buildingUID = uid
			break
		end
	end

	
	-- if ModTiles.IsSubcategoryOnTile(x,y,'Vehicles') then
		-- -- Check if it is a train carriage?
		-- types = ModTiles.GetObjectTypeOnTile(x, y)
		-- for _, typ in ipairs(types)
		-- do
			-- if string.sub(typ, 1, 8) == 'Carriage' then
				-- uids = ModTiles.GetObjectsOfTypeInAreaUIDs(typ, x, y, x, y)
				-- if uids ~= nil and uids[1] ~= nil and uids[1] ~= -1 then return uids[1] end
			-- end
		-- end
	-- end
	
	-- Callback remove
	if found then
		-- REMOVE any 'watch this tile for storage' callbacks
		if ModBase.IsGameVersionGreaterThanEqualTo(VERSION_WITH_CLASSMETHODCHECK_FUNCTION) then
			if ModBase.ClassAndMethodExist('ModBuilding','UnregisterForNewBuildingInAreaCallback') then
				ModBuilding.UnregisterForNewBuildingInAreaCallback(x, y, x, y)
			end
		end
		return buildingUID
	end
	
	-- Add a callback for that area!
	if ModBase.IsGameVersionGreaterThanEqualTo(VERSION_WITH_CLASSMETHODCHECK_FUNCTION) then
		if ModBase.ClassAndMethodExist('ModBuilding','RegisterForNewBuildingInAreaCallback') then
			ModBuilding.RegisterForNewBuildingInAreaCallback(x, y, x, y, newBuildingInArea)
		end
	end

	return nil
end

function storageUidOnTile(x,y)
	
	local types
	local uids
	local buildingUID
	
	
	buildingUID = ModBuilding.GetBuildingCoveringTile(x, y) -- excludes floor, walls, and entrence,exits.
	if ModObject.IsValidObjectUID(buildingUID) then
		if ModObject.GetObjectSubcategory(buildingUID) == 'BuildingsStorage' then
			return buildingUID
		else
			-- uids = ModTiles.GetObjectUIDsOnTile(x,y)
			-- for _, uid in ipairs(uids) do
			-- 	if ModObject.GetObjectSubcategory(uid) == 'BuildingsStorage' then return uid end
			-- end
		end
	end

	
	-- if ModTiles.IsSubcategoryOnTile(x,y,'Vehicles') then
		-- -- Check if it is a train carriage?
		-- types = ModTiles.GetObjectTypeOnTile(x, y)
		-- for _, typ in ipairs(types)
		-- do
			-- if string.sub(typ, 1, 8) == 'Carriage' then
				-- uids = ModTiles.GetObjectsOfTypeInAreaUIDs(typ, x, y, x, y)
				-- if uids ~= nil and uids[1] ~= nil and uids[1] ~= -1 then return uids[1] end
			-- end
		-- end
	-- end
	
	return nil
end

function findStorageOrConverterInDirection(srcXY, dir)
	
	if DEBUG_ENABLED then ModDebug.Log(' findStorageOrConverterInDirection - checking ', dir, srcXY[1], ':', srcXY[2]) end
	
	local building
	
	if dir == 'n' then building = storageOrConverterUidOnTile(srcXY[1]	  , srcXY[2] - 1) end
	if dir == 's' then building = storageOrConverterUidOnTile(srcXY[1]	  , srcXY[2] + 1) end
	if dir == 'w' then building = storageOrConverterUidOnTile(srcXY[1] - 1, srcXY[2]	) end
	if dir == 'e' then building = storageOrConverterUidOnTile(srcXY[1] + 1, srcXY[2]	) end
	
	if building ~= nil then return building end
	
	return nil
	
end

function storageOrConverterUidOnTile(x,y)
	
	local types
	local uids
	local buildingUID, buildingXY
	
	buildingUID = ModBuilding.GetBuildingCoveringTile(x, y) -- excludes floor, walls, and entrence,exits.
	if ModObject.IsValidObjectUID(buildingUID) then
		buildingXY = ModObject.GetObjectTileCoord(buildingUID)
	end
	
	if buildingXY ~= nil and ModTiles.IsSubcategoryOnTile(buildingXY[1], buildingXY[2], 'BuildingsStorage') then
		-- Find the real storage UID
		local uidsOnTile = ModTiles.GetObjectUIDsOnTile(buildingXY[1], buildingXY[2])
		for _, uid in ipairs(uidsOnTile) do
			if uid == -1 then break end
			local props = ModStorage.GetStorageProperties(uid)	
			if props ~= nil and props[1] ~= -1 then
				return { kind = 'storage', uid = uid,  props = props }
			end
		end
		
	end
	
	if ModBase.IsGameVersionGreaterThanEqualTo('137.22') then
		if ModObject.IsValidObjectUID(buildingUID) and buildingXY ~= nil then
			local cProps = ModConverter.GetConverterProperties(buildingUID)
			if cProps ~= nil and cProps[1] ~= nil then
				return { kind = 'converter', uid = buildingUID,  props = cProps }
			end
		end
	end
	
	-- if ModTiles.IsSubcategoryOnTile(x,y,'Vehicles') then
		-- -- Check if it is a train carriage?
		-- types = ModTiles.GetObjectTypeOnTile(x, y)
		-- for _, typ in ipairs(types)
		-- do
			-- if string.sub(typ, 1, 8) == 'Carriage' then
				-- uids = ModTiles.GetObjectsOfTypeInAreaUIDs(typ, x, y, x, y)
				-- if uids ~= nil and uids[1] ~= nil and uids[1] ~= -1 then return uids[1] end
			-- end
		-- end
	-- end
	
	return nil
end

function tileXYFromDir(srcXY, dir)
	if dir == 'n' then return srcXY[1]	, srcXY[2] - 1	end
	if dir == 's' then return srcXY[1]	, srcXY[2] + 1	end
	if dir == 'w' then return srcXY[1] - 1, srcXY[2]	end
	if dir == 'e' then return srcXY[1] + 1, srcXY[2]	end
end

function newBuildingInArea(BuildingUID, IsBlueprint, IsDragging) -- BuildingUID, IsBlueprint, IsDragging
	if IsBlueprint then return end
	if IsDragging then return end
	if ModBuilding.IsBuildingActuallyFlooring(BuildingUID) then return end
	if LINK_UIDS[BuildingUID] ~= nil then return end -- We already know about this building
	if STORAGE_UIDS[BuildingUID] ~= nil then return end -- We already know about this building
	local TileXY = ModObject.GetObjectTileCoord(BuildingUID)
	local UIDOnTile
	
	-- From here we only proceed if this is a storage.
	if ModBase.ClassAndMethodExist('ModStorage','IsStorageUIDValid') then
		if ModStorage.IsStorageUIDValid(BuildingUID) == false then return end
		if DEBUG_ENABLED then ModDebug.Log(' newBuildingInArea: Checked using "IsStorageUIDValid", true!') end
	else
		UIDOnTile = storageUidOnTile(TileXY[1], TileXY[2])
		if UIDOnTile == nil then return end
		BuildingUID = UIDOnTile
		if DEBUG_ENABLED then ModDebug.Log(' newBuildingInArea: Checked using "storageUidOnTile", not nil!', BuildingUID) end
	end
	
	addStorageToLinksWatchingTile(BuildingUID, TileXY)

end

function removeAllSymbolObjects() -- not used yet
	local blockerSymbols = ModTiles.GetObjectsOfTypeInAreaUIDs("Wooden Blocker On Symbol (BB)", 0, 0, WORLD_LIMITS[1]-1, WORLD_LIMITS[2]-1 )
	if blockerSymbols ~= nil and blockerSymbols[1] ~= nil and blockerSymbols[1] ~= -1 then
		for _, uid in ipairs(blockerSymbols) do
			if uid ~= -1 and ModObject.IsValidObjectUID(buildingUID) then
				ModObject.DestroyObject(uid)
			end
		end
	end
end

function compareLargerOnHandQty(a,b)
  return a.storageProps[2] > b.storageProps[2]
end

function compareSmallerOnHandQty(a,b)
  return a.storageProps[2] < b.storageProps[2]
end

--[[
   Author: Julio Manuel Fernandez-Diaz
   Date:   January 12, 2007
   (For Lua 5.1)
   
   Modified slightly by RiciLake to avoid the unnecessary table traversal in tablecount()

   Formats tables with cycles recursively to any depth.
   The output is returned as a string.
   References to other tables are shown as values.
   Self references are indicated.

   The string returned is "Lua code", which can be procesed
   (in the case in which indent is composed by spaces or "--").
   Userdata and function keys and values are shown as strings,
   which logically are exactly not equivalent to the original code.

   This routine can serve for pretty formating tables with
   proper indentations, apart from printing them:

      print(table.show(t, "t"))   -- a typical use
   
   Heavily based on "Saving tables with cycles", PIL2, p. 113.

   Arguments:
      t is the table.
      name is the name of the table (optional)
      indent is a first indentation (optional).
--]]
function table.show(t, name, indent)
   local cart     -- a container
   local autoref  -- for self references

   --[[ counts the number of elements in a table
   local function tablecount(t)
      local n = 0
      for _, _ in pairs(t) do n = n+1 end
      return n
   end
   ]]
   -- (RiciLake) returns true if the table is empty
   local function isemptytable(t) return next(t) == nil end

   local function basicSerialize (o)
      local so = tostring(o)
      if type(o) == "function" then
         local info = debug.getinfo(o, "S")
         -- info.name is nil because o is not a calling level
         if info.what == "C" then
            return string.format("%q", so .. ", C function")
         else 
            -- the information is defined through lines
            return string.format("%q", so .. ", defined in (" ..
                info.linedefined .. "-" .. info.lastlinedefined ..
                ")" .. info.source)
         end
      elseif type(o) == "number" or type(o) == "boolean" then
         return so
      else
         return string.format("%q", so)
      end
   end

   local function addtocart (value, name, indent, saved, field)
      indent = indent or ""
      saved = saved or {}
      field = field or name

      cart = cart .. indent .. field

      if type(value) ~= "table" then
         cart = cart .. " = " .. basicSerialize(value) .. ";\n"
      else
         if saved[value] then
            cart = cart .. " = {}; -- " .. saved[value] 
                        .. " (self reference)\n"
            autoref = autoref ..  name .. " = " .. saved[value] .. ";\n"
         else
            saved[value] = name
            --if tablecount(value) == 0 then
            if isemptytable(value) then
               cart = cart .. " = {};\n"
            else
               cart = cart .. " = {\n"
               for k, v in pairs(value) do
                  k = basicSerialize(k)
                  local fname = string.format("%s[%s]", name, k)
                  field = string.format("[%s]", k)
                  -- three spaces between levels
                  addtocart(v, fname, indent .. "   ", saved, field)
               end
               cart = cart .. indent .. "};\n"
            end
         end
      end
   end

   name = name or "__unnamed__"
   if type(t) ~= "table" then
      return name .. " = " .. basicSerialize(t)
   end
   cart, autoref = "", ""
   addtocart(t, name, indent)
   return cart .. autoref
end

function isABuildingInTableOnMap(buildingTable)
	if buildingTable == nil or buildingTable[1] ~= nil then return false end
	
	for _, rType in ipairs(buildingTable) do
		if ModTiles.GetAmountObjectsOfTypeInArea(rType,0,0,WORLD_LIMITS[1]-1,WORLD_LIMITS[2]-1) > 0 then
			return true
		end
	end
	
	return false
end




-- Moving OBJECTS_IN_FLIGHT
function updateFlightPositions()
	
	-- If move not completed and valid, update
	for UID, ob in pairs(OBJECTS_IN_FLIGHT)
	do
		updatePositionOfUIDInFlight(UID, ob)
	end
	
end

function updatePositionOfUIDInFlight(UID, ob)
	
	if UID ~= -1 and ModObject.IsValidObjectUID(UID) then
	
		local moveComplete = ModObject.UpdateMoveTo(UID, ob.arch, ob.wobble)
		
		if moveComplete then
			ob.onFlightComplete(UID, ob)
			OBJECTS_IN_FLIGHT[UID] = nil
		end
	end
	
end

function listInFlightWithProp(propName, propValue, returnUIDs)
	
	local listOfReturns = {}
	
	if returnUIDs == nil or returnUIDs == false then
		for UID, ob in pairs(OBJECTS_IN_FLIGHT)
		do
			if ob[propName] ~= nil and ob[propName] == propValue then
				listOfReturns[#listOfReturns + 1] = ob
			end
		end
		return listOfReturns
	end
	
	for UID, ob in pairs(OBJECTS_IN_FLIGHT)
	do
		if ob[propName] ~= nil and ob[propName] == propValue then
			listOfReturns[#listOfReturns + 1] = UID
		end
	end
	
	return listOfReturns
end

function hasValue (tab, val)
    for index, value in ipairs(tab) do
        if value == nil then return false end -- mmediate exit!
		if value == val then
            return true
        end
    end

    return false
end



function everyFrame(timeDelta)
	for _, ob in pairs(TIMEOUT_DB) do
		if ob ~= nil then
			-- reduce the counter
			TIMEOUT_DB[_].ms = TIMEOUT_DB[_].ms - (timeDelta*1000)
			-- if counter <= 0,.
			if TIMEOUT_DB[_].ms <= 0 then
				TIMEOUT_DB[_].whenDoneCallback() -- ()
			end
		end
	end
end

function setTimeout(cb, args, ms)
	local key = tostring(math.random(150))
	local ob = { whenDoneCallback = function() 
		TIMEOUT_DB[key] = nil
		cb(unpack(args))
	end, ms = ms }
	TIMEOUT_DB[key] = ob
end


