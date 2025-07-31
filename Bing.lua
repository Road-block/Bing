local addonName, addon = ...
addon = {};
addon.version = C_AddOns.GetAddOnMetadata(addonName, "Version");
addon.query = "";
addon.throttle = 5;
BingDB = {};

function addon.OnEvent(_, event, arg1, _, _, _, arg5, _, _, _, arg9)
	if (event == "ADDON_LOADED" and arg1 == addonName) then
		GameTooltip:HookScript("OnShow", addon.SearchTooltip);
		
		SlashCmdList[addonName] = addon.SlashHandler;
		_G["SLASH_"..addonName.."1"] = "/"..strlower(addonName);
	elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		local _, _, _, _, sourceName, _, _, _, destName = CombatLogGetCurrentEventInfo();
		addon.StringMatch(sourceName, "sonar");
		addon.StringMatch(destName, "sonar");
	elseif (event == "UPDATE_MOUSEOVER_UNIT") then
		if (addon.query == "easter" or addon.query == "female") then
			addon.SearchEaster();
		elseif (addon.query ~= "") then
			addon.SearchTooltip(GameTooltip);
		end
	end
end

function addon.SlashHandler(query)
	if query == nil or query == "" then
		addon.query = "";
		addon.Print("Stopped Searching");
	else
		addon.query = query;
		addon.Print("Searching for: '"..query.."'");
	end
end

function addon.SearchEaster(self)
	if (addon.query ~= "" and UnitName("mouseover") ~= nil) then
		local level = UnitLevel("mouseover");
		local race = UnitRace("mouseover") or "";
		local sex = UnitSex("mouseover");
		if (sex == 3) and (level >= 18) then
			addon.Alert("Level " .. level .. " " .. race .. " Female", "point");
		end
	end
end

function addon.NotFilteredTip()
	if self:GetItem() or self:GetSpell() or self:GetUnit() then return end
	if WorldMapFrame and WorldMapFrame:IsVisible() and WorldMapFrame:IsMouseOver() then return end
	if WatchFrame and WatchFrame:IsVisible() and WatchFrame:IsMouseOver() then return end
	if ObjectiveTrackerFrame and ObjectiveTrackerFrame:IsVisible() and ObjectiveTrackerFrame:IsMouseOver() then return end
	if Minimap and Minimap:IsVisible() and Minimap:IsMouseOver() then return end
	local chatFrame = (DEFAULT_CHAT_FRAME or SELECTED_CHAT_FRAME)
	if chatFrame:IsVisible() and chatFrame:IsMouseOver() then return end
	return true
end

function addon.SearchTooltip(self)
	if (addon.query ~= "") then
		if self:GetItem() == nil and self:GetSpell() == nil then
			local name, unit = self:GetUnit()
			if unit then
				if not UnitIsDead(unit) then
					addon.StringMatch(name, "point")
					return
				end
			else
				if addon.NotFilteredTip() then
					for i=1,self:NumLines() do
						local left = _G[self:GetName().."TextLeft" .. i]:GetText();
						local right = _G[self:GetName().."TextRight" .. i]:GetText();
						if addon.StringMatch(left, "point") then
							return
						end
						if addon.StringMatch(right, "point") then
							return
						end
					end
				end
			end
		end
	end
end

function addon.StringMatch(text, aType)
	if (addon.query ~= "" and text ~= nil) then
		if strfind(strlower(text), strlower(addon.query)) then
			addon.Alert(text, aType);
			return true
		end
	end
end

function addon.Alert(text, aType)
	local out = addon.FormatText(text, aType);
	if aType == "point" then
		if addon.isAlertExpired(text, aType) then
			PlaySoundFile(567574);
			addon.Print("Found: "..out);
		end
		addon.SetTargetIcon();
	elseif aType == "sonar" then
		if addon.isAlertExpired(text, aType) then
			PlaySoundFile(567427);
			addon.Print("Detected nearby: "..out);
		end
	end
end

function addon.FormatText(text, aType)
	if aType == "point" then
		local name = UnitName("mouseover") or "Unknown";
		return "|cFF00FF00"..name.."|r: "..text;
	elseif aType == "sonar" then
		return "|cFF00FF00"..text.."|r";
	end
end

function addon.SetTargetIcon()
	if (GetRaidTargetIndex("mouseover") ~= 4) then
		SetRaidTargetIcon("mouseover",4);
	end
end

function addon.isAlertExpired(text, aType)
	local now = GetTime()
	local result = BingDB[text] == nil or (BingDB[text] + addon.throttle) < now;
	BingDB[text] = now;
	return result;
end

function addon.Print(msg)
	local chatFrame = (SELECTED_CHAT_FRAME or DEFAULT_CHAT_FRAME)
	if (chatFrame) then
		msg = "|cFF00FF00["..addonName.."]|r " .. msg;
		chatFrame:AddMessage(msg, 1, 1, 1);
	end
end

addon.frame = CreateFrame("Frame", "BingFrame");
addon.frame:RegisterEvent("ADDON_LOADED");
addon.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
addon.frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
addon.frame:SetScript("OnEvent", addon.OnEvent);