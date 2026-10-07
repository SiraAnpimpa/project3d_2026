from pathlib import Path

root = Path(__file__).resolve().parents[1]
out = root/'assets/ui/items'
ink = '#23382e'

def svg(body):
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="96" height="96" viewBox="0 0 96 96"><g stroke="{ink}" stroke-width="3" stroke-linejoin="round" stroke-linecap="round">{body}</g></svg>\n'

art = {
    'lead': '<path d="M12 52 25 37H65L76 52 68 69H16Z" fill="#8295ab"/><path d="M12 52H76L68 69H16Z" fill="#526a83"/><path d="M27 37 37 24H77L86 37 80 53H76L65 37Z" fill="#a5b7c8"/><path d="M37 24H77L86 37H65" fill="#d0d8d9"/><path d="M22 47H60M38 30H71" stroke="#dbe1db"/>',
    'iron': '<path d="M17 24 70 19 82 69 29 77Z" fill="#6b7e7f"/><path d="m17 24 12 53 7-8-11-41 45-4V19Z" fill="#bdc8c4"/><path d="m31 34 8 29 28-4-8-29Z" fill="#405658"/><path d="m39 39 5 16 13-2-4-16Z" fill="#98aaa4"/><g fill="#d7dfd6"><circle cx="31" cy="32" r="3"/><circle cx="63" cy="28" r="3"/><circle cx="37" cy="65" r="3"/><circle cx="70" cy="60" r="3"/></g>',
    'copper': '<path d="M74 65q10 0 10-9V47" fill="none" stroke="#de9466" stroke-width="9"/><ellipse cx="48" cy="49" rx="29" ry="28" fill="#af6644"/><ellipse cx="48" cy="49" rx="21" ry="20" fill="#edb283"/><ellipse cx="48" cy="49" rx="12" ry="11" fill="#273d32"/><path d="M24 35q23-27 47-1M23 57q23 26 49-2" fill="none" stroke="#f5c59a" stroke-width="4"/>',
    'paper': '<path d="m17 26 48-9 16 56-48 10Z" fill="#b6b99f"/><path d="M23 16H65L78 29V75H23Z" fill="#f4e7c3"/><path d="M65 16V29H78" fill="#c7c6a5"/><path d="M33 41H64M33 51H64M33 61H56" stroke="#9caa91"/>',
    'small_herb': '<path d="M47 81V31M47 65 27 47M47 52 69 32" fill="none" stroke="#b1c89a" stroke-width="5"/><path d="M45 63Q14 67 13 35 45 34 45 63Z" fill="#7ead6f"/><path d="M49 49Q48 18 83 18 85 48 49 49Z" fill="#a7c584"/><path d="M47 38Q27 21 44 9 65 18 47 38Z" fill="#d0dba5"/><path d="M22 44 40 59M59 39 73 28" stroke="#425e3e"/>',
    'fire_essence': '<path d="M48 7Q51 29 69 33 72 22 73 20 90 43 79 67 72 85 48 86 16 85 15 59 14 40 31 25 31 43 38 43 48 24 48 7Z" fill="#d9764e"/><path d="M48 32Q49 47 61 53 78 74 49 79 26 77 32 60Z" fill="#f3b768"/><path d="M49 54Q62 67 53 74 38 75 40 67Z" fill="#f8ebc2"/>',
    'ice_crystal': '<path d="m17 45 13-20 20 13-7 37-22-9Z" fill="#82bec8"/><path d="m30 25 6 26-15 15M36 51 50 38" fill="none"/><path d="M42 66 48 18 66 7 80 34 71 82 50 87Z" fill="#b5e0df"/><path d="M59 43 71 82 50 87Z" fill="#5d97b5"/><path d="M48 18 59 43 66 7M59 43 80 34M59 43 50 87" fill="none"/>',
    'poison_extract': '<path d="M35 22H62V38L75 54V78Q47 89 21 78V54L35 38Z" fill="#c3c8c0"/><path d="M27 58q24-9 42 0V74q-21 8-42 0Z" fill="#9bb85b"/><path d="M31 16H66V28H31Z" fill="#9e7dba"/><path d="M38 59q11-20 19 0L60 70H35Z" fill="#5a683e"/><circle cx="47" cy="64" r="2" fill="#d6e6a6"/><path d="M28 47 36 39V32" stroke="#f7f3df" fill="none"/>',
    'wooden_bat': '<path d="M17 80 41 48Q44 41 45 35L68 12Q77 7 85 17 89 22 83 30L60 54Q53 55 47 61L26 85Z" fill="#c08a56"/><path d="M22 74 30 81M27 68 35 75M32 62 40 69" stroke="#eee0b6" stroke-width="5"/><path d="m52 44 23-24" stroke="#e6b478" stroke-width="4"/><path d="M14 83 23 90 30 84 20 76Z" fill="#697866"/>',
    'basic_rifle': '<path d="M6 57 29 40 40 41 45 54 24 58 16 72 6 68Z" fill="#c08a56"/><path d="M34 36H65V52H35Z" fill="#b1c2bf"/><path d="M62 39H88V47H62Z" fill="#dee0cd"/><path d="M84 36H90V50H84Z" fill="#798b85"/><path d="M45 52 43 67H57L59 52Z" fill="#61786e"/><path d="M35 52 32 61 39 64 43 53M46 36V28H59V36" fill="#788d82"/><path d="M46 28H62" stroke="#eee5ce" stroke-width="5"/><path d="M14 61 25 52M47 41H58" stroke="#f3d2a0"/>',
    'basic_medicine': '<path d="M17 30H79V77Q48 87 17 77Z" fill="#e9d9b6"/><path d="M28 30V16H67V30" fill="none" stroke="#a9bd9a" stroke-width="6"/><path d="M17 30H79V40H17Z" fill="#b2c894"/><path d="M40 45H55V54H64V69H55V78H40V69H31V54H40Z" fill="#ac6453"/>',
    'metal_component': '<path d="m48 12 10 7 12-2 5 13 11 7-5 12 3 13-13 5-7 11-13-4-12 4-7-11-13-5 3-13-5-12 11-7 5-13 12 2Z" fill="#b3c1b6"/><circle cx="49" cy="47" r="21" fill="#5d746a"/><path d="M42 35H57V59H42Z" fill="#ddc99a"/><path d="M42 42H57M42 52H57"/>',
}

def ammo(accent, symbol=''):
    return '<path d="M11 59H85V82H11Z" fill="#768c6c"/><path d="M19 59V26L28 12 37 26V59M40 59V22L49 8 58 22V59M61 59V26L70 12 79 26V59" fill="#e4bd78"/><path d="M19 36H37M40 32H58M61 36H79" stroke="#fcdf9e"/>' + f'<path d="M11 59H85V70H11Z" fill="{accent}"/>' + symbol

art['basic_ammo'] = ammo('#bda577','<path d="M36 77H61" stroke="#f1e3bd"/>')
art['fire_ammo'] = ammo('#c96e4a','<path d="M46 65Q61 75 54 84 45 90 38 81 35 75 41 71L43 78Z" fill="#f9d18d"/>')
art['ice_ammo'] = ammo('#7bb5c1','<path d="m49 68-9 9 9 9 9-9Z" fill="#e0f5ec"/>')
art['poison_ammo'] = ammo('#9879af','<path d="M49 68Q33 80 42 84 52 92 58 82 59 79 49 68Z" fill="#c6da83"/>')

seeds = {
    'seed_lead': ('lead','#8295ab'), 'seed_paper': ('paper','#e1c798'),
    'seed_copper': ('copper','#de9466'), 'seed_iron': ('iron','#8ba69c'),
    'seed_small_herb': ('small_herb','#a7c584'), 'seed_fire_pepper': ('fire_essence','#df8355'),
    'seed_ice_plant': ('ice_crystal','#83c8d6'), 'seed_poison_plant': ('poison_extract','#ac8ac4')
}
for seed,(material,accent) in seeds.items():
    art[seed] = f'<path d="M20 12H76L72 86H24Z" fill="#f0dfb6"/><path d="M20 12H76L74 28H22Z" fill="{accent}"/><path d="M25 17H71" stroke="#f6ebd0"/><g transform="translate(26 29) scale(.46)">{art[material]}</g><path d="M25 74H71" stroke="{accent}" stroke-width="4"/><g fill="{accent}"><ellipse cx="35" cy="80" rx="3" ry="2"/><ellipse cx="48" cy="80" rx="3" ry="2"/><ellipse cx="61" cy="80" rx="3" ry="2"/></g>'

assert len(art)==24
for name,body in art.items():
    (out/f'{name}.svg').write_text(svg(body),encoding='utf-8')
print('Drew',len(art),'transparent, original SVG item illustrations.')
