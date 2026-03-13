SummonCheck = LibStub("AceAddon-3.0"):NewAddon("SummonCheck", "AceConsole-3.0", "AceEvent-3.0","AceTimer-3.0", "AceComm-3.0" );


local listEntries = {}


--READY_CHECK = "Summon Check";
--READY_CHECK_ALL_READY = "Everyone is Ready";
--READY_CHECK_FINISHED = "Ready check finished";
local SUMMON_CHECK_MESSAGE = "%s has initiated a summon check.";
--READY_CHECK_NO_AFK = "No players are Away";
--READY_CHECK_START = "Starting ready check...";
--READY_CHECK_YOU_WERE_AFK = "You were Away for a ready check";

local summonChecking = false
local groupSummonStatus = {}
local checkTimer = nil

local NeooptionTable = {
		name	= "SummonCheck",
		handler = SummonCheck,
		type	= 'group',
		args = {
						check = 		{
									name = "Start summon check",
									type = "execute",
									func = function ()
										SummonCheck:StartCheck()
										SummonCheck:ShowSummonCheck("player", 30) 
									SCListHolder:Show();
	SummonCheckListenerFrame:Show()
									end
						},
						show 	=	{
									name = "Show",
									desc = "Shows the summon request list",
									type = "execute",
									func = function ()
										if InCombatLockdown() == nil then
										SCListHolder:Show()
end end
						}

				}
			}

LibStub("AceConfig-3.0"):RegisterOptionsTable("SummonCheck", NeooptionTable, {"sc"})
function SummonCheck:CheckExpires()
	summonChecking = false
	SummonCheckListenerFrame:Hide();
	print("The following do need a summon:")
	for k,v in pairs (groupSummonStatus) do
		if v.Summ == true then
			print(k)
		end
	end
end
function SummonCheck:StartCheck()
	
	if summonChecking == false then
		SCtimer =  CreateFrame("StatusBar", nil, UIParent)
		SCtimer.tx = SCtimer.tx or SCtimer:CreateTexture()
		SCtimer:ClearAllPoints();
		SCtimer:SetPoint("TOPLEFT", SELECTED_CHAT_FRAME or DEFAULT_CHAT_FRAME, "BOTTOMLEFT", 3, -3);
		SCtimer:SetPoint("BOTTOMRIGHT", SELECTED_CHAT_FRAME or DEFAULT_CHAT_FRAME, "BOTTOMLEFT", 100, -6);

		SCtimer.tx:SetAllPoints(SCtimer);
		SCtimer.tx:SetTexture(0.7, 0.7, 0, 0.8);
		SCtimer:SetStatusBarTexture(SCtimer.tx);

		SCtimer:SetMinMaxValues(0,30);
		SCtimer:Show();
		SCtimer:SetValue(30);
		SCtimer:Show();

		SCtimer:SetScript("OnUpdate", function(self,elapsed)
		-- Update the timerbar
		local n=self:GetValue() - elapsed
		self:SetValue(n)
		-- In case we do not see a _FINISHED (happens sometimes for officers, thanks blizz), we fake one after n+3 seconds
		
	end)
		summonChecking = true
		SummonCheck:PopulateList()
		checkTimer = SummonCheck:ScheduleTimer("CheckExpires",30)
		SummonCheck:SendCommMessage("SummCheck", "Start Summon Check", "RAID")
		SendChatMessage("<Summon Check>:  If you do not have the addon, say \"1\" in Raid Chat for a summon","RAID"); 
	else
	
		print("Summon Check is already in progress")
	end

end

function SummonCheck:HandleMessage(prefix, message, distribution, sender)

	--print(string.find(s2, pattern2))
	if strfind (message, "Yes (.*)") ~= nil then
		local s, e, nam = strfind (message, "Yes (.*)")
		SummonCheck:UpdateList()
		return 0
	end
	if strmatch(message, "Yes")  ~= nil then
		groupSummonStatus[sender].Summ = true
		SummonCheck:UpdateList()
		return 0
	end
	if strmatch(message, "No")  ~= nil then
		groupSummonStatus[sender].Summ = false
		SummonCheck:UpdateList()
		return 0
	end
	if strmatch(message, "Start Summon Check")  ~= nil then
		if summonChecking == false then
			summonChecking = true
			SummonCheck:PopulateList()
			checkTimer = SummonCheck:ScheduleTimer("CheckExpires",30)
		end
		return 0
	end
	--if strmatch(message, "Yes")  == true then
	--	groupSummonStatus[sender] = true
	--end
end
function SummonCheck:OnInitialize()

	SummonCheck:RegisterComm("SummCheck", "HandleMessage")
	SummonCheck:RegisterEvent("CHAT_MSG_WHISPER")
	SummonCheck:RegisterEvent("GROUP_ROSTER_UPDATE")
	SummonCheck:RegisterEvent("CHAT_MSG_RAID")

	SummonCheck:BuildScrollFrame()

end
function SummonCheck:CHAT_MSG_RAID(eventName, message, sender)
	if summonChecking == true then
		if strmatch("1", message) ~= nil then
			groupSummonStatus[sender].Summ = true
		--	SummonCheck:SendCommMessage("SummCheck", "Yes "..sender, "RAID")
		end
	end
end
function SummonCheck:CHAT_MSG_WHISPER(eventName, message, sender)
	if summonChecking == true then
		if strmatch("1", message) ~= nil then
			groupSummonStatus[sender].Summ = true
			SummonCheck:SendCommMessage("SummCheck", "Yes "..sender, "RAID")
		end
	end
end
function SummonCheck:GROUP_ROSTER_UPDATE()
for k = 0, 39 do
		--listEntries[k] = CreateFrame("Frame", "SummonListEntryTemplate"..k,content,"SummonListEntryTemplate")
		--listEntries[k].unit = UnitGUID("player")
		--listEntries[k]:SetPoint("TOPLEFT",content,-5,-k*29)
		--listEntries[k]:SetAttribute("unit", ("raid"..(k+1)))
		--listEntries[k].unitButton.elename:SetText(k)
		nam, ran, subgroup, leve, clas, fileNam, zon, onlin, isDead, rol, isML = GetRaidRosterInfo(k+1)
		listEntries[k].unit.name:SetText(nam)

		listEntries[k].Remover:SetScript("OnClick", function()
			
	if InCombatLockdown() == nil then
			listEntries[k]:Hide() 
		nam, ran, subgroup, leve, clas, fileNam, zon, onlin, isDead, rol, isML = GetRaidRosterInfo(k+1)
		listEntries[k].unit.name:SetText(nam)
		if nam ~= nil then
			if strfind(nam,"-") == nil then
				groupSummonStatus[nam.."-"..GetRealmName()].Hide = true
			else
				groupSummonStatus[nam].Hide = true
			end
		end
			listEntries[k]:Hide() SummonCheck:HideListEntry()
		end
		end
		)
	end
--SummonCheck:UpdateList()
end
function SummonCheck:SendYes()
	PlaySound("igMainMenuOptionCheckBoxOn");
	SummonCheck:SendCommMessage("SummCheck", "Yes", IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or "RAID")
	SummonCheckFrame:Hide();
end
function SummonCheck:OnEnable()

end

function SummonCheck:OnDisable()

end
function SummonCheck:PopulateList()
	groupSummonStatus = {}


	for index = 1, GetNumGroupMembers() do

		nam, ran, subgroup, leve, clas, fileNam, zon, onlin, isDead, rol, isML = GetRaidRosterInfo(index)
		if strfind(nam,"-") == nil then
			groupSummonStatus[nam.."-"..GetRealmName()] = {Summ = false, Hide = false}
		else
			groupSummonStatus[nam] = {Summ = false, Hide = false}
		end
	end
end
function SummonCheckFrame_OnLoad(self)
   -- self:RegisterEvent("READY_CHECK");
   -- self:RegisterEvent("READY_CHECK_FINISHED");
     
    SummonCheckFrameYesButton:SetText("Yes");
    SummonCheckFrameNoButton:SetText("No");
end
 
function SummonCheckFrame_OnEvent(self, event, ...)
    
end
 
function SummonCheckFrame_OnHide(self)
    self.initiator = nil;
end
function SummonCheck:splitAtFirst(str, pattern)

	local startIndex, endIndex = strfind(str,pattern)
	if startIndex ~= nil then
		return strsub(str,0,  startIndex-1), strsub(str, startIndex+strlen(pattern))
	end
	return str
end
function SummonCheck:ShowSummonCheck(initiator, timeLeft)

	SummonCheckFrame:Show();
	SummonCheckListenerFrame:Show()
	SummonCheckFrameText:SetText("Do you need a summon?")
    SummonCheckFrame.initiator = initiator;
    if ( initiator ) then
        SummonCheckFrame:Show();
        if ( UnitIsUnit("player", initiator) ) then
            --SummonCheckListenerFrame:Hide();
--			SetPortraitTexture(SummonCheckPortrait,"e\\AddOns\\SummonCheck\\miniSum2.tga");
        else
           -- SetPortraitTexture(SummonCheckPortrait, "Interface\\AddOns\\SummonCheck\\miniSum");
            local _, _, difficultyID = GetInstanceInfo();
            if ( not difficultyID or difficultyID == 0 ) then
                -- not in an instance, go by current difficulty setting
                if (UnitInRaid("player")) then
                    difficultyID = GetRaidDifficultyID();
                else
                    difficultyID = GetDungeonDifficultyID();
                end
            end
            local difficultyName, _, _, _, toggleDifficultyID = GetDifficultyInfo(difficultyID);
            if ( toggleDifficultyID and toggleDifficultyID > 0 ) then
                -- the current difficulty might change while inside an instance so show the difficulty on the ready check
                SummonCheckFrameText:SetFormattedText(SUMMON_CHECK_MESSAGE.."\n"..RAID_DIFFICULTY..": "..difficultyName, initiator);
            else
                SummonCheckFrameText:SetFormattedText(SUMMON_CHECK_MESSAGE, initiator);
            end
            SummonCheckListenerFrame:Show();
        end
    end
end



local theScrollFrame = nil
local content = nil
local frame = nil
function SummonCheck:BuildScrollFrame()
	--parent frame
	frame = CreateFrame("Frame", "MyFrame", SCListHolder)
	frame:SetPoint("CENTER",SCListHolder, -20, 0)
	frame:SetSize(180, 200)

	--local texture = frame:CreateTexture()
	--texture:SetAllPoints()
	--texture:SetTexture(1,1,1,1)
	--frame.background = texture
 
	--scrollframe
	scrollframe = CreateFrame("ScrollFrame", nil, frame)
	scrollframe:SetPoint("TOPLEFT", 10, -10)
	scrollframe:SetPoint("BOTTOMRIGHT", -10, 10)
	frame:SetBackdrop({
		bgFile = [[Interface\TutorialFrame\TutorialFrameBackground]],
		edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]],
		tile = true,
		tileSize = 32,
		edgeSize = 16,
		insets = {left = 5, top = 5, right = 5, bottom = 5}
	})
	local texture = scrollframe:CreateTexture()
	texture:SetAllPoints()
	texture:SetTexture(.5,.5,.5,1)
	frame.scrollframe = scrollframe
 
	--scrollbar
	scrollbar = CreateFrame("Slider", nil, scrollframe, "UIPanelScrollBarTemplate")
	scrollbar:SetPoint("TOPLEFT", frame, "TOPRIGHT", 4, -16)
	scrollbar:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 4, 16)
	scrollbar:SetMinMaxValues(1, 40*25)
	scrollbar:SetValueStep(1)
	scrollbar.scrollStep = 1
	scrollbar:SetValue(0)
	scrollbar:SetWidth(16)
	scrollbar:SetScript("OnValueChanged",
	function (self, value)
		if InCombatLockdown() == nil then
	self:GetParent():SetVerticalScroll(value)
	else
	scrollbar:SetValue(self:GetParent():GetVerticalScroll())
	end
	end)
	local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND")
	scrollbg:SetAllPoints(scrollbar)
	scrollbg:SetTexture(0, 0, 0, 0)
	frame.scrollbar = scrollbar
 
	--content frame
	content = CreateFrame("Frame", nil, scrollframe)
	content:SetSize(128, 60*26)
	content:Show()
	--local texture = content:CreateTexture()
	--texture:SetAllPoints()
	--texture:SetTexture("Interface\\GLUES\\MainMenu\\Glues-BlizzardLogo")
	--content.texture = texture
	scrollframe.content = content
 
	scrollframe:SetScrollChild(content)
	
	for k = 0, 39 do
		listEntries[k] = CreateFrame("Frame", "SummonListEntryTemplate"..k,content,"SummonListEntryTemplate")
		--listEntries[k].unit = UnitGUID("player")
		listEntries[k]:SetPoint("TOPLEFT",content,-15,(-k*29))
		listEntries[k]:SetAttribute("unit", "raid"..(k+1))
		listEntries[k].unit:SetAttribute("useparent-unit", true)
		listEntries[k].unit:SetAttribute("*type1", "target")
		nam, ran, subgroup, leve, clas, fileNam, zon, onlin, isDead, rol, isML = GetRaidRosterInfo(k+1)
		listEntries[k].unit.name:SetText(nam)
		--listEntries[k].unitButton.elename:SetText(k)
		
		listEntries[k].Remover:SetScript("OnClick", function()
if InCombatLockdown() == nil then
			nam, ran, subgroup, leve, clas, fileNam, zon, onlin, isDead, rol, isML = GetRaidRosterInfo(k+1)
	--	listEntries[k].unitButton.name:SetText(nam)
		if nam ~= nil then
			if strfind(nam,"-") == nil then
				groupSummonStatus[nam.."-"..GetRealmName()].Hide = false
			else
				groupSummonStatus[nam].Hide = false
			end
		end
			listEntries[k]:Hide() SummonCheck:HideListEntry() end
			end
)
	end

SummonCheck:UpdateList()
end
function SummonCheck:ShowAllRequests()
	for k,v in pairs (groupSummonStatus) do
		groupSummonStatus[k].Hide = false
	end
	SummonCheck:UpdateList()
end
function SummonCheck:UpdateList()
if InCombatLockdown() == nil then
	for k = 0, 39 do
		local nam, ran, subgroup, leve, clas, fileNam, zon, onlin, isDead, rol, isML = GetRaidRosterInfo(k+1)
		if nam == nil then
			listEntries[k]:Hide()
		else
			if strfind(nam,"-") == nil then
				if groupSummonStatus[nam.."-"..GetRealmName()] == nil then
					groupSummonStatus[nam.."-"..GetRealmName()] = {Hide = false, Summ = false}
				end
				if groupSummonStatus[nam.."-"..GetRealmName()].Hide == true then
					listEntries[k]:Hide()
				else
					if groupSummonStatus[nam.."-"..GetRealmName()].Summ == true then
						listEntries[k]:Show()
					else
						listEntries[k]:Hide()
					end
				end
			else
				if groupSummonStatus[nam] == nil then
					groupSummonStatus[nam] = {Hide = false, Summ = false}
				end
				if groupSummonStatus[nam].Hide == true then
					listEntries[k]:Hide()
				else
					if groupSummonStatus[nam].Summ == true then
						listEntries[k]:Show()
					else
						listEntries[k]:Hide()
					end
				end
				
			end


		end
	end
	SummonCheck:HideListEntry()
end
end
function SummonCheck:HideListEntry()
	local hiddens = 0
if InCombatLockdown() == nil then
	for k = 0, 39 do
		nam, ran, subgroup, leve, clas, fileNam, zon, onlin, isDead, rol, isML = GetRaidRosterInfo(k+1)
		if listEntries[k]:IsShown()  then
			listEntries[k]:SetPoint("TOPLEFT",content,-15,-1*(k-hiddens)*29)
		else
			if nam == nil then
				
				hiddens = hiddens + 1
			else
				if strfind(nam,"-") == nil then
					if groupSummonStatus[nam.."-"..GetRealmName()].Summ == false then
						hiddens = hiddens + 1
					else

					end
				else
					if groupSummonStatus[nam].Summ == false then
						hiddens = hiddens + 1
					else
					
					end
				end
			end
		end
		
	end
	content:SetSize(128, hiddens*2*26)
	if (40-hiddens)*29 ~= 0 then
		scrollbar:SetMinMaxValues(1, (40-hiddens)*25)

	else
		scrollbar:SetMinMaxValues(1, 2)
	end
	end
end
function SummonCheck:UpdateName (index, unit)

	local name = UnitName(unit) or UNKNOWN
--	listEntries[k].unitButton.elename:SetText(name)
end
function SummonListEntryTemplate_OnLoad()

end