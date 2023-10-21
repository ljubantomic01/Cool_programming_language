/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%option noyywrap 
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

  /* varijabla za duljinu stringa i za brojenje ugniježdenih komentara */
int str_len = 0;
int comment_counter = 0;

 /* prototipi funkcija (definicije na dnu) */
void reset_string();
void add_to_buffer(char*);
bool str_too_long();

/*
 *  Add Your own definitions here 
 */
%}

/*
 * Define names for regular expressions here.
 */

DARROW          =>
ASSIGN          <-  
LE              <=
DIGIT           [0-9]
CHAR            [A-Za-z0-9_]
CAPITAL_LETTER  [A-Z]
LWR_CASE_LETTER [a-z]
TYPEID          {CAPITAL_LETTER}{CHAR}* 
OBJECTID        {LWR_CASE_LETTER}{CHAR}* 
COMMENT_START   \(\*
COMMENT_STOP    \*\)
DASH_COMMENT    --
WHITE_SPACE     [ \n\f\r\t\v]
SPACE           [ ]
STR_START_STOP   \"


%x STRING
%x COMMENT
%x COMMENT_2
%x ERROR_HANDLE

%%

\n                                               curr_lineno++;
{WHITE_SPACE}                                    {}

 /*   Ups! Izgleda da . na dnu initial stanja kupi sve ove znakove, ali neka ovo stoji, da nije džaba pisano xD; 
"!"                                              { cool_yylval.error_msg = "!";  return (ERROR); }
"#"                                              { cool_yylval.error_msg = "#";  return (ERROR); }
"$"                                              { cool_yylval.error_msg = "$";  return (ERROR); }
"%"                                              { cool_yylval.error_msg = "%";  return (ERROR); }
"^"                                              { cool_yylval.error_msg = "^";  return (ERROR); }
"&"                                              { cool_yylval.error_msg = "&";  return (ERROR); }
"_"                                              { cool_yylval.error_msg = "_";  return (ERROR); }
">"                                              { cool_yylval.error_msg = ">";  return (ERROR); }
"?"                                              { cool_yylval.error_msg = "?";  return (ERROR); }
"`"                                              { cool_yylval.error_msg = "`";  return (ERROR); }
"["                                              { cool_yylval.error_msg = "[";  return (ERROR); }
"]"                                              { cool_yylval.error_msg = "]";  return (ERROR); }
"\\"                                             { cool_yylval.error_msg = "\\"; return (ERROR); }
"|"                                              { cool_yylval.error_msg = "|";  return (ERROR); }

                                               { cool_yylval.error_msg = "\001";  return (ERROR); }
                                               { cool_yylval.error_msg = "\002";  return (ERROR); }
                                               { cool_yylval.error_msg = "\003";  return (ERROR); }    
                                               { cool_yylval.error_msg = "\004";  return (ERROR); }
 */

 /*
  *  Nested comments
  */

 /* ulazak u komentar */

{COMMENT_START}       { 
                        comment_counter ++; 
                        BEGIN COMMENT; 
                      }

 /* stanje komentar */                      

<COMMENT>{

{COMMENT_START}       { comment_counter++; }
{COMMENT_STOP}        { comment_counter --;
                        if(comment_counter == 0)  
                            BEGIN INITIAL;
                      }
\n                    { curr_lineno++; }
.                     { }
<<EOF>>               { 
                        cool_yylval.error_msg = "EOF in comment";
                        BEGIN INITIAL; 
                        return (ERROR);
                      }
}

 /* ako naiđe na ovaj znak za kraj komentara izvan komentara : */

{COMMENT_STOP}       { 
                      cool_yylval.error_msg = "Unmatched *)";
                      return (ERROR);
                     }

 /* ulazak u komentar 2, sa -- */

{DASH_COMMENT}        BEGIN COMMENT_2;

 /* stanje komentar 2 */

<COMMENT_2>{
    
\n                   { 
                      curr_lineno++; 
                      BEGIN INITIAL; 
                     }  
.                    { }
}

 /*
  *  The multiple-character operators.
  */


{DARROW}	  { return (DARROW) ; }
{ASSIGN}    { return (ASSIGN) ; }
{LE}        { return (LE) ; }

"."         {  return '.' ; }
"@"         {  return '@' ; }
"~"         {  return '~' ; }
"*"         {  return '*' ; }
"/"         {  return '/' ; }
"+"         {  return '+' ; }
"-"         {  return '-' ; }
"<"         {  return '<' ; }
","         {  return ',' ; }
";"         {  return ';' ; }
":"         {  return ':' ; }
"("         {  return '(' ; }
")"         {  return ')' ; }
"{"         {  return '{' ; }
"}"         {  return '}' ; }
"="         {  return '=' ; }

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

([Cc][Ll][Aa][Ss][Ss])                          { return  (CLASS) ; } 
([Ee][Ll][Ss][Ee])                              { return  (ELSE) ; }
([Ff][Ii])                                      { return  (FI) ; }
([Ii][Ff])                                      { return  (IF) ; }
([Ii][Nn])                                      { return  (IN) ; }
([Ii][Nn][Hh][Ee][Rr][Ii][Tt][Ss])              { return  (INHERITS) ; }
([Ii][Ss][Vv][Oo][Ii][Dd])                      { return  (ISVOID) ; }
([Ll][Ee][Tt])                                  { return  (LET) ; }
([Ll][Oo][Oo][Pp])                              { return  (LOOP) ; }
([Pp][Oo][Oo][Ll])                              { return  (POOL) ; }
([Tt][Hh][Ee][Nn])                              { return  (THEN) ; }
([Ww][Hh][Ii][Ll][Ee])                          { return  (WHILE) ; }
([Cc][Aa][Ss][Ee])                              { return  (CASE) ; }
([Ee][Ss][Aa][Cc])                              { return  (ESAC) ; }
([Nn][Ee][Ww])                                  { return  (NEW) ; }
([Oo][Ff])                                      { return  (OF) ; }
([Nn][Oo][Tt])                                  { return  (NOT) ; }
(t[Rr][Uu][Ee])                                 { cool_yylval.boolean = 1; return(BOOL_CONST) ; }
(f[Aa][Ll][Ss][Ee])                             { cool_yylval.boolean = 0; return(BOOL_CONST) ; }

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */

{STR_START_STOP}   {
                    BEGIN STRING;   
                    str_len = 0;
                   }  

<STRING>{

{STR_START_STOP} { 
                cool_yylval.symbol = stringtable.add_string(string_buf); 
                reset_string(); 
                BEGIN INITIAL; 
                return (STR_CONST); 
              }

  /* ako naiđe na znak za novi redak, odnosno string nije zatvoren */            

  \n          { 
                cool_yylval.error_msg = "Unterminated string constant";
                reset_string();
                curr_lineno++;
                BEGIN INITIAL;
                return (ERROR);
              }
  
  /* ako naiđe na \ n */

  \\n         { 
                if(str_too_long())   
              {   
                  reset_string(); 
                  cool_yylval.error_msg = "String constant too long"; 
                  BEGIN ERROR_HANDLE;
                  return (ERROR);
              }
                str_len += 2;
                add_to_buffer("\n");
              }
  
  /* ako naiđe na  \ \n */
  
  \\\n        {
                if(str_too_long())   
              { 
                  reset_string(); 
                  cool_yylval.error_msg = "String constant too long"; 
                  BEGIN ERROR_HANDLE;
                  return (ERROR);
              }
                str_len ++;
                curr_lineno++;
                add_to_buffer("\n");
              }
 
  \\b         {
                if(str_too_long())   
              { 
                  reset_string(); 
                  cool_yylval.error_msg = "String constant too long"; 
                  BEGIN ERROR_HANDLE;
                  return (ERROR);
              }
  
                str_len ++;
                add_to_buffer("\b");

              }

  \\t         {
                if(str_too_long())   
              {   
                  reset_string(); 
                  cool_yylval.error_msg = "String constant too long"; 
                  BEGIN ERROR_HANDLE;
                  return (ERROR);
              }
        
                str_len ++;
                add_to_buffer("\t");
              }

  \\f         {
                if(str_too_long())   
              { 
                  reset_string(); 
                  cool_yylval.error_msg = "String constant too long"; 
                  BEGIN ERROR_HANDLE;
                  return (ERROR);
              }
        
                str_len ++;
                add_to_buffer("\f");
              }

  \0          { 
                cool_yylval.error_msg = "String contains null character"; 
                reset_string(); 
                BEGIN ERROR_HANDLE;
                return (ERROR);
              }

   /* za slučaj \c koji se čita kao c : */ 

  \\.         {
                if(str_too_long())   
              { 
                  reset_string(); 
                  cool_yylval.error_msg = "String constant too long"; 
                  BEGIN ERROR_HANDLE;
                  return (ERROR);
              }
                str_len++;
                add_to_buffer(&yytext[1]);
              }

  <<EOF>>     {
                cool_yylval.error_msg = "EOF in string constant"; 
                curr_lineno++;
                BEGIN INITIAL;
                return (ERROR);

              } 
 
 
  .           { 
                if(str_too_long())   
              { 
                  reset_string(); 
                  cool_yylval.error_msg = "String constant too long"; 
                  BEGIN ERROR_HANDLE;
                  return (ERROR);
              }

                str_len++; 
                add_to_buffer(yytext); 
              }
  }

<ERROR_HANDLE>{

\"            BEGIN INITIAL;
\n          { 
              curr_lineno++; 
              BEGIN INITIAL;
            }
.           { }

}

{DIGIT}+                     { 
                              cool_yylval.symbol = inttable.add_string(yytext); 
                              return (INT_CONST); 
                             }

{TYPEID}                     { 
                              cool_yylval.symbol = idtable.add_string(yytext);
                              return (TYPEID);
                             }

{OBJECTID}                   { 
                              cool_yylval.symbol = idtable.add_string(yytext);
                              return (OBJECTID); 
                             } 

.                            { 
                              cool_yylval.error_msg = yytext;
                              return (ERROR); 
                             } 

%%

 /* funkcija koja prazni string buffer */
void reset_string(){
  string_buf[0] = '\0';
}


 /* funkcija koja dodaje znak u string buffer */
void add_to_buffer(char* character){
    strcat(string_buf, character);
}

 /*funkcija koja provjerava je li string predugačak */

bool str_too_long(){
  if(str_len + 1 >= MAX_STR_CONST)
      return true;
      
  return false;
}
