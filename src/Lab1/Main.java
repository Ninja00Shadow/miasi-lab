package Lab1;

import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;

public class Main {
    public static void main(String[] args) {
        // create a CharStream that reads from standard input
//	CharStream input = CharStreams.fromStream(System.in);
        CharStream input = CharStreams.fromString("f(x) { x and y; }");

        // create a lexer that feeds off of input CharStream
        ExprLexer lexer = new ExprLexer(input);

        // create a buffer of tokens pulled from the lexer
        CommonTokenStream tokens = new CommonTokenStream(lexer);

        // create a parser that feeds off the tokens buffer
        ExprParser parser = new ExprParser(tokens);

        // start parsing at the program rule
        ParseTree tree = parser.program();
        // System.out.println(tree.toStringTree());

        // create a visitor to traverse the parse tree
        Logic visitor = new Logic();
        System.out.println(visitor.visit(tree));
    }
}