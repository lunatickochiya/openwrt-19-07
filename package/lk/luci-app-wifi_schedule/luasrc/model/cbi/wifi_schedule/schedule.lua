
require("luci.tools.webadmin")

local fs = require "nixio.fs"
local sys = require "luci.sys"
local wifilist =  sys.exec("uci show wireless |grep \"\\.ssid\"\|awk -F [=] '{print $2}' |tr -d \"'\" > /var/etc/wifilist")
local schedulelist =  sys.exec("cat /etc/config/wifi_schedule |grep days |awk '{print $3}' |tr -d \"'\" > /var/etc/schedulelist")

local wifi_schedule =(luci.sys.call("pidof wifi_schedule > /dev/null") == 0)
if wifi_schedule then	
	m = Map("wifi_schedule", translate("Wifi Schedule"), "<b><font color=\"green\">" .. translate("Wifi Schedule is running!") .. "</font></b>")
else
	m = Map("wifi_schedule", translate("Wifi Schedule"), "<b><font color=\"red\">" .. translate("Wifi Schedule is not running.") .. "</font></b>")
end

s = m:section(NamedSection, "config", "wifi_schedule", translate("config"), translate("Wifi Schedule is a very useful app which will allow you to manage and schedule when your device Wi-Fi will turn on and off."))

e = s:option(Flag, "enabled", translate("Enable"), translate("Enable or disable Wifi Schedule."))
e.rmempty = false
e.default = e.enabled

function e.write(self, section, value)
	if value == "0" then
		os.execute("/etc/init.d/wifi_schedule stop")
		os.execute("/etc/init.d/wifi_schedule disable")
	else
		os.execute("/etc/init.d/wifi_schedule enable")
		os.execute("/etc/init.d/wifi_schedule restart")
	end
	Flag.write(self, section, value)
end

o = s:option(Value, "interval", translate("Interval to query for changes"), translate("In seconds"))
o.optional = true
o.datatype = "and(uinteger,min(30))"
o.default = 30

s = m:section(TypedSection, "device", translate("Device"))
s.addremove = true
s.anonymous = true

ssid = s:option(Value, "ssid", translate("ssid"), translate("Select ssid to control."))
for i_1 in io.popen("cat /var/etc/wifilist", "r"):lines() do
    ssid:value(i_1)
end

list = s:option(Value, "list", translate("schedulelist"), translate("Select schedulelist for upper ssid."))
for i_1 in io.popen("cat /var/etc/schedulelist", "r"):lines() do
    list:value(i_1)
end

s = m:section(TypedSection, "days", translate("Schedulelist"), translate("Define time for wifi_schedule."))
s.addremove = true
--s.anonymous = true

s:tab("wd1", translate("Monday"))
s:tab("wd2", translate("Tuesday"))
s:tab("wd3", translate("Wednesday"))
s:tab("wd4", translate("Thursday"))
s:tab("wd5", translate("Friday"))
s:tab("wd6", translate("Saturday"))
s:tab("wd7", translate("Sunday"))

for day=1,7 do
	for i=0,23 do
		f=i
		t=i+1
		s:taboption("wd"..day, Flag, day.."_"..f,
        		translate(f..":00 - "..t..":00"),
	        	translate(""))
	end
end

return m
