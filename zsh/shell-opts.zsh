autoload -U select-word-style
select-word-style bash # Consider select-word-style with e.g. WORDCHARS=${WORDCHARS//[\/]}
bindkey $terminfo[kLFT5] backward-word
bindkey $terminfo[kRIT5] forward-word
