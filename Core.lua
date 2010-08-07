WhyWontYouCallMeBack = CreateFrame("frame")

-----------------------------
--  Debugging stuff        --
-----------------------------

local debugf = tekDebug and tekDebug:GetFrame("WhyWontYouCallMeBack")
local function Debug(...)
	if debugf then
		debugf:AddMessage(string.join(", ", ...))
	end
end

-----------------------------
--      Event Handler      --
-----------------------------

WhyWontYouCallMeBack:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)
WhyWontYouCallMeBack:RegisterEvent("ADDON_LOADED")
function WhyWontYouCallMeBack:Print(...) ChatFrame1:AddMessage(string.join(" ", "|cFF33FF99WhyWontYouCallMeBack|r:", ...)) end


function WhyWontYouCallMeBack:ADDON_LOADED(event, addon)
	if addon:lower() ~= "whywontyoucallmeback" then return end

	self:UnregisterEvent("ADDON_LOADED")
	self.ADDON_LOADED = nil

	if IsLoggedIn() then self:PLAYER_LOGIN() else self:RegisterEvent("PLAYER_LOGIN") end
end


function WhyWontYouCallMeBack:PLAYER_LOGIN()
	self:RegisterEvent("PLAYER_LOGOUT")

	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("CHAT_MSG_WHISPER")
	self:RegisterEvent("CHAT_MSG_BN_WHISPER")

	self.ImpatientPeople = {}
	self.dirty = false
	self.prefix = "<WhyWontYouCallMeBack>"
	self.inCombatMsg = self.prefix .. " In combat. You will automatically be sent a message when combat is over."
	self.outOfCombatMsg = self.prefix .. " Out of combat."


	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
end


function WhyWontYouCallMeBack:PLAYER_LOGOUT()
end


function WhyWontYouCallMeBack:PLAYER_REGEN_ENABLED()
	Debug("Out of Combat")
	--self:Print("Out of Combat")
	if not self.dirty then return end

	for i,v in pairs(self.ImpatientPeople) do
		if v=="Reg" then
			SendChatMessage(self.outOfCombatMsg,"WHISPER",nil,i)
			Debug("Sending out of combat msg via regular whisper to "..i)
		else
			BNSendWhisper(v, self.outOfCombatMsg)
			local _,f,l,t = BNGetFriendInfoByID(v)
			Debug("Sending out of combat msg via BN whisper to "..v..", aka "..f.." "..l.." aka "..t)
		end
		self.ImpatientPeople[i] = nil
	end

	-- this shouldn't really be necessary any more, but better safe than sorry
	self.ImpatientPeople = {}
end


function WhyWontYouCallMeBack:CHAT_MSG_WHISPER(event, msg, from, ...)
--~ 	Debug("I got a regular whisper!")
--~ 	Debug(msg..":"..from)
	if not InCombatLockdown() then return end
	self.dirty = true
	if not self.ImpatientPeople[from] then
		self.ImpatientPeople[from] = "Reg"
		SendChatMessage("<WhyWontYouCallMeBack> This is an auto-responder. In combat; you will automatically be sent a message once combat is over.", "WHISPER",nil,from)
	end
end

function WhyWontYouCallMeBack:CHAT_MSG_BN_WHISPER(event, msg, ...)
--~ 	Debug("I got a BN whisper!")
	local name = select(1,...)
--~ 	Debug(msg..":"..name)
	if not InCombatLockdown() then return end
	self.dirty = true
	if not self.ImpatientPeople[name] then
		local from = select(12,...)
		self.ImpatientPeople[name] = from
		BNSendWhisper(from,"<WhyWontYouCallMeBack> This is an auto-responder. In combat; you will automatically be sent a message once combat is left.")
	end
end
