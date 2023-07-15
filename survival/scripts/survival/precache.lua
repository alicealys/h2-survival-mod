game:precacheshader("dpad_killstreak_sentry_gun_static_frontend")
game:precacheshader("hud_icon_rpg_dpad")
game:precacheshader("hud_us_smokegrenade")
game:precachemodel("sentry_minigun")
game:precachemodel("sentry_grenade_launcher")
game:precacheturret("sentry_grenade_launcher")
game:precacheturret("sentry_gun")
game:precachemodel("com_plasticcase_green_big")
game:precachemodel("viewmodel_ussmokegrenade")
game:precachemodel("vehicle_little_bird_armed")
game:precachemodel("vehicle_mi17_woodland_fly_cheap")
game:precachemodel("vehicle_little_bird_minigun_left")
game:precachemodel("vehicle_little_bird_minigun_right")

game:precachemodel("vehicle_ac130_low")
game:precachemodel("vehicle_ucav")

game:precacheshader("specialty_armorvest")
game:precacheshader("specialty_fastreload")

local weapons = game:assetlist("weapon")
for i = 1, #weapons do
    game:precacheitem(weapons[i])
end
