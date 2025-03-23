grammar first;

prog:	stat* EOF ;

stat: expr ';' #expr_stat
    | var_decl ';' #var_decl_stat
    | IF_kw '(' cond=expr ')' then=block (ELSE_IF_kw '(' econd=expr ')' elseif=block)* (ELSE_kw else=block)? #if_stat
    | WHILE_kw '(' cond=expr ')' body=block #while_stat
    | fname=ID '(' arg=ID ')' body=block #func_decl
    | '>' expr ';' #print_stat
    ;

//func_decl: fname=ID '(' ID (',' ID)* ')' body=block ;

block : stat #block_single
    | '{' block* '}' #block_real
    ;

var_decl: 'int' ID ('=' expr)? ;

expr:
        l=expr op=(MUL|DIV) r=expr #binOp
    |   l=expr op=(ADD|SUB) r=expr #binOp
    |   l=expr op=(LT | LE | GT | GE | EQ | NEQ) r=expr #compOp
    |   l=expr op=(AND | OR) r=expr #logicOp
    |   op=NOT r=expr #unaryLogicOp
    |   INT #int_tok
    |   ID #id_tok
    |   ID '(' expr ')' #func_call
    |   '(' expr ')' #pars
    |   <assoc=right> ID '=' expr #assign
    ;

IF_kw : 'if' ;
ELSE_IF_kw : 'else if' ;
ELSE_kw : 'else' ;
WHILE_kw : 'while' ;

DIV : '/' ;
MUL : '*' ;
SUB : '-' ;
ADD : '+' ;

LT  : '<' ;
LE  : '<=' ;
GT  : '>' ;
GE  : '>=' ;
EQ  : '==' ;
NEQ : '!=' ;

AND : '&&' ;
OR  : '||' ;
NOT : '!' ;

//NEWLINE : [\r\n]+ -> skip;
NEWLINE : [\r\n]+ -> channel(HIDDEN);

//WS : [ \t]+ -> skip ;
WS : [ \t]+ -> channel(HIDDEN) ;

INT     : [0-9]+ ;


ID : [a-zA-Z_][a-zA-Z0-9_]* ;

COMMENT : '/*' .*? '*/' -> channel(HIDDEN) ;
LINE_COMMENT : '//' ~'\n'* '\n' -> channel(HIDDEN) ;