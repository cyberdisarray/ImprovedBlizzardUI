--[[
    ImpBlizzardUI/modules/ImpBlizzardUI_Bars
    Handles and modifies Action Bar related stuff
    Current Features: Main Action Bars minified, Range / OOM colours on all abilities, Moved Vehicle Leave Button, stripped unneccesary textures, Micro Menu on Minimap, Cast Bar (With Timer), Buff Bars
]]
local _, ImpBlizz = ...;

local BarFrame = CreateFrame("Frame", nil, UIParent);

-- Buffs
BarFrame.buffPoint = BuffFrame.SetPoint;
BarFrame.buffScale = BuffFrame.SetScale;
TemporaryEnchantFrame.buffPoint = TemporaryEnchantFrame.SetPoint;
TemporaryEnchantFrame.buffScale = TemporaryEnchantFrame.SetScale;

-- Totem Bar
local newTotemBar;
blizzardTimers = true;
barTimers = true;
spacing = 8;

-- Helper function for moving a Blizzard frame that has a SetMoveable flag
local function ModifyFrame(frame, anchor, parent, posX, posY, scale)
    if (frame == nil) then
        print("Missing Frame");
        return;
    end
    frame:SetMovable(true);
    frame:ClearAllPoints();
    if(parent == nil) then frame:SetPoint(anchor, posX, posY) else frame:SetPoint(anchor, parent, posX, posY) end
    if(scale ~= nil) then frame:SetScale(scale) end
    frame:SetUserPlaced(true);
    frame:SetMovable(false);
end

-- Helper function for moving a Blizzard frame that does NOT have a SetMoveable flag
local function ModifyBasicFrame(frame, anchor, parent, posX, posY, scale)
    if (frame == nil) then
        print("Missing Basic Frame");
        return;
    end
    frame:ClearAllPoints();
    if(parent == nil) then frame:SetPoint(anchor, posX, posY) else frame:SetPoint(anchor, parent, posX, posY) end
    if(scale ~= nil) then frame:SetScale(scale) end
end

function newTotemBar_Destroy(self, button)
	if (button ~= "RightButton") then return end
	if (self:GetName() == "MultiCastActionButton1") or (self:GetName() == "MultiCastActionButton5") or (self:GetName() == "MultiCastActionButton9") then
		DestroyTotem(2);
	elseif (self:GetName() == "MultiCastActionButton2") or (self:GetName() == "MultiCastActionButton6") or (self:GetName() == "MultiCastActionButton10") then
		DestroyTotem(1);
	elseif (self:GetName() == "MultiCastActionButton3") or (self:GetName() == "MultiCastActionButton7") or (self:GetName() == "MultiCastActionButton11") then
		DestroyTotem(3);
	elseif (self:GetName() == "MultiCastActionButton4") or (self:GetName() == "MultiCastActionButton8") or (self:GetName() == "MultiCastActionButton12") then
		DestroyTotem(4);
	end
end

function newTotemBar_Update(totemN)
	if blizzardTimers == false then
		TotemFrame:Hide()
	end
	if newTotemBarTimers == true then
		haveTotem, totemName, startTime, duration = GetTotemInfo(totemN)
       		if (duration == 0) then
			TotemTimers[totemN]:SetCooldown(0, 0);
		else
			TotemTimers[totemN]:SetCooldown(startTime, duration)
		end
	end
end

local function FixTotemBar()
    newTotemBar = CreateFrame("Frame","newTotemBar",UIParent)
    newTotemBar:SetWidth(190 + (spacing*5))
    newTotemBar:SetHeight(38)
    newTotemBar:SetPoint("CENTER","UIParent","CENTER")

    MultiCastActionBarFrame:SetParent(newTotemBar)
    MultiCastActionBarFrame:SetWidth(0.01)

    MultiCastSummonSpellButton:SetParent(newTotemBar)
    MultiCastSummonSpellButton:ClearAllPoints()
    MultiCastSummonSpellButton:SetPoint("BOTTOMLEFT", newTotemBar, 5, 5)

    for i=1, 4 do
    	_G["MultiCastSlotButton"..i]:SetParent(newTotemBar)
    end
    MultiCastSlotButton1:ClearAllPoints()
    MultiCastSlotButton1:SetPoint("LEFT", MultiCastSummonSpellButton, "RIGHT", spacing, 0)
    for i=2, 4 do
    	local b = _G["MultiCastSlotButton"..i]
    	local b2 = _G["MultiCastSlotButton"..i-1]
    	b:ClearAllPoints()
    	b:SetPoint("LEFT", b2, "RIGHT", spacing, 0)
    end

    MultiCastRecallSpellButton:ClearAllPoints()
    MultiCastRecallSpellButton:SetPoint("LEFT", MultiCastSlotButton4, "RIGHT", spacing, 0)

    for i=1, 12 do
    	local b = _G["MultiCastActionButton"..i]
    	local b2 = _G["MultiCastSlotButton"..(i % 4 == 0 and 4 or i % 4)]
    	b:ClearAllPoints()
    	b:SetPoint("CENTER", b2, "CENTER", 0, 0)
    end

    local dummy = function() return end
    for i=1, 4 do
    	local b = _G["MultiCastSlotButton"..i]
    	b.SetParent = dummy
    	b.SetPoint = dummy
    end
    MultiCastRecallSpellButton.SetParent = dummy
    MultiCastRecallSpellButton.SetPoint = dummy

    local defaults = { Anchor = "CENTER", X = 0, Y = 0, Scale = 1.0, Hide = false }

    local TotemTimers = {};
    TotemTimers[1] = CreateFrame("Cooldown","TotemTimers1",MultiCastSlotButton2)
    TotemTimers[2] = CreateFrame("Cooldown","TotemTimers2",MultiCastSlotButton1)
    TotemTimers[3] = CreateFrame("Cooldown","TotemTimers3",MultiCastSlotButton3)
    TotemTimers[4] = CreateFrame("Cooldown","TotemTimers4",MultiCastSlotButton4)
    TotemTimers[1]:SetAllPoints(MultiCastSlotButton2)
    TotemTimers[2]:SetAllPoints(MultiCastSlotButton1)
    TotemTimers[3]:SetAllPoints(MultiCastSlotButton3)
    TotemTimers[4]:SetAllPoints(MultiCastSlotButton4)

    newTotemBar:RegisterEvent("PLAYER_ENTERING_WORLD")
    newTotemBar:RegisterEvent("PLAYER_TOTEM_UPDATE")

    newTotemBar:SetScript("OnEvent", function(self,event,...)
            if (event=="PLAYER_ENTERING_WORLD") then
    		if HasMultiCastActionBar() == false then
    			newTotemBar:Hide()
    		else
    			newTotemBar:Show()
    		end
    		for i=1, MAX_TOTEMS do
    			newTotemBar_Update(i);
    		end
    	elseif (event=="PLAYER_TOTEM_UPDATE") then
                    newTotemBar_Update(select(1,...));
            end
    end)

    newTotemBar:SetScript("OnMouseDown",function()
    	newTotemBar:StartMoving()
    end)

    newTotemBar:SetScript("OnMouseUp",function()
    	newTotemBar:StopMovingOrSizing()
    end)

    for i = 1, 12 do
    	hooker = _G["MultiCastActionButton"..i];
    	hooker:HookScript("OnClick", newTotemBar_Destroy)
    end
end

local function AdjustExperienceBars()
    offset = 0;

    -- Adjust all fillable bars eg Honor, Exp, Artifact Power
    -- Adjust Exp Bar
    MainMenuExpBar:SetWidth(512);
    ModifyBasicFrame(MainMenuExpBar, "TOP", nil, 0, 0, nil); -- Move it
    ExhaustionTick:Hide(); -- Hide Exhaustion Tick
    ExhaustionLevelFillBar:SetVertexColor(0.0, 0.0, 0.0, 0.0);
    for i = 1, 19 do -- Remove EXP Dividers
        if _G["MainMenuXPBarDiv"..i] then _G["MainMenuXPBarDiv"..i]:Hide() end
    end
    for i = 0, 3 do -- Remove "collapsed" exp bar at max level
        if _G["MainMenuMaxLevelBar"..i] then _G["MainMenuMaxLevelBar"..i]:Hide() end
    end

    if(MainMenuExpBar:IsShown()) then
        offset = 10;
    else
        offset = 0;
    end -- Tweak position based on exp bar being visible

    -- Tweak and Adjust Reputation Bar
    ReputationWatchStatusBar:SetWidth(512);
    ReputationWatchBar:SetFrameStrata("BACKGROUND");
    ReputationWatchBar:SetWidth(512);
    for i = 0, 3 do
        _G["ReputationWatchBarTexture"..i]:Hide()
    end

    ModifyBasicFrame(ReputationWatchBar, "TOP", nil, 0, offset, nil); -- Move it
end

-- Does the bulk of the tweaking to the primary action bars
-- god damn I hate the repeating bar stuff, need to refactor once the logic is finalised
local function AdjustActionBars()
    local offset = 0;

    if(InCombatLockdown() == nil) then

        ModifyFrame(MainMenuBar, "BOTTOM", nil, 0, 0, 1.1); -- Main Action Bar
        ModifyFrame(MainMenuBarBackpackButton, "BOTTOMRIGHT", UIParent, -1, -300, nil); -- Bag Bar
        ModifyFrame(CharacterMicroButton, "BOTTOMRIGHT", UIParent, 0, 5000, nil); -- Micro Menu

        MainMenuBar:SetWidth(512);

        -- Tweak Art Positions
        MainMenuBarTexture0:SetPoint("CENTER", MainMenuBarArtFrame, -128, 0);
        MainMenuBarTexture1:SetPoint("CENTER", MainMenuBarArtFrame, 128, 0);
        MainMenuBarRightEndCap:SetPoint("CENTER", MainMenuBarArtFrame, 290, 0);
        MainMenuBarLeftEndCap:SetPoint("CENTER", MainMenuBarArtFrame, -290, 0);

        ModifyFrame(ExtraActionBarFrame, "BOTTOM", UIParent, 0, 192, nil);

        AdjustExperienceBars();

        local shownBars = 0;
        if(MainMenuExpBar:IsShown()) then
            shownBars = shownBars + 1;
        end

        if(ReputationWatchBar:IsShown()) then
            shownBars = shownBars + 1;
        end

        offset = shownBars * 10;

        ModifyFrame(MultiBarBottomRight, "BOTTOM", nil, 0, 92 + offset, nil); -- Bottom Right Action Bar
        ModifyFrame(MultiBarBottomLeft, "BOTTOM", nil, 0, 49 + offset, nil); -- Bottom Left Action Bar

        -- Adjust and reposition the stance bar and totem bar based on the above
        if(MultiBarBottomLeft:IsShown()) then
            ModifyFrame(newTotemBar, "BOTTOM", nil, -162, offset + 100, 1);
            ModifyFrame(ShapeshiftBarFrame, "TOPLEFT", nil, 0, 65 + offset, 1);
        end
        if(MultiBarBottomRight:IsShown()) then
            ModifyFrame(newTotemBar, "BOTTOM", nil, -162, offset + 146, 1);
            ModifyFrame(ShapeshiftBarFrame, "TOPLEFT", nil, 0, 110 + offset, 1);
        end
        if(MultiBarBottomLeft:IsShown() == nil and MultiBarBottomRight:IsShown() == nil) then
            ModifyFrame(newTotemBar, "BOTTOM", nil, -162, offset + 46, 1);
            ModifyFrame(ShapeshiftBarFrame, "TOPLEFT", nil, 0, 20 + offset, 1);
        end

        newTotemBar:SetFrameStrata("HIGH"); -- Keep Totem Bar on top of artwork

        -- Hide Textures
        MainMenuBarTexture2:SetTexture(nil);
        MainMenuBarTexture3:SetTexture(nil);
        _G["ShapeshiftBarLeft"]:SetTexture(nil);
        _G["ShapeshiftBarMiddle"]:SetTexture(nil);
        _G["ShapeshiftBarRight"]:SetTexture(nil);
        _G["SlidingActionBarTexture"..0]:SetTexture(nil);
        _G["SlidingActionBarTexture"..1]:SetTexture(nil);
        if(Conf_ShowArt == false) then -- Hide Action Bar Art
            MainMenuBarRightEndCap:SetTexture(nil);
            MainMenuBarLeftEndCap:SetTexture(nil);
        end

        -- Hide Main Action Bar Buttons
        MainMenuBarPageNumber:Hide();
        ActionBarDownButton:Hide();
        ActionBarUpButton:Hide();

        -- Vehicle Leave Button
        ModifyBasicFrame(MainMenuBarVehicleLeaveButton, "CENTER", nil, -350, 40, nil);

        -- Adjust and reposition the pet bar based on the above
        if(MultiBarBottomRight:IsShown()) then
            if ( ShapeshiftBarFrame and GetNumShapeshiftForms() > 0 ) then
                ModifyBasicFrame(PetActionButton1, "CENTER", nil, -609, 35 + offset);
            else
                ModifyBasicFrame(PetActionButton1, "CENTER", nil, -143, 35 + offset);
            end
        else
            if ( ShapeshiftBarFrame and GetNumShapeshiftForms() > 0 ) then
                ModifyBasicFrame(PetActionButton1, "CENTER", nil, -609, -8 + offset);
            else
                ModifyBasicFrame(PetActionButton1, "CENTER", nil, -143, -8 + offset);
            end
        end

        -- Enable the Micro Menu
        Minimap:SetScript("OnMouseUp", function(self, btn)
    	if btn == "RightButton" then
    		EasyMenu(BarFrame.microMenuList, BarFrame.microMenu, "cursor", 0, 0, "MENU", 3);
    	else
    		Minimap_OnClick(self)
    	end
    	end)

        -- Casting Bar
        ModifyFrame(CastingBarFrame, "CENTER", nil, 0, -175, 1.1);

        BuffFrame:ClearAllPoints();
    	BarFrame.buffPoint(BuffFrame, "TOPRIGHT", -175, -22);
    	BarFrame.buffScale(BuffFrame, 1.4);

        TemporaryEnchantFrame:ClearAllPoints();
    	TemporaryEnchantFrame.buffPoint(TemporaryEnchantFrame, "TOPRIGHT", -175, -22);
    	TemporaryEnchantFrame.buffScale(TemporaryEnchantFrame, 1.4);
    end
end

-- Toggles the Bag Bar between hidden and visible, called from the Micro Menu
local function ToggleBagBar()
    if(BarFrame.bagsVisible) then
        -- Hide them
        ModifyFrame(MainMenuBarBackpackButton, "BOTTOMRIGHT", UIParent, -1, -300, nil);
        BarFrame.bagsVisible = false;
    else
        --show them
        ModifyFrame(MainMenuBarBackpackButton, "BOTTOMRIGHT", UIParent, -100, 0, nil);
        BarFrame.bagsVisible = true;
    end
end

-- Builds the Micro Menu List that displays on Right Click
local function UpdateMicroMenuList(newLevel)
    BarFrame.microMenuList = {}; -- Create the array

    -- Add Stuff to it
    table.insert(BarFrame.microMenuList, {text = "|cffFFFFFF"..ImpBlizz["Character"], func = function() securecall(ToggleCharacter, "PaperDollFrame") end, notCheckable = true, fontObject = BarFrame.menuFont, icon = 'Interface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle' });
    table.insert(BarFrame.microMenuList, {text = "|cffFFFFFF"..ImpBlizz["Spellbook"], func = function() securecall(ToggleFrame, SpellBookFrame) end, notCheckable = true, fontObject = BarFrame.menuFont, icon = 'Interface\\MINIMAP\\TRACKING\\Class' });
    if(newLevel >= 10) then
        table.insert(BarFrame.microMenuList, {text = "|cffFFFFFF"..ImpBlizz["Talents"], func = function()
            if (not PlayerTalentFrame) then
                    LoadAddOn('Blizzard_TalentUI')
                end
                if (not GlyphFrame) then
                    LoadAddOn('Blizzard_GlyphUI')
                end
                securecall(ToggleFrame, PlayerTalentFrame)
            end, notCheckable = true, fontObject = BarFrame.menuFont, icon = 'Interface\\MINIMAP\\TRACKING\\Profession' });
    end
    table.insert(BarFrame.microMenuList, {text = "|cffFFFFFF"..ImpBlizz["Achievements"], func = function() securecall(ToggleAchievementFrame) end, notCheckable = true, fontObject = BarFrame.menuFont, icon = 'Interface\\Icons\\INV_Misc_Coin_02', });
    table.insert(BarFrame.microMenuList, {text = "|cffFFFFFF"..ImpBlizz["Quest Log"], func = function() securecall(ToggleFrame, QuestLogFrame) end, notCheckable = true, fontObject = BarFrame.menuFont, icon = 'Interface\\GossipFrame\\ActiveQuestIcon' });
    table.insert(BarFrame.microMenuList, {text = "|cffFFFFFF"..ImpBlizz["Guild"], func = function()
        if (IsTrialAccount()) then
            UIErrorsFrame:AddMessage(ERR_RESTRICTED_ACCOUNT, 1, 0, 0)
        else
            securecall(ToggleGuildFrame)
        end
    end, notCheckable = true, fontObject = BarFrame.menuFont, icon = 'Interface\\GossipFrame\\TabardGossipIcon' });
    if(newLevel >= 15) then
        table.insert(BarFrame.microMenuList, {text = "|cffFFFFFF"..ImpBlizz["Group Finder"], func = function() securecall(ToggleLFDParentFrame) end, notCheckable = true, fontObject = BarFrame.menuFont, icon = 'Interface\\LFGFRAME\\BattlenetWorking0' });
        table.insert(BarFrame.microMenuList, {text = "|cffFFFFFF"..ImpBlizz["PvP"], func = function() securecall(ToggleFrame, PVPFrame) end, notCheckable = true, fontObject = BarFrame.menuFont, icon = 'Interface\\MINIMAP\\TRACKING\\BattleMaster' });
    end
    if(newLevel >= 15) then
        table.insert(BarFrame.microMenuList, {text = "|cffFFFFFF"..ImpBlizz["Dungeon Journal"].."     ", func = function() securecall(ToggleEncounterJournal) end, notCheckable = true, fontObject = BarFrame.menuFont, icon = 'Interface\\MINIMAP\\TRACKING\\None' });
    end
    table.insert(BarFrame.microMenuList, {text = "|cffFFFFFF"..ImpBlizz["Swap Bags"], func = function() ToggleBagBar() end, notCheckable = true, fontObject = BarFrame.menuFont, icon = 'Interface\\MINIMAP\\TRACKING\\Banker' });
    table.insert(BarFrame.microMenuList, {text = "|cff00FFFF"..ImpBlizz["ImpBlizzardUI"], func = function() InterfaceOptionsFrame_OpenToCategory("Improved Blizzard UI") end, notCheckable = true, fontObject = BarFrame.menuFont });
    table.insert(BarFrame.microMenuList, {text = "|cffFFFF00"..ImpBlizz["Log Out"], func = function() Logout() end, notCheckable = true, fontObject = BarFrame.menuFont });
    table.insert(BarFrame.microMenuList, {text = "|cffFE2E2E"..ImpBlizz["Force Exit"], func = function() ForceQuit() end, notCheckable = true, fontObject = BarFrame.menuFont });
end


local function HandleEvents(self, event, ...)
    if(event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_TALENT_UPDATE" or event == "ACTIVE_TALENT_GROUP_CHANGED") then
        AdjustActionBars();
        UpdateMicroMenuList(UnitLevel("player"));
    end

    if(event == "UNIT_EXITED_VEHICLE") then
        if(... == "player") then
            AdjustActionBars();
        end
    end

    if(event == "PLAYER_FLAGS_CHANGED") then
        ModifyFrame(CharacterMicroButton, "BOTTOMRIGHT", UIParent, 0, 5000, nil);
    end

    if(event == "PLAYER_LEVEL_UP") then
        local newLevel, _, _, _, _, _, _, _, _ = ...;
        UpdateMicroMenuList(newLevel);
        -- Print out hint for players on level up of unlocks, replaces the blizzard flashing thing
        if(newLevel == 10) then
            print("|cffffff00Talents now available under the Minimap Right-Click Menu!");
        elseif(newLevel == 15) then
            print("|cffffff00Group Finder and Adventure Guide now available under the Minimap Right-Click Menu!");
        end
    end

    if(event == "ADDON_LOADED" and ... == "ImpBlizzardUI") then
      if(Conf_CastingTimer) then
          CastingBarFrame.timer = CastingBarFrame:CreateFontString(nil);
          CastingBarFrame.timer:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE");
          CastingBarFrame.timer:SetPoint("TOP", CastingBarFrame, "BOTTOM", 0, 35);
          CastingBarFrame.updateDelay = 0.1;
      end
    end
end

-- Sets up Event Handlers etc
local function Init()
    BarFrame:SetScript("OnEvent", HandleEvents);

    -- Register all Events
    BarFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
    BarFrame:RegisterEvent("PLAYER_FLAGS_CHANGED");
    BarFrame:RegisterEvent("PLAYER_TALENT_UPDATE");
    BarFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
    BarFrame:RegisterEvent("UNIT_EXITED_VEHICLE");
    BarFrame:RegisterEvent("PLAYER_LEVEL_UP");
    BarFrame:RegisterEvent("ADDON_LOADED");

    -- Micro Menu that replaces the removed action bar based one. Spawns on right click of minimamp
    BarFrame.microMenu = CreateFrame("Frame", "RightClickMenu", UIParent, "UIDropDownMenuTemplate");
    BarFrame.menuFont = CreateFont("menuFont");
    BarFrame.menuFont:SetFontObject(GameFontNormal);
    BarFrame.menuFont:SetFont("Interface\\AddOns\\ImpBlizzardUI\\media\\impfont.ttf", 12, nil);
    BarFrame.bagsVisible = false;

    FixTotemBar();
end

-- Handles the Out of Range action bar colouring
local function UpdateActionRange(self, elapsed)
    if(Conf_OutOfRange) then
        if(self.rangeTimer == TOOLTIP_UPDATE_TIME) then
            if(IsActionInRange(self.action) == false) then
                self.icon:SetVertexColor(1, 0, 0);
            else
                local canUse, amountMana = IsUsableAction( self.action );
                if(canUse) then
                    self.icon:SetVertexColor( 1.0, 1.0, 1.0 );
    			elseif(amountMana) then
                    self.icon:SetVertexColor( 0.5, 0.5, 1.0 );
    			else
                    self.icon:SetVertexColor( 0.4, 0.4, 0.4 )
                end
            end
        end
    end
end

-- Fixes the Buff Frames once the Blizzard UI messes with them
local function FixBuffs()
    BuffFrame:ClearAllPoints();
    BarFrame.buffPoint(BuffFrame, "TOPRIGHT", -175, -22);
    BarFrame.buffScale(BuffFrame, 1.4);
end

-- Repositon stuff after the Blizzard UI fucks with them
local function MainMenuBar_UpdateExperienceBars_Hook(newLevel)
    AdjustActionBars();
    AdjustExperienceBars();
end

-- Repositon stuff after the Blizzard UI fucks with them
local function MainMenuBarVehicleLeaveButton_Update_Hook()
    AdjustActionBars();
end

-- Moves the MicroMenu back after the Blizzard UI repositions it
local function MoveMicroButtons_Hook(...)
    ModifyFrame(CharacterMicroButton, "BOTTOMRIGHT", UIParent, 0, 5000, nil);
end

-- Displays the Casting Bar timer
CastingBarFrame:HookScript('OnUpdate', function(self, elapsed)
    if not self.timer then return end

    if (self.updateDelay and self.updateDelay < elapsed) then
        if (self.casting) then
            self.timer:SetText(format("%.1f", max(self.maxValue - self.value, 0)))
        elseif (self.channeling) then
            self.timer:SetText(format("%.1f", max(self.value, 0)))
        else
            self.timer:SetText("")
        end
        self.updateDelay = 0.1
    else
        self.updateDelay = self.updateDelay - elapsed
    end
end)

-- Add a function to be called after execution of a secure function. Allows one to "post-hook" a secure function without tainting the original.
hooksecurefunc("MoveMicroButtons", MoveMicroButtons_Hook);
hooksecurefunc("ActionButton_OnUpdate", UpdateActionRange);
hooksecurefunc("MultiActionBar_Update", AdjustActionBars);
--hooksecurefunc("MainMenuBar_UpdateExperienceBars", MainMenuBar_UpdateExperienceBars_Hook); TODO
hooksecurefunc("MainMenuBarVehicleLeaveButton_Update", MainMenuBarVehicleLeaveButton_Update_Hook);
hooksecurefunc( BuffFrame, "SetPoint", function(frame) frame:ClearAllPoints(); BarFrame.buffPoint(BuffFrame, "TOPRIGHT", -175, -22); end);
hooksecurefunc( BuffFrame, "SetScale", function(frame) BarFrame.buffScale(BuffFrame, 1.4); end)

ExhaustionTick:HookScript("OnShow", ExhaustionTick.Hide); -- Make sure it never comes back
-- Credit : BlizzBugsSuck (Shefki, Phanx) - http://www.wowinterface.com/downloads/info17002-BlizzBugsSuck.html
-- Fix InterfaceOptionsFrame_OpenToCategory not actually opening the category (and not even scrolling to it) Used by the MicroMenu
-- Confirmed still broken in 7.0.3.21973 (7.0.3)
do
	local function get_panel_name(panel)
		local tp = type(panel)
		local cat = INTERFACEOPTIONS_ADDONCATEGORIES
		if tp == "string" then
			for i = 1, #cat do
				local p = cat[i]
				if p.name == panel then
					if p.parent then
						return get_panel_name(p.parent)
					else
						return panel
					end
				end
			end
		elseif tp == "table" then
			for i = 1, #cat do
				local p = cat[i]
				if p == panel then
					if p.parent then
						return get_panel_name(p.parent)
					else
						return panel.name
					end
				end
			end
		end
	end

	local function InterfaceOptionsFrame_OpenToCategory_Fix(panel)
		if doNotRun or InCombatLockdown() then return end
		local panelName = get_panel_name(panel)
		if not panelName then return end -- if its not part of our list return early
		local noncollapsedHeaders = {}
		local shownpanels = 0
		local mypanel
		local t = {}
		local cat = INTERFACEOPTIONS_ADDONCATEGORIES
		for i = 1, #cat do
			local panel = cat[i]
			if not panel.parent or noncollapsedHeaders[panel.parent] then
				if panel.name == panelName then
					panel.collapsed = true
					t.element = panel
					InterfaceOptionsListButton_ToggleSubCategories(t)
					noncollapsedHeaders[panel.name] = true
					mypanel = shownpanels + 1
				end
				if not panel.collapsed then
					noncollapsedHeaders[panel.name] = true
				end
				shownpanels = shownpanels + 1
			end
		end
		local Smin, Smax = InterfaceOptionsFrameAddOnsListScrollBar:GetMinMaxValues()
		if shownpanels > 15 and Smin < Smax then
			local val = (Smax/(shownpanels-15))*(mypanel-2)
			InterfaceOptionsFrameAddOnsListScrollBar:SetValue(val)
		end
		doNotRun = true
		InterfaceOptionsFrame_OpenToCategory(panel)
		doNotRun = false
	end

	hooksecurefunc("InterfaceOptionsFrame_OpenToCategory", InterfaceOptionsFrame_OpenToCategory_Fix)
end

-- End of file, call Init
Init();
