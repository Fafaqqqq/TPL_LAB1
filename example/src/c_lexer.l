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
  printf("%s, \"%s\", %d, %d\n", tokName, yytext, line(), column() - yyleng);
}

%}

%x COMMENT

digit[0-9]
letter[a-zA-Z]
delim[();]
oper[<>=]
space[ \t]

octa[0-7]
hex[0-9a-f]
binary[01]

%%
"/*" { BEGIN(COMMENT); }

<COMMENT>.    { }
<COMMENT>"*/" { BEGIN(INITIAL); }

for { printLexeme("KEYWORD");}
do { printLexeme("KEYWORD");}

("_"|{letter})("_"|{letter}|{digit})* {printLexeme("IDENTIFIER");}

[-+]?("0")("x"{hex}+|"b"{binary}+|{octa}+)[uUlL]* {printLexeme("INT CONST");}

[-+]?({digit}*\.{digit}+|{digit}+\.)([eE][-+]?{digit}+)?[fF]? {printLexeme("FLOAT CONST");}

(\"|\')({letter}*|{digit}*)(\"\') { printLexeme("STRING LITERAL"); }

("_"|{letter})("_"|{letter}|{digit})+"["({digit}+|{letter}+)"]" { printLexeme("INDEXING VARIABLE"); }

{oper} { printLexeme("OPERATION");}

":=" { printLexeme("OPERATION");}

{delim} { printLexeme("DELIMITER");}

{space}+ { }

\r?\n/(.|\n) { dropColumn(); incrLine(1);}

[^a-zA-Z_0-9+\-*/><!;,=(){}\[\]&|'" \n\t] { printLexeme("ERROR"); GotError = true;}

. { printLexeme("UNKNOWN"); }

\r?\n  { return GotError;}
%%