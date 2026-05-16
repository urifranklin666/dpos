# DESIGN.md — dpos visual language

This document names the aesthetic and the grammar. Read it before
touching the wallpaper, polybar, fastfetch, lockscreen, MOTD, or
anything that ends up on a screen for more than a half-second.

## The stance

**Operator-Cult Industrial.**

Same family as the homepage's `/codex`, `/rites`, `/confessional`,
`/cemetery`, `/bbs` surfaces. Not the playful BBS energy, not the
broadcast-studio energy. Dry. Ritualistic. Terminal-as-altar. The
machine is in service of an ongoing observance, and you are the
operator on duty.

It is not a "Linux rice." A rice is decoration. This is a working
priesthood.

## Differentiation anchor

> If you screenshotted the desktop with all branding removed, what
> would still tell someone it's a dpos box?

**The daily rite, surfacing every time the user opens a shell** —
rendered in fastfetch with the rest of the system info, in serif
italic against the figlet mono logo. The wall of ambient log-line
text on the wallpaper is the secondary anchor. Polybar's `// LABEL`
grammar is tertiary.

(Earlier iteration tried a giant serif load number in conky, but conky
on a tiling WM means competing for a tile slot you've already promised
to i3. The rite moved to fastfetch.)

## Tokens

These mirror the homepage CSS variables. **Do not invent new ones.**

| Token       | Hex       | Role                                       |
|-------------|-----------|--------------------------------------------|
| red         | `#cc0000` | primary structural red                     |
| red-bright  | `#ff2222` | accents, hover, focus, glow                |
| red-dim     | `#880000` | secondary, muted                           |
| red-deep    | `#3a0000` | deep accent, selection bg                  |
| bg          | `#060606` | page bg                                    |
| surface     | `#0a0a0a` | panels                                     |
| surface-2   | `#101010` | nested panels                              |
| border      | `#1c0000` |                                            |
| border-mid  | `#2b0000` |                                            |
| border-hi   | `#4a0000` |                                            |
| text        | `#dedede` |                                            |
| text-mid    | `#9a9a9a` |                                            |
| text-dim    | `#606060` |                                            |
| text-bright | `#ffffff` |                                            |
| amber       | `#ffb000` | reserved for "operator attention" warnings |
| good        | `#22cc44` | reserved for status pills (sparingly)      |

## Grammar

### Eyebrows

Every primary label is prefixed with `// ` and rendered in **mono caps
or mono lower-tracked**. Examples:

```
// LOAD
// CPU 42
// MEM 47
// AUTHENTICATE
// the daemons are in their places. you may begin.
```

This is the single most visible brand signal. Do not replace `//` with
`>` or `▸` or `★` for any reason.

### Type pairings

- **Mono** (Cascadia Code → Fira Code → DejaVu Sans Mono): everything
  structural. Labels. Status. Numbers. The shell prompt.
- **Serif italic** (DejaVu Serif italic, Georgia italic as fallback):
  reserved for the **rite** and any other passage that should read like
  it's being intoned. Never used for chrome.
- **Serif regular/bold** (DejaVu Serif, Georgia as fallback): reserved
  for body-length passages that deserve a "document" register —
  Codex-style reading rather than UI chrome.

### Composition

- Asymmetry is preferred over symmetry. The wallpaper sigil is in the
  top-right; the wordmark is in the bottom-left; the central log
  column is offset, not dead-center.
- **One element should dominate per surface.** On the wallpaper it's
  the column of ambient text. In fastfetch it's the figlet wordmark
  plus the rite. On the lockscreen it's `// AUTHENTICATE`.
- Negative space is structural. Polybar has 2px of border-bottom and
  no other framing. The wallpaper's corner brackets imply a frame
  without enclosing one.

### Motion

- Boot splash: heartbeat pulse on the sigil, drifting embers, ~6s
  chromatic-split glitch on the wordmark. (Plymouth script handles
  this.)
- Desktop: no motion by default. Polybar refreshes module values on
  short intervals (CPU/MEM 2-3s, // ON AIR 5s). Picom does fades,
  not blurs.
- Lockscreen: i3lock-color renders the password ring in red. No bounce.

If you find yourself adding "a little extra animation to make it pop,"
stop. The stance is restraint.

### The corner brackets

The chamfered corner brackets are **the structural signature**. They
appear on:

- the wallpaper (all four corners)
- the homepage panels (clip-path version)
- the Plymouth splash (during boot)
- (future) the lockscreen, alacritty padding mode, dunst frames

They are 64-80px legs, 2px stroke, brand red, ~55% opacity. They
imply a viewport without drawing a box.

## The polished surfaces

| Surface        | What dominates                                      |
|----------------|-----------------------------------------------------|
| Wallpaper      | Column of ambient operator log-lines, fading top/bot |
| Polybar        | `// LABEL VALUE` everywhere, underline on active   |
| Plymouth splash | Pulsing sigil + chromatic-split glitch on the wordmark |
| Shell banner   | dpos-banner on every interactive shell — figlet wordmark + rite |
| Zsh prompt     | `╭─ user@host ~/path  git:branch !`  /  `╰─▌` with RPROMPT time |
| `dpos` launcher | fzf menu with `// invoke ▌` prompt, brand colors, ▌ pointer |
| `dpos status`  | live TUI dashboard — host facts, bars, remote dots, today's rite |
| Vim            | Custom dpos.vim colorscheme — comments italic dim, keywords bold red |
| tmux           | `// dpos · session` left, `host · HH:MM · YYYY-MM-DD` right |
| btop           | dpos.theme — all gradients red-only, no green→amber→red |
| Lockscreen     | Blurred wallpaper + centered `// AUTHENTICATE`     |
| First boot     | One-time greeter terminal with fastfetch + single dry line |

(Conky was removed — it doesn't belong on a tiling WM.)

## The `dpos` command hub

A single command that opens a fzf launcher to every operator-tool we
ship. Run bare for the menu; `dpos <subcommand>` dispatches directly;
`dpos help` prints the full manual.

| Subcommand | What it does |
|------------|--------------|
| `status`   | Live TUI dashboard (host + remote heartbeat) |
| `ssh`      | fzf launcher over `~/.ssh/config` |
| `services` | fzf launcher over the deadplug.digital app catalogue |
| `sigil <text>` | Procedural ASCII sigil — echoes `/oracle` |
| `confess [sin]` | The confessional — echoes `/confessional` |
| `numbers [count]` | Number-station broadcast — echoes `/numbers` |
| `boot`     | Theatrical boot sequence (decryption animation) |
| `rite`     | Today's rite from the corpus |
| `onair`    | Check broadcast state via owncast |
| `lock`     | Lock screen |
| `colors`   | Show the dpos palette |
| `banner`   | Re-show the shell-open banner |
| `home`     | Open `deadplug.digital` |
| `ops`      | Open `/ops` console |
| `help`     | Manual page |

The launcher menu uses the brand fzf colors. Adding a new subcommand
means dropping a `dpos-<name>` script into `~/.local/bin/` and listing
it in `dpos`'s registry.

## Anti-patterns

- **No icon glyphs** in polybar labels. We use the `//` eyebrow instead.
- **No rainbow.** No lolcat. No multi-hue gradients. The palette is
  black, red, and one neutral.
- **No system fonts** (Inter, Roboto, system-ui). Mono fonts only,
  plus DejaVu Serif italic for the rite.
- **No symmetrical "centered logo" wallpapers.** The sigil is a
  watermark, not a focal point.
- **No telemetry references in copy.** Marketing-speak ban. Brand
  voice is dry and a little hostile to the discourse.

## When to break the rules

Almost never. If you must:

1. State the intended exception in your commit message.
2. Confine it to a single surface.
3. Make sure the differentiation anchor (the rite) is still visible
   somewhere on the screen — otherwise it's no longer dpos.
