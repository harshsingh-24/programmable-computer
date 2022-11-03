%{
    #include<stdio.h>
    #include<cstring> 
    #include "stringwrapper.hpp"
    #include "parse.tab.h" 
    #define ERROR -1
%}

%option yylineno

digit [0-9]
letter [a-zA-Z]

%%
:= return ASSIGN;
,  return COMMA;
: return COLON;
def return DEF;
else return ELSE;
end return END;
\=\= return EQ;
>= return GE;
global return GLOBAL;
> return GT;
if return IF;
int return INT;
\( return LEFT_PAREN;
\<\= return LE;
\< return LT;
- return MINUS;
\<\> return NE;
\+ return PLUS;
\) return RIGHT_PAREN;
; return SEMICOLON;

{digit}{digit}*(E[+-]?{digit}{digit}*)? { 
    int temp = atoi(yytext);
    yylval.value = temp;
    return INT_CONST;
}

{letter}({letter}|{digit})*  {
    char* temp = strdup(yytext);
    yylval.identifier = temp;
    return ID;
}

\/\/.*\n {}
[ \t\n] {}
. return ERROR;


%%
int yywrap(void) {return 1;}