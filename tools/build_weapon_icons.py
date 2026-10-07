"""Original transparent SVG weapon illustrations for the game's existing items.

Run directly to rebuild only weapons. build_ui_item_icons.py also imports these
definitions so a full item-art rebuild preserves the seven weapon illustrations.
"""
from pathlib import Path

DEFS = '''<defs>
<linearGradient id="steel" x1="0" y1="0" x2="0.7" y2="1" gradientUnits="objectBoundingBox"><stop stop-color="#e7eee5"/><stop offset=".45" stop-color="#9fbbb3"/><stop offset="1" stop-color="#516e68"/></linearGradient>
<linearGradient id="wood" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#e4b57a"/><stop offset=".45" stop-color="#b78050"/><stop offset="1" stop-color="#78503b"/></linearGradient>
<linearGradient id="olive" x1="0" y1="0" x2="0" y2="1"><stop stop-color="#a2ae8c"/><stop offset="1" stop-color="#536956"/></linearGradient>
<linearGradient id="blade" x1="0" y1="0" x2="1" y2="0"><stop stop-color="#7e9d99"/><stop offset=".47" stop-color="#bdd3cc"/><stop offset=".5" stop-color="#f3f3da"/><stop offset="1" stop-color="#a0bbb4"/></linearGradient>
</defs>'''

WEAPON_ART = {
    'basic_rifle': '''<g transform="rotate(-30 48 48)" stroke-width="1.8">
<path d="M7 47 25 40 35 41 38 51 22 53 14 65 7 64Z" fill="url(#wood)"/>
<path d="M7 48V63M12 49 25 45" fill="none" stroke="#f1cf98" stroke-width="1.4"/>
<path d="M33 45 35 41H58L62 45V54H34Z" fill="url(#steel)"/>
<path d="M39 54 36 64 42 67 47 55" fill="#785742"/>
<path d="M45 54V61H51L54 54" fill="none" stroke="#d3ddc8" stroke-width="2.2"/>
<path d="M54 53 52 66 62 68 65 54Z" fill="#577268"/>
<path d="M56 58 61 59M55 62 60 63" stroke="#91a999" stroke-width="1.3"/>
<path d="M60 44H85V49H60Z" fill="url(#steel)"/>
<path d="M61 42H75V51H61Z" fill="url(#wood)"/>
<path d="M65 44V49M69 44V49M73 44V49" stroke="#6e4d36" stroke-width="1.3"/>
<path d="M84 42H90V51H84Z" fill="#5a746d"/>
<path d="M36 40H59V43H36Z" fill="#384f49"/>
<path d="M38 40V36H42V40M79 44V38H82V44" fill="#b9c8b6"/>
<path d="M38 47H56M36 51H44" stroke="#e9e9ce" stroke-width="1.4"/>
<circle cx="55" cy="48" r="1.6" fill="#d9b979"/>
</g>''',
    'marksman_rifle': '''<g transform="rotate(-30 48 48)" stroke-width="1.8">
<path d="M6 47 24 40H39L43 48 35 53 24 52 15 64H6Z" fill="url(#wood)"/>
<path d="M7 47V63M12 48 25 44H35" fill="none" stroke="#f0cd92" stroke-width="1.4"/>
<path d="M36 43H64V52H36Z" fill="url(#steel)"/>
<path d="M39 52 36 63 43 66 47 53" fill="#5c5945"/>
<path d="M47 53V60H53L56 53" fill="none" stroke="#d2dcc5" stroke-width="2"/>
<path d="M58 52V60H65V52" fill="#425e53"/>
<path d="M60 44H88V48H60Z" fill="url(#steel)"/>
<path d="M61 43H73V52H61Z" fill="#9b784c"/>
<path d="M86 42H91V50H86Z" fill="#567268"/>
<path d="M44 38V43M57 38V43" stroke="#bfcdb9" stroke-width="3"/>
<path d="M37 31H64V38H37Z" fill="#3d5751"/>
<path d="M35 29H42V40H35ZM61 28H69V41H61Z" fill="url(#steel)"/>
<path d="M69 30H72V39H69Z" fill="#a4cbba"/>
<path d="M44 31V27H51V31" fill="#9aaf9c"/>
<path d="M43 33H59M39 46H59" stroke="#d4dfcb" stroke-width="1.3"/>
<path d="M56 45 58 40 62 40" fill="none" stroke="#e4bf7d" stroke-width="2"/>
</g>''',
    'pistol': '''<g transform="rotate(-24 48 48)" stroke-width="2">
<path d="M15 28H76L82 33V45H43L39 50 32 76H16L23 47H15Z" fill="#526c62"/>
<path d="M14 27H76L82 32V40H14Z" fill="url(#steel)"/>
<path d="M18 29H72" stroke="#eef0d5" stroke-width="1.6"/>
<path d="M16 28V23H22V28M68 27V23H73V27" fill="#aabbaa"/>
<path d="M77 32H83V40H77Z" fill="#293e38"/>
<path d="M42 45H59V51Q56 59 47 59H37" fill="none" stroke="#b8c8b4" stroke-width="3"/>
<path d="M46 46 44 53H48" fill="none" stroke="#e2bd7e"/>
<path d="M25 48H39L32 73H19Z" fill="url(#wood)"/>
<path d="M25 54H34M23 60H32M22 66H30" stroke="#76533e" stroke-width="1.5"/>
<circle cx="31" cy="52" r="1.6" fill="#e5c58f"/>
<path d="M16 73H33V78H16Z" fill="#a6b9a8"/>
<path d="M21 32V37M25 32V37M29 32V37" stroke="#516f68" stroke-width="1.5"/>
</g>''',
    'smg': '''<g transform="rotate(-27 48 48)" stroke-width="1.8">
<path d="M7 43H27V50H14V61H7Z" fill="#526d60"/>
<path d="M11 45H26M11 49V56" fill="none" stroke="#b9c8ae" stroke-width="1.5"/>
<path d="M26 39H66L73 44V54H28Z" fill="url(#olive)"/>
<path d="M29 39V35H62V39" fill="#344e44"/>
<path d="M35 35V30H42V35" fill="#9aaf95"/>
<path d="M68 43H85V49H68Z" fill="url(#steel)"/>
<path d="M83 40H90V52H83Z" fill="#526d63"/>
<path d="M30 54 27 66H36L40 54" fill="#8c7650"/>
<path d="M40 54V61H47V54" fill="none" stroke="#cbd7bd" stroke-width="2"/>
<path d="M48 54 46 76 58 78 61 54Z" fill="url(#steel)"/>
<path d="M50 58 49 72M55 58 54 73" stroke="#405b53" stroke-width="1.5"/>
<path d="M60 42H72V53H60Z" fill="#576f54"/>
<path d="M63 44V50M67 44V50" stroke="#abb78f" stroke-width="1.4"/>
<path d="M31 43H55" stroke="#d9dfbf" stroke-width="1.5"/>
<path d="M43 47H54" stroke="#344d43" stroke-width="2.5"/>
</g>''',
    'knife': '''<g transform="rotate(39 48 48)" stroke-width="1.9">
<path d="M40 58V24L50 9 59 30 57 57Z" fill="url(#blade)"/>
<path d="M50 12 48 53 56 56" fill="none" stroke="#f2f1d8" stroke-width="1.3"/>
<path d="M42 36H46M42 42H46M42 48H46" stroke="#557a70" stroke-width="1.6"/>
<path d="M35 57H61V63H35Z" fill="#b4bba0"/>
<path d="M41 63H56L55 84 50 89H43L39 84Z" fill="url(#olive)"/>
<path d="M41 68H55M41 74H55M41 80H54" stroke="#344e3e" stroke-width="2"/>
<path d="M44 65V82" stroke="#d5d7ac" stroke-width="1.3"/>
<path d="M41 84H55V89H42Z" fill="#aabca8"/>
<circle cx="49" cy="86" r="1.4" fill="#354d42"/>
</g>''',
    'sword': '''<g transform="rotate(39 48 48)" stroke-width="1.8">
<path d="M48 5 56 17 54 65H42L40 17Z" fill="url(#blade)"/>
<path d="M48 8V62" stroke="#f7f4da" stroke-width="1.4"/>
<path d="M43 19 45 59" stroke="#74968e" stroke-width="1.4"/>
<path d="M31 64 38 62 48 66 58 62 65 64 63 70 57 68H39L33 70Z" fill="#d1b67a"/>
<path d="M42 69H54L53 85H43Z" fill="#705541"/>
<path d="M43 72 53 74M43 77 53 79M43 82 53 84" stroke="#bea478" stroke-width="2"/>
<path d="M42 85H54L55 90 48 94 41 90Z" fill="#c3b680"/>
<path d="M44 88H51" stroke="#f1dfaa" stroke-width="1.4"/>
</g>''',
    'wooden_bat': '''<g transform="rotate(39 48 48)" stroke-width="1.8">
<path d="M39 8Q48 3 57 8L59 16 56 42Q54 51 52 59L52 85H44V59Q42 51 40 42L37 16Z" fill="url(#wood)"/>
<path d="M42 11 43 38Q44 46 46 51" fill="none" stroke="#efc68a" stroke-width="2"/>
<path d="M51 13 50 35M47 19 48 40" stroke="#92613e" stroke-width="1.2"/>
<path d="M38 19 57 24M38 29 57 34M40 39 55 43" stroke="#41594f" stroke-width="4"/>
<path d="M38 18 57 23M38 28 57 33M40 38 55 42" stroke="#c5d0b8" stroke-width="1.8"/>
<path d="M37 21 32 17 34 24M56 29 63 25 61 33M39 37 34 33 34 40" fill="none" stroke="#cbd6be" stroke-width="2"/>
<path d="M44 60H52V84H44Z" fill="#a7b39b"/>
<path d="M44 64 52 67M44 70 52 73M44 76 52 79" stroke="#4d6558" stroke-width="2.5"/>
<path d="M41 85H55V90Q48 94 41 90Z" fill="#5c7766"/>
<path d="M43 87H52" stroke="#becab1" stroke-width="1.4"/>
</g>''',
}


def weapon_svg(body):
    return ('<svg xmlns="http://www.w3.org/2000/svg" width="96" height="96" '
            'viewBox="0 0 96 96">' + DEFS +
            '<g stroke="#21372e" stroke-linejoin="round" stroke-linecap="round">' +
            body + '</g></svg>\n')


def write_weapon_icons(root):
    folder = Path(root) / 'assets/ui/items'
    for name, body in WEAPON_ART.items():
        (folder / (name + '.svg')).write_text(weapon_svg(body), encoding='utf-8')


if __name__ == '__main__':
    write_weapon_icons(Path(__file__).resolve().parents[1])
    print('Drew 7 transparent weapon illustrations.')
