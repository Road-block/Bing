Bing = {};
Bing.version = GetAddOnMetadata("Bing", "Version");
Bing.query = "";
BingDB = {};

function Bing.OnEvent(_, event, arg1, _, _, _, arg5, _, _, _, arg9)
	if (event == "ADDON_LOADED" and arg1 == "Bing") then
		GameTooltip:HookScript("OnShow", Bing.SearchTooltip);
		
		SlashCmdList["Bing"] = Bing.SlashHandler;
		SLASH_Bing1 = "/Bing";
	elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		local _, _, _, _, sourceName, _, _, _, destName = CombatLogGetCurrentEventInfo();
		Bing.StringMatch(sourceName, "sonar");
		Bing.StringMatch(destName, "sonar");
	elseif (event == "UPDATE_MOUSEOVER_UNIT") then
		if (Bing.query == "easter" or Bing.query == "female") then
			Bing.SearchEaster();
		elseif (Bing.query ~= "") then
			Bing.SearchTooltip(GameTooltip);
		end
	end
end

function Bing.SlashHandler(query)
	if query == nil or query == "" then
		Bing.query = "";
		Bing.Print("Stopped Searching");
	else
		Bing.query = query;
		Bing.Print("Searching for: '"..query.."'");
	end
end

function Bing.SearchEaster(self)
	if (Bing.query ~= "" and UnitName("mouseover") ~= nil) then
		local level = UnitLevel("mouseover");
		local race = UnitRace("mouseover") or "";
		local sex = UnitSex("mouseover");
		if (sex == 3) and (level >= 18) then
			Bing.Alert("Level " .. level .. " " .. race .. " Female", "point");
		end
	end
end

function Bing.SearchTooltip(self)
	if (Bing.query ~= "") then
		if self:GetItem() == nil and self:GetSpell() == nil then
			for i=1,self:NumLines() do
				local left = getglobal(self:GetName().."TextLeft" .. i):GetText();
				local right = getglobal(self:GetName().."TextRight" .. i):GetText();
				Bing.StringMatch(left, "point");
				Bing.StringMatch(right, "point");
			end
		end
	end
end

function Bing.StringMatch(text, aType)
	if (Bing.query ~= "" and text ~= nil) then
		if strfind(strlower(text), strlower(Bing.query)) then
			Bing.Alert(text, aType);
		end
	end
end

function Bing.Alert(text, aType)
	text = Bing.FormatText(text, aType);
	if aType == "point" then
		PlaySoundFile(567574);
		if Bing.isAlertExpired(text, aType) then
			Bing.Print("Found: "..text);
		end
		Bing.SetTargetIcon();
	elseif aType == "sonar" then
		if Bing.isAlertExpired(text, aType) then
			PlaySoundFile(567427);
			Bing.Print("Detected nearby: "..text);
		end
	end
end

function Bing.FormatText(text, aType)
	if aType == "point" then
		local name = UnitName("mouseover") or "Unknown";
		return "|cFF00FF00"..name.."|r: "..text;
	elseif aType == "sonar" then
		return "|cFF00FF00"..text.."|r";
	end
end

function Bing.SetTargetIcon()
	if (GetRaidTargetIndex("mouseover") ~= 4) then
		SetRaidTargetIcon("mouseover",4);
	end
end

function Bing.isAlertExpired(text, aType)
	local result = BingDB[text] == nil or (BingDB[text] + 10) < time();
	BingDB[text] = time();
	return result;
end

function Bing.Print(msg)
	if (DEFAULT_CHAT_FRAME) then
		msg = "|cFF00FF00[Bing]|r " .. msg;
		DEFAULT_CHAT_FRAME:AddMessage(msg, 1, 1, 1);
	end
end

Bing.frame = CreateFrame("Frame", "BingFrame");
Bing.frame:RegisterEvent("ADDON_LOADED");
Bing.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
Bing.frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
Bing.frame:SetScript("OnEvent", Bing.OnEvent);