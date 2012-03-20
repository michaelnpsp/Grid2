-- Players Buffs & Debuffs, used by StatusAuraNewPredictor.lua
-- player_buffs total: 466 generated: 03/19/12 21:37:14
Grid2Options.PlayerBuffs =  {
	["ALL"] = { 109744,101185,107962,106466,109802,74243,92730,109793,87551,107947,87840,107948,54758,65116,107982,74497,96229,92731,90992,109963,
		102435,87558,74245,87547,75170,87550,106664,107966,102660,59547,73313,110660,101293,92729,87545,102659,101291,102664,82627,87546,102667,
		92725,109709,74241,109776,107988,87556,79634,59752,96230,53755,87554,109717,109742,79470,68992,109748,89091,58984,79471,54861,87557,
		74224,92104,105144,109811,79633,109774,91047,107960,109787,79476,57334,},
	["DEATHKNIGHT"] = { 55233,50421,48265,91342,81162,48792,91816,51460,57330,49016,105647,81141,48707,108008,96171,55610,53365,53748,101568,42650,
		81256,91821,107949,63560,105582,79638,81340,3714,92184,51124,51271,59052,77535,48266,49222,45529,},
	["DRUID"] = { 61336,740,79061,16870,96962,105713,5217,48418,16886,774,44203,768,100977,48420,48421,24907,29166,5487,16689,80886,
		69369,8936,17057,48517,33763,33891,5229,81262,48391,77764,783,81006,52610,40120,50334,5215,22812,51185,16914,81022,24932,
		24858,48504,48505,96206,17116,48518,93400,48438,1850,},
	["HUNTER"] = { 13159,53257,5118,53220,96911,92099,34477,3045,82661,82921,13165,56453,96978,982,108687,20043,95712,35099,83359,51755,
		19577,92124,105919,19574,82926,136,89388,54227,64420,19263,99621,109860,34471,109861,77769,94007,35079,82692,19506,},
	["MAGE"] = { 10,12042,6117,11426,79683,7302,83098,83582,64343,90896,80353,47000,57761,57531,44413,105785,543,79058,32612,66,
		12472,130,79038,30482,53908,55342,46989,48108,12051,1953,82930,58501,12043,45438,1463,44544,79057,91019,54646,54648,12536,},
	["PALADIN"] = { 20154,84963,31842,79063,642,31850,85497,86669,53657,79062,79101,31884,85696,105819,85433,94686,20053,20178,85416,105742,
		105801,53563,89906,74221,91810,25780,90174,54428,87173,70940,86700,82327,32223,79102,86698,498,31930,31801,96263,26573,31821,
		54149,23214,19746,20925,59578,19891,465,86273,107968,20165,88819,1044,88063,7294,107951,},
	["PRIEST"] = { 15286,81700,89485,87160,59888,79632,81206,48045,139,88688,27827,47585,77613,47788,77487,64901,79106,95799,32409,1706,
		105826,586,588,81301,15357,45242,63735,10060,87118,90885,33143,47753,15473,91147,33206,79107,91138,96267,14893,64844,14751,
		7001,64904,41635,65081,73413,87153,64843,91724,81661,17,79105,56161,79104,77489,},
	["ROGUE"] = { 59628,13877,74001,51690,84745,5171,84747,109959,84746,1966,1784,96228,105864,13750,2983,73651,31224,5277,57933,57934,
		76577,},
	["SHAMAN"] = { 974,53817,16188,105877,52127,51470,73683,324,29178,105821,105779,79206,16278,61295,51945,105869,73681,101289,30808,105284,
		61882,16246,73685,32182,16166,53390,16236,2645,64701,30823,105763,},
	["WARLOCK"] = { 74434,94318,54372,28176,54277,105786,91711,85768,79268,48020,54374,85383,1949,54371,85759,94311,48018,94310,79459,85767,
		5740,54375,},
	["WARRIOR"] = { 101492,50227,73320,60503,20230,12976,109780,23920,18499,97010,50720,52437,105909,57519,12964,87096,105914,871,2458,86627,
		105860,16491,6673,85730,2457,55694,71,2565,57516,97954,12328,46924,65156,32216,80396,90806,84620,84586,469,1134,1719,
		97463,},
}
-- player_debuffs total: 143 generated: 03/19/12 21:37:14
Grid2Options.PlayerDebuffs = {
	["ALL"] = { 57723,95223,},
	["DEATHKNIGHT"] = { 50435,43265,49560,81130,81326,98957,73975,49206,55741,47476,50536,55095,45524,96294,51399,56222,55078,51714,65142,},
	["DRUID"] = { 8921,33876,1822,60433,50259,22570,91565,93402,58180,1079,108095,5570,},
	["HUNTER"] = { 1130,109856,1978,13810,3674,13812,82654,34490,5116,63468,19503,35101,88453,3355,53301,20736,88691,},
	["MAGE"] = { 31661,31589,120,44614,12355,116,11113,87023,88148,83853,41425,36032,44457,22959,28272,83154,12654,122,61305,84721,
		2120,55021,83047,92315,11366,118,},
	["PALADIN"] = { 68055,2812,62124,25771,31935,31790,31803,879,853,26017,},
	["PRIEST"] = { 34914,48301,589,87178,14914,15407,2944,6788,},
	["ROGUE"] = { 99173,13218,2818,84617,2094,6770,51722,51585,1776,58683,1943,408,1833,},
	["SHAMAN"] = { 17364,51514,8042,77661,8050,},
	["WARLOCK"] = { 603,17800,5782,47960,18118,29341,80240,27243,30283,172,85421,702,348,1490,},
	["WARRIOR"] = { 7922,86346,58567,96273,12294,94009,12809,46857,355,46968,18498,1160,6343,64382,1161,82406,12721,},
}
