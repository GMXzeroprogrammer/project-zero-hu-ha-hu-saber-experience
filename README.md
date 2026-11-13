# Mega Man X3: Project Zero - Hu Ha Hu! Edition (Saber Experience)

**English** | [Português (Brasil)](README.pt-BR.md)  
**Version:** v1.7b • **Platform:** Super Nintendo (SNES) • **Base mod:** Zero Project v4.8 by Justin3009

> An unofficial fan-made add-on for **Mega Man X3**, centered on Zero's saber combat. Play with a three-hit ground combo, separate Z-Buster controls, in-stage X/Zero switching, enhanced bosses, and an unlockable Boss Rush.
>
> **No game ROM is provided.** This repository contains IPS patches, source files, and documentation. You must supply your own legally obtained, compatible game dump.

## What's included

- **Zero's Z-Saber on Y:** A standing three-hit ground combo inspired by *Mega Man X4-X6*, plus an aerial slash. Press **Down + Y** in the air for a spinning saber attack.
- **Zero's Z-Buster on X:** Fire and charge up to the pink charge level. The older green-charge saber finisher has been removed.
- **Character switch on Select:** Swap between X and Zero during supported stages, following the base Zero Project's restrictions. Their health is tracked separately. When normal damage depletes one character's health, the partner may take over if available. Pits, spikes and crushing remain instant deaths.
- **X remains familiar:** Y still fires and charges his X-Buster.
- **Boss health extension:** A purple extra health bar adds 50% in normal play and 100% after a completed playthrough.
- **Boss Rush:** An option on the title menu once at least one save file has cleared the game. Start fully equipped, face bosses in randomized order, regain some health after each victory, and return without altering save files. Current roster: the eight Mavericks and two Doppler fortress bosses; other bosses are not yet included.

## Controls

| Character | Input | Action |
|---|---|---|
| Zero | `Y` | Z-Saber; press again to chain the three-hit ground combo |
| Zero | `Y` while airborne | Aerial slash |
| Zero | `Down + Y` while airborne | Spinning saber |
| Zero | `X` | Z-Buster, charge up to pink; sub-weapons |
| X | `Y` | X-Buster (unchanged) |
| X / Zero | `Select` | Switch character, where the base mod allows it |

## Installation

Use [Floating IPS (Flips)](https://www.romhacking.net/utilities/1040/) or another compatible IPS patcher. Choose **one** file from `patches/`:

| Patch file | Apply to |
|---|---|
| `MMX3_ZeroCombo_v1.7b_rom_original.ips` | A clean, **unheadered** **Mega Man X3 (USA)** ROM. This patch already includes Zero Project v4.8 changes. |
| `MMX3_ZeroCombo_v1.7b_sobre_ZP48.ips` | A compatible ROM that already has **Zero Project v4.8** applied. |

**Important:** Do not apply one patch over the other or stack v1.7b on a previous version of this add-on. Make a backup first. Compatibility with other ROM regions, headered ROMs, or additional hacks is not guaranteed.

## Build from source

The assembly source is included for study and further development. Build requirements:

- [Asar](https://github.com/RPGHacker/asar) (1.8x)
- A compatible ROM already patched with Zero Project v4.8

```bash
cp "Mega Man X3 ZP48.sfc" "build.sfc"
asar --fix-checksum=on src/mmx3_zero_combo.asm build.sfc
```

The entry point is `src/mmx3_zero_combo.asm`; additional components live in `src/zc_data.asm`, `src/zc_bar.asm`, and `src/zc_rush.asm`.

`tools/sprites/` contains the Python sprite conversion scripts. The original sprite sheet is **not redistributed**. To run the converters, supply an appropriate sprite sheet as `tools/sprites/spritesheet.png`, or set the `MMX3_SPRITESHEET` environment variable. Install dependencies from `requirements.txt`. The supplied `src/zc_data.asm` is already generated, so rebuilding the existing assembly does not require the original sheet. Some auxiliary scripts may require additional project-specific inputs.

## Version history

See [CHANGELOG.md](CHANGELOG.md) in English or [CHANGELOG.pt-BR.md](CHANGELOG.pt-BR.md) in Brazilian Portuguese.

## Credits and acknowledgements

- **Mega Man X3:** © Capcom. All relevant original rights remain with their owners.
- **Zero Project v4.8:** **Justin3009** (also known as xJustin3009x / Shishisenkou). This add-on builds on that original mod.
- **X4-style Zero saber-combo sprites:** **[kensuyjin33](https://www.deviantart.com/kensuyjin33/gallery)**, as credited in the original project package.
- **Concept, design direction, and testing:** **GmasterX / GMXzeroprogrammer**.
- **Programming support:** **Claude (Anthropic)**, as noted by the original project.

This is a noncommercial, unofficial fan modification. It is not affiliated with or endorsed by Capcom, Justin3009, or the sprite artist. Attribution does not imply licensing or endorsement. Please respect the original authors' rights when redistributing or building on their work.
