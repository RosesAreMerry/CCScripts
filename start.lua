-- Clone the repo to CCScripts (Could check version at some point)
shell.run("github clone RosesAreMerry/CCScripts -b main")

-- delete old scripts folder and rename. (So that files actually get deleted when they are no longer in git)
shell.run("delete scripts")
shell.run("rename CCScripts scripts")

-- Replace current startup with new startup file from git. Rename currently running file.
shell.run("cp scripts/start.lua /")
shell.run("rename startup.lua oldstart.lua")
shell.run("rename start.lua startup.lua")

-- Enter program
shell.run("scripts/entry.lua")

-- Delete current file.
shell.run("delete oldstart.lua")