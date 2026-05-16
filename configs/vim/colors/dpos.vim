" dpos.vim — operator-cult industrial vim colorscheme
" tokens mirror /homepage CSS variables.
" works in true-color terminals (alacritty), degrades to 256-color elsewhere.

set background=dark
hi clear
if exists("syntax_on") | syntax reset | endif
let g:colors_name = "dpos"

" ---- base UI ----
hi Normal       guifg=#dedede guibg=#060606 ctermfg=253 ctermbg=232
hi NonText      guifg=#2b0000 ctermfg=52
hi LineNr       guifg=#606060 guibg=#060606 ctermfg=240 ctermbg=232
hi CursorLine                 guibg=#101010              ctermbg=233 cterm=NONE
hi CursorLineNr guifg=#ff2222 guibg=#101010 ctermfg=196 ctermbg=233 cterm=bold gui=bold
hi CursorColumn               guibg=#101010              ctermbg=233
hi Cursor       guifg=#060606 guibg=#ff2222 ctermfg=232 ctermbg=196
hi ColorColumn                guibg=#101010              ctermbg=233
hi Visual                     guibg=#3a0000              ctermbg=52
hi VisualNOS                  guibg=#3a0000              ctermbg=52
hi SignColumn                 guibg=#060606              ctermbg=232
hi VertSplit    guifg=#2b0000 guibg=#060606 ctermfg=52  ctermbg=232 cterm=NONE
hi StatusLine   guifg=#dedede guibg=#0a0a0a ctermfg=253 ctermbg=233 cterm=NONE gui=NONE
hi StatusLineNC guifg=#606060 guibg=#0a0a0a ctermfg=240 ctermbg=233 cterm=NONE gui=NONE
hi MatchParen   guifg=#ff2222 guibg=NONE    ctermfg=196              cterm=bold gui=bold
hi Folded       guifg=#9a9a9a guibg=#101010 ctermfg=247 ctermbg=233
hi FoldColumn   guifg=#606060 guibg=#060606 ctermfg=240 ctermbg=232
hi WildMenu     guifg=#ffffff guibg=#cc0000 ctermfg=255 ctermbg=160

" ---- syntax — tight palette ----
hi Comment      guifg=#606060               ctermfg=240 cterm=italic gui=italic
hi Constant     guifg=#ff2222               ctermfg=196
hi String       guifg=#dedede               ctermfg=253
hi Number       guifg=#ffb000               ctermfg=214
hi Boolean      guifg=#ff2222               ctermfg=196
hi Float        guifg=#ffb000               ctermfg=214
hi Character    guifg=#ffb000               ctermfg=214
hi Identifier   guifg=#dedede               ctermfg=253 cterm=NONE
hi Function     guifg=#ff2222               ctermfg=196 cterm=bold gui=bold
hi Statement    guifg=#cc0000               ctermfg=160
hi Conditional  guifg=#cc0000               ctermfg=160
hi Repeat       guifg=#cc0000               ctermfg=160
hi Label        guifg=#cc0000               ctermfg=160
hi Operator     guifg=#9a9a9a               ctermfg=247
hi Keyword      guifg=#cc0000               ctermfg=160 cterm=bold gui=bold
hi Exception    guifg=#ff2222               ctermfg=196 cterm=bold gui=bold
hi Type         guifg=#9a9a9a               ctermfg=247
hi StorageClass guifg=#9a9a9a               ctermfg=247
hi Structure    guifg=#9a9a9a               ctermfg=247
hi Typedef      guifg=#9a9a9a               ctermfg=247
hi Special      guifg=#ffb000               ctermfg=214
hi SpecialChar  guifg=#ffb000               ctermfg=214
hi Tag          guifg=#cc0000               ctermfg=160
hi Delimiter    guifg=#9a9a9a               ctermfg=247
hi SpecialComment guifg=#880000             ctermfg=88  cterm=italic gui=italic
hi Debug        guifg=#ff2222               ctermfg=196
hi PreProc      guifg=#880000               ctermfg=88
hi Include      guifg=#880000               ctermfg=88
hi Define       guifg=#880000               ctermfg=88
hi Macro        guifg=#880000               ctermfg=88
hi PreCondit    guifg=#880000               ctermfg=88
hi Title        guifg=#ff2222               ctermfg=196 cterm=bold gui=bold
hi Underlined                                             cterm=underline gui=underline
hi Ignore       guifg=#606060               ctermfg=240
hi Error        guifg=#ffffff guibg=#cc0000 ctermfg=255 ctermbg=160 cterm=bold gui=bold
hi Todo         guifg=#ffb000 guibg=NONE    ctermfg=214              cterm=bold gui=bold

" ---- diffs ----
hi DiffAdd      guifg=#22cc44 guibg=#001a00 ctermfg=34   ctermbg=22
hi DiffChange                 guibg=#1a1500              ctermbg=234
hi DiffDelete   guifg=#ff2222 guibg=#1a0000 ctermfg=196 ctermbg=52
hi DiffText     guifg=#ffffff guibg=#3a0000 ctermfg=255 ctermbg=52  cterm=bold gui=bold

" ---- search / messages ----
hi Search       guifg=#ffffff guibg=#3a0000 ctermfg=255 ctermbg=52
hi IncSearch    guifg=#ffffff guibg=#cc0000 ctermfg=255 ctermbg=160 cterm=NONE gui=NONE
hi ErrorMsg     guifg=#ff2222               ctermfg=196 cterm=bold gui=bold
hi WarningMsg   guifg=#ffb000               ctermfg=214
hi MoreMsg      guifg=#cc0000               ctermfg=160
hi Question     guifg=#cc0000               ctermfg=160
hi ModeMsg      guifg=#dedede               ctermfg=253

" ---- popup menus / completion ----
hi Pmenu        guifg=#dedede guibg=#101010 ctermfg=253 ctermbg=233
hi PmenuSel     guifg=#ffffff guibg=#3a0000 ctermfg=255 ctermbg=52  cterm=bold gui=bold
hi PmenuSbar                  guibg=#1c0000              ctermbg=52
hi PmenuThumb                 guibg=#cc0000              ctermbg=160

" ---- tabs ----
hi TabLine      guifg=#9a9a9a guibg=#0a0a0a ctermfg=247 ctermbg=233 cterm=NONE gui=NONE
hi TabLineSel   guifg=#ffffff guibg=#3a0000 ctermfg=255 ctermbg=52  cterm=bold gui=bold
hi TabLineFill                guibg=#060606              ctermbg=232 cterm=NONE gui=NONE

" ---- spell / quickfix ----
hi SpellBad     guifg=#ff2222 guisp=#ff2222 ctermfg=196 cterm=underline gui=undercurl
hi SpellCap     guifg=#ffb000 guisp=#ffb000 ctermfg=214 cterm=underline gui=undercurl
hi SpellRare    guifg=#9a9a9a guisp=#9a9a9a ctermfg=247 cterm=underline gui=undercurl
hi SpellLocal   guifg=#9a9a9a guisp=#9a9a9a ctermfg=247 cterm=underline gui=undercurl

hi Directory    guifg=#ff2222               ctermfg=196 cterm=bold gui=bold

" ---- terminal colors (true-color) ----
let g:terminal_ansi_colors = [
  \ '#0a0a0a', '#cc0000', '#22cc44', '#ffb000',
  \ '#5e7eff', '#ff2266', '#22ccaa', '#dedede',
  \ '#2b0000', '#ff2222', '#3ddb59', '#ffcb44',
  \ '#88a6ff', '#ff5588', '#55e6c8', '#ffffff'
\ ]
