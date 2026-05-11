; ---------------------------------------------------------
; Keywords
; ---------------------------------------------------------
"FUNCTION_BLOCK" @keyword
"END_FUNCTION_BLOCK" @keyword
"FUNCTION" @keyword
"END_FUNCTION" @keyword
"ORGANIZATION_BLOCK" @keyword
"END_ORGANIZATION_BLOCK" @keyword
"DATA_BLOCK" @keyword
"END_DATA_BLOCK" @keyword
"TYPE" @keyword
"END_TYPE" @keyword
"STRUCT" @keyword
"END_STRUCT" @keyword

"VAR" @keyword
"END_VAR" @keyword
"VAR_INPUT" @keyword
"VAR_OUTPUT" @keyword
"VAR_IN_OUT" @keyword
"VAR_TEMP" @keyword
"CONST" @keyword
"END_CONST" @keyword

"BEGIN" @keyword
"IF" @keyword.conditional
"THEN" @keyword.conditional
"ELSIF" @keyword.conditional
"ELSE" @keyword.conditional
"END_IF" @keyword.conditional
"CASE" @keyword.conditional
"OF" @keyword.conditional
"END_CASE" @keyword.conditional

"FOR" @keyword.repeat
"TO" @keyword.repeat
"BY" @keyword.repeat
"DO" @keyword.repeat
"END_FOR" @keyword.repeat
"WHILE" @keyword.repeat
"END_WHILE" @keyword.repeat
"REPEAT" @keyword.repeat
"UNTIL" @keyword.repeat
"END_REPEAT" @keyword.repeat

"CONTINUE" @keyword.exception
"EXIT" @keyword.exception
"RETURN" @keyword.exception
"GOTO" @keyword.exception

; ---------------------------------------------------------
; Types and Variables
; ---------------------------------------------------------
(elementary_type) @type.builtin
(user_type) @type
(string_type) @type.builtin
(array_type) @type
(identifier) @variable
(absolute_address) @variable.builtin

; ---------------------------------------------------------
; Functions
; ---------------------------------------------------------
(call_statement function: (identifier) @function)
(call_expression function: (identifier) @function)
(member_access property: (identifier) @property)

; ---------------------------------------------------------
; Literals
; ---------------------------------------------------------
(number_literal) @number
(bool_literal) @boolean
(string_literal) @string
(time_literal) @string.special

; ---------------------------------------------------------
; Comments
; ---------------------------------------------------------
(line_comment) @comment
(block_comment) @comment

; ---------------------------------------------------------
; Operators & Punctuation
; ---------------------------------------------------------
":=" @operator
"=" @operator
"<" @operator
">" @operator
"<=" @operator
">=" @operator
"<>" @operator
"+" @operator
"-" @operator
"*" @operator
"/" @operator
"**" @operator

";" @punctuation.delimiter
":" @punctuation.delimiter
"," @punctuation.delimiter
"." @punctuation.delimiter
"[" @punctuation.bracket
"]" @punctuation.bracket
"(" @punctuation.bracket
")" @punctuation.bracket
