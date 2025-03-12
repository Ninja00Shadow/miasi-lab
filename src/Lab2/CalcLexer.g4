lexer grammar CalcLexer;

ZER : 'Z' ;
FAC : '!';
ADD : '+' ;
SUB : '-' ;
MULT : '*' ;
DIV : '/' ;

LPAREN : '(' ;
RPAREN : ')' ;

INT : [0-9]+ ;

WS : [ \t\n\r]+ -> skip ;