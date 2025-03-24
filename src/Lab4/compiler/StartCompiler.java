package Lab4.compiler;

import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.tree.ParseTree;
import org.stringtemplate.v4.ST;
import org.stringtemplate.v4.STGroup;
import org.stringtemplate.v4.STGroupFile;
import Lab4.grammar.firstLexer;
import Lab4.grammar.firstParser;

import java.io.FileWriter;
import java.io.IOException;

public class StartCompiler {
    public static void main(String[] args) {
        CharStream inp = null;

        try {
            inp = CharStreams.fromFileName("src/Lab4/we.second");
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
//        CharStream inp = CharStreams.fromString("1\n2+3+4","wejście");
        firstLexer lex = new firstLexer(inp);
        CommonTokenStream tokens = new CommonTokenStream(lex);
        firstParser par = new firstParser(tokens);

        ParseTree tree = par.prog();

        //st group
        STGroup.trackCreationEvents = true;
        STGroup group = new STGroupFile("src/Lab4/compiler/register.stg");

        EmitVisitor em = new EmitVisitor(group);
        ST res = em.visit(tree);
        System.out.println(res.render());
        try {
            var wr = new FileWriter("src/Lab4/wy2.asm");
            wr.write(res.render());
            wr.close();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
//        res.inspect();
    }
}
