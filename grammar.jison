/* LEXER */

%lex

%%

\s+					/* Ignore*/ 
"$".*				/* Ignore*/

"&Prnt"				return 'TPRINT';
"&Dcl"				return 'TDECLARE';
"&Whle"			    return 'TWHILE';
"&If"				return 'TIF';
"&Do"				return 'TDO';
"&Else"			    return 'TELSE';
"&For"				return 'TFOR';
"&True"			    return 'TTRUE';
"&False"			return 'TFALSE';
"&Fnctn"            return 'TFUNCT';

","                 return ',';
":"					return ':';
";"					return ';';
"{"					return '{';
"}"					return '}';
"("					return '(';
")"					return ')';
"["                 return '[';
"]"                 return ']';

"+=>"				return 'PEQ';
"-=>"				return 'MEQ';
"*=>"				return 'MUEQ';
"/=>"				return 'DIEQ';
"&&"				return '&&'
"||"				return '||';

"+"					return '+';
"-"					return '-';
"*"					return '*';
"/"					return '/';
"&"					return 'CONCAT';

"<=="				return 'LESSEQ';
">=="				return 'GRTREQ';
"==="				return 'EQUAL';
"!=="				return 'DIFF';

"<"					return 'LESS';
">"					return 'GRTR';
"=>"				return 'TASSIGN';

"!"					return 'TNOT';

\`[^\"]*\`				{ yytext = yytext.substr(1,yyleng-2); return 'STRING'; }
[0-9]+("."[0-9]+)?\b  	return 'DECIMAL';
[0-9]+\b				return 'INTEGER';
([a-zA-Z])[a-zA-Z0-9_]*	return 'ID';


<<EOF>>				return 'EOF';
.					{ throw 'Este es un error léxico: ' + yytext + ', en la linea: ' + yylloc.first_line + ', en la columna: ' + yylloc.first_column; }

/lex


 %{
 var funciones = require('./data').funciones;
 %}

/* Asociación de operadores y precedencia */
%left 'CONCAT'
%left '+' '-'
%left '*' '/'
%left UMENOS

%start program


%% /* Definición de la gramática */


program
	: Instructions EOF { return $1; }
;

Instructions
	: Instructions Instruction     { $1.push($2); $$ = $1;  }
	| Instruction					{ $$ = [$1]; }
;

Instruction
    : TFUNCT TASSIGN '[' ID ']' '(' Param ')' '{' body '}' ';'
        { $$ = funciones.insertarFuncion($1,$4,$7,$10);}
    ;

Param
    : /* Empty */
    | ID { $$ = $1;}
    ;

body
    : /* Empty */
    | ListSentences
    ;

ListSentences
    : ListSentences Sentence { $1.push($2); $$ = $1; }
    | Sentence                 { $$ = [$1]; }
    ;

Sentence
    : TPRINT TASSIGN '(' String_Expression ')' ';'	{ $$ = $4; }
    | TDECLARE TASSIGN '[' ID ']' ';' { $$ = funciones.declararVariable($4); }
    | ID TASSIGN String_Expression ';' {$$ = funciones.actualizarVariable($1, $3); }
    | ID O_Operators Number_Expression ';'
        {
            var v1 = funciones.extraerVariable($1);
            if($2 === '+=' ) {
                var res = funciones.OperacionesNumericas( v1, $3, '+');
                $$ = funciones.actualizarVariable($1, res);
                }
          else if($2 === '-=' ) {
              var res = funciones.OperacionesNumericas( v1, $3, '-');
            $$ = funciones.actualizarVariable($1, res);
            }
          else if($2 === '*=' ) {
              var res = funciones.OperacionesNumericas( v1, $3, '*');
              $$ = funciones.actualizarVariable($1, res); }
          else if($2 === '/=' ) {
              var res = funciones.OperacionesNumericas( v1, $3, '/');
              $$ = funciones.actualizarVariable($1, res);
              }
           }
    | TWHILE TASSIGN '(' Logical_Expression ')' '{' ListSentences '}' ';'
    | TDO TASSIGN '{' ListSentences '}' TWHILE TASSIGN '(' Logical_Expression ')'';'
    | TFOR TASSIGN '[' ID TASSIGN Number_Expression ']' '(' Logical_Expression ';' ID '+' '+' ')' '{' ListSentences '}' ';'
    | TIF TASSIGN '(' Logical_Expression ')' '{' ListSentences '}' ';'
    | TIF TASSIGN '(' Logical_Expression ')' '{' ListSentences '}' TELSE TASSIGN '{' ListSentences '}' ';'
    	| error { throw 'Este es un error sintáctico: ' + yytext + ', en la linea: ' + this._$.first_line + ', en la columna: ' + this._$.first_column; }
    ;

Expression
    : STRING { $$ = [$1]; }
    ;


Number_Expression
    : '-' Number_Expression %prec UMENOS      { $$ = funciones.OperacionesNumericas( -$2, 0, '+');}
    | Number_Expression '+' Number_Expression { $$ = funciones.OperacionesNumericas( $1, $3, $2); }
    | Number_Expression '-' Number_Expression { $$ = funciones.OperacionesNumericas( $1, $3, $2); }
    | Number_Expression '*' Number_Expression { $$ = funciones.OperacionesNumericas( $1, $3, $2); }
    | Number_Expression '/' Number_Expression { $$ = funciones.OperacionesNumericas( $1, $3, $2); }
    | '(' Number_Expression ')'               { $$ = $2; }
    | INTEGER                                 { $$ = Number($1); }
    | DECIMAL                                 { $$ = Number($1); }
    | ID                                      { $$ = funciones.extraerVariable($1);}
    ;

String_Expression
    : String_Expression CONCAT String_Expression { $$ = $1 + $3; }
    | STRING            { $$ = $1; }
    | BOOLEAN           { $$ = $1; }
    | Number_Expression { $$ = $1; }
    ;

Relational_Expression
    : Number_Expression GRTR Number_Expression   { $$ = ( $1 > $3 ); }
    | Number_Expression LESS Number_Expression   { $$ = ( $1 < $3 ); }
    | Number_Expression GRTREQ Number_Expression { $$ = ( $1 >= $3 ); }
    | Number_Expression LESSEQ Number_Expression { $$ = ( $1 <= $3 ); }
    | Number_Expression EQUAL Number_Expression { $$ = ( $1 === $3 ); }
    | Number_Expression DIFF Number_Expression { $$ = ( $1 !== $3 ); }
    ;

Logical_Expression
    : Relational_Expression '&&' Relational_Expression      { $$ = ( $1 && $3 );}
    | Relational_Expression '||' Relational_Expression      { $$ = ( $1 || $3 );}
    | '!' Relational_Expression                             { $$ = !$1 }
    | Relational_Expression                                 { $$ = $1; }
    ;

O_Operators
    : PEQ  { $1 = '+='; $$ = $1; }
    | MEQ  { $1 = '-='; $$ = $1; }
    | MUEQ  { $1 = '*='; $$ = $1; }
    | DIEQ  { $1 = '/='; $$ = $1; }
    ;


BOOLEAN
    : TTRUE   { $1='true' ; $$ = $1; }
    | TFALSE   { $1='false' ; $$ = $1; }
    ;
