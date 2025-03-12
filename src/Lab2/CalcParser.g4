parser grammar CalcParser;
options { tokenVocab=CalcLexer; }

equation
    : expr EOF
    ;

expr
    : expr MULT expr
    | expr DIV expr
    | expr ADD expr
    | expr SUB expr
    | LPAREN expr RPAREN
    | INT
//    | FLOAT
    ;