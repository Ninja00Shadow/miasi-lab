package Lab2;

import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;

public class Main {
    public static void main(String[] args) {
        // create a CharStream that reads from standard input
//        CharStream input = CharStreams.fromStream(System.in);
        CharStream input = CharStreams.fromString("(2 + 3) * (11 - (4 + 3!))");
//        CharStream input = CharStreams.fromString("2 + 3 * 11 - 4 + Z 1");

        // create a lexer that feeds off of input CharStream
        CalcLexer lexer = new CalcLexer(input);

        // create a buffer of tokens pulled from the lexer
        CommonTokenStream tokens = new CommonTokenStream(lexer);

        // create a parser that feeds off the tokens buffer
        CalcParser parser = new CalcParser(tokens);

        // start parsing at the equation rule
        ParseTree tree = parser.equation();
//        System.out.println(tree.toStringTree(parser));

        // create a visitor to traverse the parse tree
        CalcVisitor visitor = new CalcVisitor();
        System.out.println(visitor.visit(tree));
    }
}