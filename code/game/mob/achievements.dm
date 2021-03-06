/mob/proc/unlock_medal(title, announce, desc, diff)

	spawn ()
		if (ismob(src) && src.key)
			var/list/keys = list()
			var/DBQuery/cquery = dbcon.NewQuery("SELECT `medal` FROM `medals` WHERE ckey='[src.ckey]'")
			var/DBQuery/kquery = dbcon.NewQuery("SELECT `ckey` FROM `medals` WHERE ckey='[src.ckey]'")
			if(!kquery.Execute())
				messageadmins(cquery.ErrorMsg())
				world.log_admin(cquery.ErrorMsg())
			else
				while(kquery.NextRow())
					keys = kquery.GetRowData()
			if(!cquery.Execute())
				messageadmins(cquery.ErrorMsg())
				world.log_admin(cquery.ErrorMsg())
			else
				while(cquery.NextRow())
					var/list/column_data = cquery.GetRowData()
					for(var/P in keys)
						if(title == column_data["medal"])
							return
			var/DBQuery/xquery = dbcon.NewQuery("REPLACE INTO `medals` (`ckey`, `medal`, `medaldesc`, `medaldiff`) VALUES ('[src.ckey]', '[escape_string(title)]', '[escape_string(desc)]', '[diff]');")
			if(!xquery.Execute())
				messageadmins(xquery.ErrorMsg())
				world.log_admin(xquery.ErrorMsg())
				src << "Medal save failed"
			var/H
			switch(diff)
				if ("medium")
					H = "#EE9A4D"
				if ("easy")
					H = "green"
				if ("hard")
					H = "red"
			if (announce)
				world << "<b>Achievement Unlocked!: [src.key] unlocked the '<font color = [H]>[title]</font color>' achievement.</b></font>"
				src << text("[desc]")
			else if (!announce)
				src << "<b>Achievement Unlocked!: You unlocked the '<font color = [H]>[title]</font color>' achievement.</b></font>"
				src << text("[desc]")

/proc/escape_string(var/t)
	var/s = replace(t, "\\", "\\\\")
	s = replace(s, "'", "\\'")
	return s

mob/verb/show_medal()
	set name = "Show Achievements"
	set category = "Commands"
	var/DBQuery/xquery = dbcon.NewQuery("SELECT `ckey` FROM `medals` WHERE ckey='[src.ckey]'")
	var/DBQuery/gquery = dbcon.NewQuery("SELECT * FROM `medals` WHERE ckey='[src.ckey]'")
	var/list/keys = list()
	var/cooldown
	var/cooldownt
	if(cooldown)
		src << "Spam protection [cooldownt] left"
	if(xquery.Execute())
		while(xquery.NextRow())
			keys = xquery.GetRowData()
	else
		src << "You have no medals"
		messageadmins(xquery.ErrorMsg())
		world.log_admin(xquery.ErrorMsg())
	if(gquery.Execute())
		while(gquery.NextRow())
			var/list/column_data = gquery.GetRowData()
			for(var/P in keys)
				var/title = column_data["medal"]
				var/desc = column_data["medaldesc"]
				var/diff = column_data["medaldiff"]
				var/H
				switch(diff)
					if ("medium")
						H = "#EE9A4D"
					if ("easy")
						H = "green"
					if ("hard")
						H = "red"
				src << "<font color = [H]>[title]</font color></b></font>"
				src << text("[desc]")
			cooldown = 1
			spawn(10)cooldownt--
			spawn(10)cooldownt--
			spawn(10)cooldownt-- // not very pretty i know.
			spawn(10)cooldownt--
			spawn(10)cooldownt--
			if(cooldownt==0)
				cooldown = 0

	else
		messageadmins(gquery.ErrorMsg())
		world.log_admin(gquery.ErrorMsg())