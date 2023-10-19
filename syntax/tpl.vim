" tpl.vim - Vim syntax file for tpl grammar

if exists("b:current_syntax")
    finish
endif

" Comments
syn region	tplBlockComment	start="/\*"  end="\*/"
syn match	tplLineComment	"//.*$"

" Constants
syn keyword tplBool         true false
syn keyword tplNull         null
syn match   tplInteger      "\<[0-9]\+\>"
syn match   tplReal         "\<[0-9]\+[eE][\+|-]\?[0-9]\+\>"
syn match   tplReal         "\<[0-9]\+\.[0-9]*\((\+|-)\?[0-9]\+\)\?\>"
syn match   tplReal         "\<[0-9]*\.[0-9]\+\((\+|-)\?[0-9]\+\)\?\>"
syn match   tplEscape       contained "\\."
syn region  tplInterpol     contained start=+${+ end=+}+
syn region  tplString       start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=tplEscape,tplInterpolation
syn region  tplString       start=+'+ skip=+\\\\\|\\'+ end=+'+ contains=tplEscape,tplInterpolation

syn match   tplIdentifier   "\<[a-zA-Z_][a-zA-Z_0-9]*\>"
syn keyword tplFunction     template function

syn keyword tplConditional  if else
syn keyword tplRepeat       for
syn keyword tplOperator     and or not
syn match   tplOperator     "\(!\|==\|!=\|<\|>\|<=\|>=\|=\~\|!\~\|+\|-\|*\|/\|%\|&&\|||\|=\|+=\|-=\|*=\|/=\|%=\|\.\)"
syn keyword tplStatement    return assert delete
syn keyword tplKeyword      where new import

syn keyword tplType         void bool int real string
syn keyword tplStructure    class enum

hi def link tplBlockComment Comment
hi def link tplBool         Boolean
hi def link tplNull         Constant
hi def link tplInteger      Number
hi def link tplReal         Float
hi def link tplString       String

hi def link tplIdentifier   Identifier
hi def link tplFunction     Keyword

hi def link tplConditional  Conditional
hi def link tplRepeat       Repeat
hi def link tplOperator     Operator
hi def link tplStatement    Statement
hi def link tplKeyword      Keyword

hi def link tplType         Type
hi def link tplStructure    Structure

hi def link tplInterpol     Special
hi def link tplEscape       Special

let b:current_syntax = "tpl"

