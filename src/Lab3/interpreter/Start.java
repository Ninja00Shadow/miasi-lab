package Lab3.interpreter;

import Lab3.grammar.*;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.ParseTree;

import java.io.IOException;

public class Start {
    public static void main(String[] args) {
        CharStream inp = null;
        try {
            inp = CharStreams.fromFileName("src/Lab3/we.first");
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
//        inp = CharStreams.fromString("1+2*3-(4+5)","wejście");
//        inp = CharStreams.fromStream(System.in);
//        inp = CharStreams.fromString("if (3 + 2) { > 2 } else { > 4 }", "wejście");

        firstLexer lex = new firstLexer(inp);
        CommonTokenStream tokens = new CommonTokenStream(lex);
        firstParser par = new firstParser(tokens);

        ParseTree tree = par.prog();

        CalculateVisitor v = new CalculateVisitor(inp,tokens);
        Integer res = v.visit(tree);
//        System.out.printf("Wynik: %d\n", res);
    }
}
