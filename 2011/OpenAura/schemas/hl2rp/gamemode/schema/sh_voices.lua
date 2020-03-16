--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- A function to add a voice.
function openAura.schema:AddVoice(faction, command, phrase, sound, female, menu)
	self.voices[#openAura.schema.voices + 1] = {
		command = command,
		faction = faction,
		phrase = phrase,
		female = female,
		sound = sound,
		menu = menu
	};
end;

-- A function to add a dispatch voice.
function openAura.schema:AddDispatchVoice(command, phrase, sound)
	self.dispatchVoices[#openAura.schema.dispatchVoices + 1] = {
		command = command,
		phrase = phrase,
		sound = sound
	};
end;

openAura.schema.voices = {};
openAura.schema.menuVoices = {};
openAura.schema.dispatchVoices = {};

openAura.schema:AddDispatchVoice("Anti-Citizen", "Attention ground units. Anti-citizen reported in this community. Code: LOCK, CAUTERIZE, STABILIZE.", "npc/overwatch/cityvoice/f_anticitizenreport_spkr.wav");
openAura.schema:AddDispatchVoice("Anti-Civil", "Protection team alert. Evidence of anti-civil activity in this community. Code: ASSEMBLE, PLAN, CONTAIN.", "npc/overwatch/cityvoice/f_anticivilevidence_3_spkr.wav");
openAura.schema:AddDispatchVoice("Person Interest", "Attention please. Unidentified person of interest confirm your civil status with local protection team immediately.", "npc/overwatch/cityvoice/f_confirmcivilstatus_1_spkr.wav");
openAura.schema:AddDispatchVoice("Citizen Inaction", "Citizen reminder. Inaction is conspiracy. Report counter behaviour to a Civil Protection team immediately.", "npc/overwatch/cityvoice/f_innactionisconspiracy_spkr.wav");
openAura.schema:AddDispatchVoice("Unrest Structure", "Alert community ground protection units, local unrest structure detected. ASSEMBLE, ADMINISTER, PACIFY.", "npc/overwatch/cityvoice/f_localunrest_spkr.wav");
openAura.schema:AddDispatchVoice("Status Evasion", "Attention protection team. Status evasion in progress in this community. RESPOND, ISOLATE, ENQUIRE.", "npc/overwatch/cityvoice/f_protectionresponse_1_spkr.wav");
openAura.schema:AddDispatchVoice("Lockdown", "Attention all ground protection teams. Judgment waiver now in effect. Capital prosecution is discretionary.", "npc/overwatch/cityvoice/f_protectionresponse_5_spkr.wav");
openAura.schema:AddDispatchVoice("Rations Deducted", "Attention occupants. Your block is now charged with permissive inactive cohesion. Five ration units deducted.", "npc/overwatch/cityvoice/f_rationunitsdeduct_3_spkr.wav");
openAura.schema:AddDispatchVoice("Inspection", "Citizen notice. Priority identification check in progress. Please assemble in your designated inspection positions.", "npc/overwatch/cityvoice/f_trainstation_assemble_spkr.wav");
openAura.schema:AddDispatchVoice("Inspection 2", "Attention please. All citizens in local residential block, assume your inspection positions.", "npc/overwatch/cityvoice/f_trainstation_assumepositions_spkr.wav");
openAura.schema:AddDispatchVoice("Miscount Detected", "Attention resident. Miscount detected in your block. Co-operation with your Civil Protection team permit full ration reward.", "npc/overwatch/cityvoice/f_trainstation_cooperation_spkr.wav");
openAura.schema:AddDispatchVoice("Infection", "Attention resident. This block contains potential civil infection. INFORM, CO-OPERATE, ASSEMBLE.", "npc/overwatch/cityvoice/f_trainstation_inform_spkr.wav");
openAura.schema:AddDispatchVoice("Relocation", "Citizen notice. Failure to co-operate will result in permanent off-world relocation.", "npc/overwatch/cityvoice/f_trainstation_offworldrelocation_spkr.wav");
openAura.schema:AddDispatchVoice("Unrest Code", "Attention community. Unrest procedure code is now in effect. INOCULATE, SHIELD, PACIFY. Code: PRESSURE, SWORD, STERILIZE.", "npc/overwatch/cityvoice/f_unrestprocedure1_spkr.wav");
openAura.schema:AddDispatchVoice("Evasion", "Attention please. Evasion behaviour consistent with mal-compliant defendant. Ground protection team, alert. Code: ISOLATE, EXPOSE, ADMINISTER.", "npc/overwatch/cityvoice/f_evasionbehavior_2_spkr.wav");
openAura.schema:AddDispatchVoice("Individual", "Individual. You are charged with social endangerment, level one. Protection unit, prosecution code: DUTY, SWORD, MIDNIGHT.", "npc/overwatch/cityvoice/f_sociolevel1_4_spkr.wav");
openAura.schema:AddDispatchVoice("Autonomous", "Attention all ground protection teams. Autonomous judgement is now in effect, sentencing is now discretionary. Code: AMPUTATE, ZERO, CONFIRM.", "npc/overwatch/cityvoice/f_protectionresponse_4_spkr.wav");
openAura.schema:AddDispatchVoice("Citizenship", "Individual. You are convicted of multi anti-civil violations. Implicit citizenship revoked. Status: MALIGNANT.", "npc/overwatch/cityvoice/f_citizenshiprevoked_6_spkr.wav");
openAura.schema:AddDispatchVoice("Malcompliance", "Individual. You are charged with capital malcompliance, anti-citizen status approved.", "npc/overwatch/cityvoice/f_capitalmalcompliance_spkr.wav");
openAura.schema:AddDispatchVoice("Exogen", "Overwatch acknowledges critical exogen breach, AirWatch augmentation force dispatched and inbound. Hold for reinforcements.", "npc/overwatch/cityvoice/fprison_airwatchdispatched.wav");
openAura.schema:AddDispatchVoice("Failure", "Attention ground units. Mission failure will result in permanent off-world assignment. Code reminder: SACRIFICE, COAGULATE, PLAN.", "npc/overwatch/cityvoice/fprison_missionfailurereminder.wav");

openAura.schema:AddVoice("Combine", "Sweeping", "Sweeping for suspect.", "npc/metropolice/hiding02.wav");
openAura.schema:AddVoice("Combine", "Isolate", "Isolate!", "npc/metropolice/hiding05.wav");
openAura.schema:AddVoice("Combine", "You Can Go", "Alright, you can go.", "npc/metropolice/vo/allrightyoucango.wav");
openAura.schema:AddVoice("Combine", "Need Assistance", "Eleven-ninety-nine, officer needs assistance!", "npc/metropolice/vo/11-99officerneedsassistance.wav");
openAura.schema:AddVoice("Combine", "Administer", "Administer.", "npc/metropolice/vo/administer.wav");
openAura.schema:AddVoice("Combine", "Affirmative", "Affirmative.", "npc/metropolice/vo/affirmative.wav");
openAura.schema:AddVoice("Combine", "All Units Move In", "All units move in!", "npc/metropolice/vo/allunitsmovein.wav");
openAura.schema:AddVoice("Combine", "Amputate", "Amputate.", "npc/metropolice/vo/amputate.wav");
openAura.schema:AddVoice("Combine", "Anti-Citizen", "Anti-citizen.", "npc/metropolice/vo/anticitizen.wav");
openAura.schema:AddVoice("Combine", "Citizen", "Citizen.", "npc/metropolice/vo/citizen.wav");
openAura.schema:AddVoice("Combine", "Copy", "Copy.", "npc/metropolice/vo/copy.wav");
openAura.schema:AddVoice("Combine", "Cover Me", "Cover me, I'm going in!", "npc/metropolice/vo/covermegoingin.wav");
openAura.schema:AddVoice("Combine", "Assist Trespass", "Assist for a criminal trespass!", "npc/metropolice/vo/criminaltrespass63.wav");
openAura.schema:AddVoice("Combine", "Destroy Cover", "Destroy that cover!", "npc/metropolice/vo/destroythatcover.wav");
openAura.schema:AddVoice("Combine", "Don't Move", "Don't move!", "npc/metropolice/vo/dontmove.wav");
openAura.schema:AddVoice("Combine", "Final Verdict", "Final verdict administered.", "npc/metropolice/vo/finalverdictadministered.wav");
openAura.schema:AddVoice("Combine", "Final Warning", "Final warning!", "npc/metropolice/vo/finalwarning.wav");
openAura.schema:AddVoice("Combine", "First Warning", "First warning, move away!", "npc/metropolice/vo/firstwarningmove.wav");
openAura.schema:AddVoice("Combine", "Get Down", "Get down!", "npc/metropolice/vo/getdown.wav");
openAura.schema:AddVoice("Combine", "Get Out", "Get out of here!", "npc/metropolice/vo/getoutofhere.wav");
openAura.schema:AddVoice("Combine", "Suspect One", "I got suspect one here.", "npc/metropolice/vo/gotsuspect1here.wav");
openAura.schema:AddVoice("Combine", "Help", "Help!", "npc/metropolice/vo/help.wav");
openAura.schema:AddVoice("Combine", "Running", "He's running!", "npc/metropolice/vo/hesrunning.wav");
openAura.schema:AddVoice("Combine", "Hold It", "Hold it right there!", "npc/metropolice/vo/holditrightthere.wav");
openAura.schema:AddVoice("Combine", "Move Along Repeat", "I said move along.", "npc/metropolice/vo/isaidmovealong.wav");
openAura.schema:AddVoice("Combine", "Malcompliance", "Issuing malcompliance citation.", "npc/metropolice/vo/issuingmalcompliantcitation.wav");
openAura.schema:AddVoice("Combine", "Keep Moving", "Keep moving!", "npc/metropolice/vo/keepmoving.wav");
openAura.schema:AddVoice("Combine", "Lock Position", "All units, lock your position!", "npc/metropolice/vo/lockyourposition.wav");
openAura.schema:AddVoice("Combine", "Trouble", "Lookin' for trouble?", "npc/metropolice/vo/lookingfortrouble.wav");
openAura.schema:AddVoice("Combine", "Look Out", "Look out!", "npc/metropolice/vo/lookout.wav");
openAura.schema:AddVoice("Combine", "Minor Hits", "Minor hits, continuing prosecution.", "npc/metropolice/vo/minorhitscontinuing.wav");
openAura.schema:AddVoice("Combine", "Move", "Move!", "npc/metropolice/vo/move.wav");
openAura.schema:AddVoice("Combine", "Move Along", "Move along!", "npc/metropolice/vo/movealong3.wav");
openAura.schema:AddVoice("Combine", "Move Back", "Move back, right now!", "npc/metropolice/vo/movebackrightnow.wav");
openAura.schema:AddVoice("Combine", "Move It", "Move it!", "npc/metropolice/vo/moveit2.wav");
openAura.schema:AddVoice("Combine", "Hardpoint", "Moving to hardpoint.", "npc/metropolice/vo/movingtohardpoint.wav");
openAura.schema:AddVoice("Combine", "Officer Help", "Officer needs help!", "npc/metropolice/vo/officerneedshelp.wav");
openAura.schema:AddVoice("Combine", "Privacy", "Possible level three civil privacy violator here!", "npc/metropolice/vo/possiblelevel3civilprivacyviolator.wav");
openAura.schema:AddVoice("Combine", "Judgement", "Suspect prepare to receive civil judgement!", "npc/metropolice/vo/prepareforjudgement.wav");
openAura.schema:AddVoice("Combine", "Priority Two", "I have a priority two anti-citizen here!", "npc/metropolice/vo/priority2anticitizenhere.wav");
openAura.schema:AddVoice("Combine", "Prosecute", "Prosecute!", "npc/metropolice/vo/prosecute.wav");
openAura.schema:AddVoice("Combine", "Amputate Ready", "Ready to amputate!", "npc/metropolice/vo/readytoamputate.wav");
openAura.schema:AddVoice("Combine", "Rodger That", "Rodger that!", "npc/metropolice/vo/rodgerthat.wav");
openAura.schema:AddVoice("Combine", "Search", "Search!", "npc/metropolice/vo/search.wav");
openAura.schema:AddVoice("Combine", "Shit", "Shit!", "npc/metropolice/vo/shit.wav");
openAura.schema:AddVoice("Combine", "Sentence Delivered", "Sentence delivered.", "npc/metropolice/vo/sentencedelivered.wav");
openAura.schema:AddVoice("Combine", "Sterilize", "Sterilize!", "npc/metropolice/vo/sterilize.wav");
openAura.schema:AddVoice("Combine", "Take Cover", "Take cover!", "npc/metropolice/vo/takecover.wav");
openAura.schema:AddVoice("Combine", "Restrict", "Restrict!", "npc/metropolice/vo/restrict.wav");
openAura.schema:AddVoice("Combine", "Restricted", "Restricted block.", "npc/metropolice/vo/restrictedblock.wav");
openAura.schema:AddVoice("Combine", "Second Warning", "This is your second warning!", "npc/metropolice/vo/thisisyoursecondwarning.wav");
openAura.schema:AddVoice("Combine", "Verdict", "You want a non-compliance verdict?", "npc/metropolice/vo/youwantamalcomplianceverdict.wav");
openAura.schema:AddVoice("Combine", "Backup", "Backup!", "npc/metropolice/vo/backup.wav");
openAura.schema:AddVoice("Combine", "Apply", "Apply.", "npc/metropolice/vo/apply.wav");
openAura.schema:AddVoice("Combine", "Restriction", "Terminal restriction zone.", "npc/metropolice/vo/terminalrestrictionzone.wav");
openAura.schema:AddVoice("Combine", "Complete", "Protection complete.", "npc/metropolice/vo/protectioncomplete.wav");
openAura.schema:AddVoice("Combine", "Location Unknown", "Suspect location unknown.", "npc/metropolice/vo/suspectlocationunknown.wav");
openAura.schema:AddVoice("Combine", "Can 1", "Pick up that can.", "npc/metropolice/vo/pickupthecan1.wav");
openAura.schema:AddVoice("Combine", "Can 2", "Pick... up... the can.", "npc/metropolice/vo/pickupthecan2.wav");
openAura.schema:AddVoice("Combine", "Wrap It", "That's it, wrap it up.", "npc/combine_soldier/vo/thatsitwrapitup.wav");
openAura.schema:AddVoice("Combine", "Can 3", "I said pickup the can!", "npc/metropolice/vo/pickupthecan3.wav");
openAura.schema:AddVoice("Combine", "Can 4", "Now, put it in the trash can.", "npc/metropolice/vo/putitinthetrash1.wav");
openAura.schema:AddVoice("Combine", "Can 5", "I said put it in the trash can!", "npc/metropolice/vo/putitinthetrash2.wav");
openAura.schema:AddVoice("Combine", "Now Get Out", "Now get out of here!", "npc/metropolice/vo/nowgetoutofhere.wav");
openAura.schema:AddVoice("Combine", "Haha", "Haha.", "npc/metropolice/vo/chuckle.wav");
openAura.schema:AddVoice("Combine", "X-Ray", "X-Ray!", "npc/metropolice/vo/xray.wav");
openAura.schema:AddVoice("Combine", "Patrol", "Patrol!", "npc/metropolice/vo/patrol.wav");
openAura.schema:AddVoice("Combine", "Serve", "Serve.", "npc/metropolice/vo/serve.wav");
openAura.schema:AddVoice("Combine", "Knocked Over", "You knocked it over, pick it up!", "npc/metropolice/vo/youknockeditover.wav");
openAura.schema:AddVoice("Combine", "Watch It", "Watch it!", "npc/metropolice/vo/watchit.wav");
openAura.schema:AddVoice("Combine", "Restricted Canals", "Suspect is using restricted canals at...", "npc/metropolice/vo/suspectusingrestrictedcanals.wav");
openAura.schema:AddVoice("Combine", "505", "Subject is five-oh-five!", "npc/metropolice/vo/subjectis505.wav");
openAura.schema:AddVoice("Combine", "404", "Possible four-zero-oh here!", "npc/metropolice/vo/possible404here.wav");
openAura.schema:AddVoice("Combine", "Vacate", "Vacate citizen!", "npc/metropolice/vo/vacatecitizen.wav");
openAura.schema:AddVoice("Combine", "Escapee", "Priority two escapee.", "npc/combine_soldier/vo/prioritytwoescapee.wav");
openAura.schema:AddVoice("Combine", "Objective", "Priority one objective.", "npc/combine_soldier/vo/priority1objective.wav");
openAura.schema:AddVoice("Combine", "Payback", "Payback.", "npc/combine_soldier/vo/payback.wav");
openAura.schema:AddVoice("Combine", "Got Him Now", "Affirmative, we got him now.", "npc/combine_soldier/vo/affirmativewegothimnow.wav");
openAura.schema:AddVoice("Combine", "Antiseptic", "Antiseptic.", "npc/combine_soldier/vo/antiseptic.wav");
openAura.schema:AddVoice("Combine", "Cleaned", "Cleaned.", "npc/combine_soldier/vo/cleaned.wav");
openAura.schema:AddVoice("Combine", "Engaged Cleanup", "Engaged in cleanup.", "npc/combine_soldier/vo/engagedincleanup.wav");
openAura.schema:AddVoice("Combine", "Engaging", "Engaging.", "npc/combine_soldier/vo/engaging.wav");
openAura.schema:AddVoice("Combine", "Full Response", "Executing full response.", "npc/combine_soldier/vo/executingfullresponse.wav");
openAura.schema:AddVoice("Combine", "Heavy Resistance", "Overwatch advise, we have heavy resistance.", "npc/combine_soldier/vo/heavyresistance.wav");
openAura.schema:AddVoice("Combine", "Inbound", "Inbound.", "npc/combine_soldier/vo/inbound.wav");
openAura.schema:AddVoice("Combine", "Lost Contact", "Lost contact!", "npc/combine_soldier/vo/lostcontact.wav");
openAura.schema:AddVoice("Combine", "Move In", "Move in!", "npc/combine_soldier/vo/movein.wav");
openAura.schema:AddVoice("Combine", "Harden Position", "Harden that position!", "npc/combine_soldier/vo/hardenthatposition.wav");
openAura.schema:AddVoice("Combine", "Go Sharp", "Go sharp, go sharp!", "npc/combine_soldier/vo/gosharpgosharp.wav");
openAura.schema:AddVoice("Combine", "Delivered", "Delivered.", "npc/combine_soldier/vo/delivered.wav");
openAura.schema:AddVoice("Combine", "Necrotics Inbound", "Necrotics, inbound!", "npc/combine_soldier/vo/necroticsinbound.wav");
openAura.schema:AddVoice("Combine", "Necrotics", "Necrotics.", "npc/combine_soldier/vo/necrotics.wav");
openAura.schema:AddVoice("Combine", "Outbreak", "Outbreak!", "npc/combine_soldier/vo/outbreak.wav");
openAura.schema:AddVoice("Combine", "Copy That", "Copy that.", "npc/combine_soldier/vo/copythat.wav");
openAura.schema:AddVoice("Combine", "Outbreak Status", "Outbreak status is code.", "npc/combine_soldier/vo/outbreakstatusiscode.wav");
openAura.schema:AddVoice("Combine", "Overwatch", "Overwatch!", "npc/combine_soldier/vo/overwatch.wav");
openAura.schema:AddVoice("Combine", "Preserve", "Preserve!", "npc/metropolice/vo/preserve.wav");
openAura.schema:AddVoice("Combine", "Pressure", "Pressure!", "npc/metropolice/vo/pressure.wav");
openAura.schema:AddVoice("Combine", "Phantom", "Phantom!", "npc/combine_soldier/vo/phantom.wav");
openAura.schema:AddVoice("Combine", "Stinger", "Stinger!", "npc/combine_soldier/vo/stinger.wav");
openAura.schema:AddVoice("Combine", "Shadow", "Shadow!", "npc/combine_soldier/vo/shadow.wav");
openAura.schema:AddVoice("Combine", "Savage", "Savage!", "npc/combine_soldier/vo/savage.wav");
openAura.schema:AddVoice("Combine", "Reaper", "Reaper!", "npc/combine_soldier/vo/reaper.wav");
openAura.schema:AddVoice("Combine", "Victor", "Victor!", "npc/metropolice/vo/victor.wav");
openAura.schema:AddVoice("Combine", "Sector", "Sector!", "npc/metropolice/vo/sector.wav");
openAura.schema:AddVoice("Combine", "Inject", "Inject!", "npc/metropolice/vo/inject.wav");
openAura.schema:AddVoice("Combine", "Dagger", "Dagger!", "npc/combine_soldier/vo/dagger.wav");
openAura.schema:AddVoice("Combine", "Blade", "Blade!", "npc/combine_soldier/vo/blade.wav");
openAura.schema:AddVoice("Combine", "Razor", "Razor!", "npc/combine_soldier/vo/razor.wav");
openAura.schema:AddVoice("Combine", "Nomad", "Nomad!", "npc/combine_soldier/vo/nomad.wav");
openAura.schema:AddVoice("Combine", "Judge", "Judge!", "npc/combine_soldier/vo/judge.wav");
openAura.schema:AddVoice("Combine", "Ghost", "Ghost!", "npc/combine_soldier/vo/ghost.wav");
openAura.schema:AddVoice("Combine", "Sword", "Sword!", "npc/combine_soldier/vo/sword.wav");
openAura.schema:AddVoice("Combine", "Union", "Union!", "npc/metropolice/vo/union.wav");
openAura.schema:AddVoice("Combine", "Helix", "Helix!", "npc/combine_soldier/vo/helix.wav");
openAura.schema:AddVoice("Combine", "Storm", "Storm!", "npc/combine_soldier/vo/storm.wav");
openAura.schema:AddVoice("Combine", "Spear", "Spear!", "npc/combine_soldier/vo/spear.wav");
openAura.schema:AddVoice("Combine", "Vamp", "Vamp!", "npc/combine_soldier/vo/vamp.wav");
openAura.schema:AddVoice("Combine", "Nova", "Nova!", "npc/combine_soldier/vo/nova.wav");
openAura.schema:AddVoice("Combine", "Mace", "Mace!", "npc/combine_soldier/vo/mace.wav");
openAura.schema:AddVoice("Combine", "Grid", "Grid!", "npc/combine_soldier/vo/grid.wav");
openAura.schema:AddVoice("Combine", "Kilo", "Kilo!", "npc/combine_soldier/vo/kilo.wav");
openAura.schema:AddVoice("Combine", "Echo", "Echo!", "npc/combine_soldier/vo/echo.wav");
openAura.schema:AddVoice("Combine", "Dash", "Dash!", "npc/combine_soldier/vo/dash.wav");
openAura.schema:AddVoice("Combine", "Apex", "Apex!", "npc/combine_soldier/vo/apex.wav");
openAura.schema:AddVoice("Combine", "Jury", "Jury!", "npc/metropolice/vo/jury.wav");
openAura.schema:AddVoice("Combine", "King", "King!", "npc/metropolice/vo/king.wav");
openAura.schema:AddVoice("Combine", "Lock", "Lock!", "npc/metropolice/vo/lock.wav");
openAura.schema:AddVoice("Combine", "Vice", "Vice!", "npc/metropolice/vo/vice.wav");
openAura.schema:AddVoice("Combine", "Zero", "Zero!", "npc/metropolice/vo/zero.wav");
openAura.schema:AddVoice("Combine", "Zone", "Zone!", "npc/metropolice/vo/zone.wav");