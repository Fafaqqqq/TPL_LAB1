%option noyywrap nounput noinput

%{
#include <stdio.h>
#include <stdbool.h>
#include <assert.h>

typedef struct
{
  int line; // Строка
  int column; // Столбец
} Position_t;

extern FILE* result;
static Position_t Position = {1, 1}; //Текущая позиция в файле
static bool GotError = false;// и

// Функция сдвига на num строк
static void incrLine(int num) {Position.line += num;}
// Функция возвращает номер текущей строки в читаемом файле
static int line(void) {return Position.line;}
// Функция сдвига на num столбцов
static void incrColumn(int num) {Position.column += num;}
// Функция возвращает номер текущего столбца в читаемом файле
static int column(void) {return Position.column;}
// Функция сброса номера текущего столбца в читаемом файле в начало
// строки
static void dropColumn(void) {Position.column = 1;}

#define YY_USER_ACTION { incrColumn(yyleng); }

static void printLexeme(const char * tokName)
{
  fprintf(result,"%s, \"%s\", %d, %d\n", tokName, yytext, line(), column() - yyleng);
}

%}

%x COMMENT_LINE COMMENT_BLOCK

digit [0-9]
letter [a-zA-Z]
delim [();,]
space [ \t]

block [{}]

octa [0-7]
hex [0-9a-f]
binary [01]

identifier ("_"|{letter})("_"|{letter}|{digit})*
int_const [-+]?("0"?("x"{hex}+|"b"{binary}+|{octa}+)|{digit}+)[uUlL]?[uUlL]?
arithm_oper ([+/&|]|"*"|"%"|"-"|"<<"|">>")


%%
"/*"                { BEGIN(COMMENT_BLOCK); }
<COMMENT_BLOCK>.    { }
<COMMENT_BLOCK>"*/" { BEGIN(INITIAL); }

"//"                { BEGIN(COMMENT_LINE); }
<COMMENT_LINE>\n    { BEGIN(INITIAL); }
<COMMENT_LINE>.     { }

("auto"|"double"|"if"|"int"|"goto"|"switch"|"struct"|"const"|"float"|"short"|"unsigned"|"break"|"long"|"continue"|"for"|"signed"|"void"|"case"|"enum"|"register"|"typedef"|"default"|"sizeof"|"char"|"volatile"|"extern"|"return"|"union"|"do"|"static"|"while") { printLexeme("KEYWORD");}

("<"|">"|"<="|">="|"!="|"=="|"&&"|"||") { printLexeme("COMPARE OPERATOR"); }

{arithm_oper} {printLexeme("ARITHMETIC OPERATOR");}

{arithm_oper}= { printLexeme("ARITHMETIC ASSIGN OPERATOR"); }

= { printLexeme("ASSIGN OPERATOR"); }

{identifier} { printLexeme("IDENTIFIER"); }

{int_const} {printLexeme("INT CONST");}

[-+]?({digit}*\.{digit}+|{digit}+\.)([eE][-+]?{digit}+)?[fF]? {printLexeme("FLOAT CONST");}

(\".*\")|(\'.*\')  { printLexeme("STRING LITERAL"); }

("_"|{letter})("_"|{letter}|{digit})+"["({identifier}|{int_const})"]" { printLexeme("INDEXING VARIABLE"); }

{block} { printLexeme("BLOCK OPERATOR"); }

{space}+ {}

("_"|{letter}|{digit})+":" { printLexeme("LABLE"); }

{delim} { printLexeme("DELIMITER");}

\r?\n/(.|\n) { dropColumn(); incrLine(1);}

[^a-zA-Z_0-9+\-*/><!;,=(){}\[\]&|'" \n\t] { printLexeme("ERROR"); GotError = true;}

. { printLexeme("UNKNOWN"); }

\r?\n  { return GotError;}
%%