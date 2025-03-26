package Lab4.compiler;

import org.antlr.v4.runtime.tree.TerminalNode;
import org.stringtemplate.v4.ST;
import org.stringtemplate.v4.STGroup;
import Lab4.grammar.firstBaseVisitor;
import Lab4.grammar.firstParser;

import java.util.ArrayList;
import java.util.List;

public class EmitVisitor extends firstBaseVisitor<ST> {
    private final STGroup stGroup;
    private int labelCounter = 0;

    private ST declarations;

    public EmitVisitor(STGroup group) {
        super();
        this.stGroup = group;
        this.declarations = group.getInstanceOf("decls");
    }

    private String newLabel(String base) {
        return base + (labelCounter++);
    }

    @Override
    protected ST defaultResult() {
        return stGroup.getInstanceOf("deflt");
    }

    @Override
    protected ST aggregateResult(ST aggregate, ST nextResult) {
        if (nextResult != null)
            aggregate.add("elem", nextResult);
        return aggregate;
    }

    @Override
    public ST visitProg(firstParser.ProgContext ctx) {
        ST prog =  super.visitProg(ctx);
        ST st = stGroup.getInstanceOf("deflt");
        st.add("elem", declarations);
        st.add("elem", prog);
        return st;
    }

    @Override
    public ST visitTerminal(TerminalNode node) {
//        return new ST("Terminal node:<n>").add("n", node.getText());
        return super.visitTerminal(node);
    }

    @Override
    public ST visitInt_tok(firstParser.Int_tokContext ctx) {
        ST st = stGroup.getInstanceOf("int");
        st.add("i", ctx.INT().getText());
        return st;
    }

    @Override
    public ST visitId_tok(firstParser.Id_tokContext ctx) {
        ST st = stGroup.getInstanceOf("id");
        st.add("id", ctx.ID().getText());
        return st;
    }

    @Override
    public ST visitBinOp(firstParser.BinOpContext ctx) {
        String template = switch (ctx.op.getType()) {
            case firstParser.ADD -> "dodaj";
            case firstParser.SUB -> "odejmij";
            case firstParser.MUL -> "mnoz";
            case firstParser.DIV -> "dziel";
            default -> null;
        };
        if (template == null) return null;
        ST st = stGroup.getInstanceOf(template);
        return st.add("p1", visit(ctx.l)).add("p2", visit(ctx.r));
    }

    @Override
    public ST visitLogicOp(firstParser.LogicOpContext ctx) {
        String template = ctx.op.getType() == firstParser.AND ? "and" : "or";
        ST st = stGroup.getInstanceOf(template);
        String suffix = newLabel(template.toUpperCase());
        return st.add("p1", visit(ctx.l))
                .add("p2", visit(ctx.r))
                .add("suffix", suffix);
    }

    @Override
    public ST visitUnaryLogicOp(firstParser.UnaryLogicOpContext ctx) {
        ST st = stGroup.getInstanceOf("nie");
        return st.add("p", visit(ctx.expr()));
    }

    @Override
    public ST visitCompOp(firstParser.CompOpContext ctx) {
        String template;
        switch (ctx.op.getType()) {
            case firstParser.LT -> template = "lt";
            case firstParser.LE -> template = "le";
            case firstParser.GT -> template = "gt";
            case firstParser.GE -> template = "ge";
            case firstParser.EQ -> template = "eq";
            case firstParser.NEQ -> template = "ne";
            default -> {
                return super.visitCompOp(ctx);
            }
        }
        ST st = stGroup.getInstanceOf(template);
        String suffix = newLabel(template.toUpperCase());
        return st.add("p1", visit(ctx.l))
                .add("p2", visit(ctx.r))
                .add("suffix", suffix);
    }

    @Override
    public ST visitAssign(firstParser.AssignContext ctx) {
        ST st = stGroup.getInstanceOf("assign");
        return st.add("id", ctx.ID().getText()).add("p", visit(ctx.expr()));
    }

    @Override
    public ST visitVar_decl(firstParser.Var_declContext ctx) {
        declarations.add("id", ctx.ID().getText());

        if (ctx.expr() != null) {
            ST st = stGroup.getInstanceOf("assign");
            st.add("id", ctx.ID().getText()).add("p", visit(ctx.expr()));
            return st;
        }
        return null;
    }

    @Override
    public ST visitIf_stat(firstParser.If_statContext ctx) {
        String elseLabel = "else";
        String endLabel = "end";
        ST st;
        if (ctx.else_ == null) {
            st = stGroup.getInstanceOf("if_no_else")
                    .add("cond", visit(ctx.cond))
                    .add("thenBlock", visit(ctx.then))
                    .add("endLabel", endLabel);
        } else {
            st = stGroup.getInstanceOf("if_else")
                    .add("cond", visit(ctx.cond))
                    .add("thenBlock", visit(ctx.then))
                    .add("elseBlock", visit(ctx.else_))
                    .add("elseLabel", elseLabel)
                    .add("endLabel", endLabel);
        }
        return st;
    }
}
