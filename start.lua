shell.run("github clone RosesAreMerry/CCScripts -b main")
shell.run("cp CCScripts/start.lua /")
shell.run("rename startup.lua oldstart.lua")
shell.run("rename start.lua startup.lua")
shell.run("CCScripts/entry.lua")
shell.run("delete oldstart.lua")
-- Does this get copied?