/// lvl_aero — Aero showcase (Cryo support; Geo locked for now)
level_name = "Aero: Wind & Gaps";
tutorial_hint = "4=Aero (gap jumps + wind lift). 2=Cryo freezes water.";
show_hint = true;

roles_enabled[ROLE.GEO]  = false;
roles_enabled[ROLE.CRYO] = true;
roles_enabled[ROLE.AEGI] = false;
roles_enabled[ROLE.AERO] = true;
