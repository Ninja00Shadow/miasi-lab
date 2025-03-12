lexer grammar CalcLexer;

ADD : '+' ;
SUB : '-' ;
MULT : '*' ;
DIV : '/' ;

LPAREN : '(' ;
RPAREN : ')' ;

INT : [0-9]+ ;
//FLOAT : [0-9]+ ('.' | ',') [0-9]+ ;

WS : [ \t\n\r]+ -> skip ;