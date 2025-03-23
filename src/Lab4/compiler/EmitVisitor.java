package Lab4.compiler;

import org.antlr.v4.runtime.tree.TerminalNode;
import org.stringtemplate.v4.ST;
import org.stringtemplate.v4.STGroup;
import Lab4.grammar.firstBaseVisitor;
import Lab4.grammar.firstParser;

public class EmitVisitor extends firstBaseVisitor<ST> {
    private final STGroup stGroup;

    public EmitVisitor(STGroup group) {
        super();
        this.stGroup = group;
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
    public ST visitTerminal(TerminalNode node) {
        return new ST("Terminal node:<n>").add("n", node.getText());
    }

    @Override
    public ST visitInt_tok(firstParser.Int_tokContext ctx) {
        ST st = stGroup.getInstanceOf("int");
        st.add("i", ctx.INT().getText());
        return st;
    }

    @Override
    public ST visitBinOp(firstParser.BinOpContext ctx) {
        switch (ctx.op.getType()) {
            case firstParser.ADD:
                ST st = stGroup.getInstanceOf("dodaj");
                return st.add("p1", visit(ctx.l)).add("p2", visit(ctx.r));
            case firstParser.SUB:
                ST st1 = stGroup.getInstanceOf("odejmij");
                return st1.add("p1", visit(ctx.l)).add("p2", visit(ctx.r));
            case firstParser.MUL:
                ST st2 = stGroup.getInstanceOf("mnoz");
                return st2.add("p1", visit(ctx.l)).add("p2", visit(ctx.r));
            case firstParser.DIV:
                ST st3 = stGroup.getInstanceOf("dziel");
                return st3.add("p1", visit(ctx.l)).add("p2", visit(ctx.r));
            default:
                return null;
        }
    }

//    @Override
//    public ST visitLogicOp(firstParser.LogicOpContext ctx) {
//        ST st;
//        switch (ctx.op.getType()) {
//            case firstParser.AND:
//                st = stGroup.getInstanceOf("andOp");
//                break;
//            case firstParser.OR:
//                st = stGroup.getInstanceOf("orOp");
//                break;
//            default:
//                return null;
//        }
//        return st.add("p1", visit(ctx.l)).add("p2", visit(ctx.r));
//    }

    @Override
    public ST visitUnaryLogicOp(firstParser.UnaryLogicOpContext ctx) {
        ST st = stGroup.getInstanceOf("nie");
        return st.add("p", visit(ctx.expr()));
    }

    @Override
    public ST visitCompOp(firstParser.CompOpContext ctx) {
        ST st;
        switch (ctx.op.getType()) {
            case firstParser.GT:
                st = stGroup.getInstanceOf("gt");
                break;
            case firstParser.EQ:
                st = stGroup.getInstanceOf("eq");
                break;
            default:
                return super.visitCompOp(ctx);
        }
        return st.add("p1", visit(ctx.l)).add("p2", visit(ctx.r));
    }

    @Override
    public ST visitAssign(firstParser.AssignContext ctx) {
        ST st = stGroup.getInstanceOf("assign");
        return st.add("id", ctx.ID().getText()).add("p", visit(ctx.expr()));
    }

    @Override
    public ST visitIf_stat(firstParser.If_statContext ctx) {
        String base = ctx.cond.getText().replaceAll("\\W", ""); // prosty sufiks
        String elseLabel = "else" + base;
        String endLabel = "end" + base;
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

    @Override
    public ST visitWhile_stat(firstParser.While_statContext ctx) {
        return super.visitWhile_stat(ctx);
    }

    @Override
    public ST visitVar_decl(firstParser.Var_declContext ctx) {
        ST st = stGroup.getInstanceOf("var_decl_init");
        st.add("id", ctx.ID().getText()).add("p", visit(ctx.expr()));
        return st;
    }

    @Override
    public ST visitId_tok(firstParser.Id_tokContext ctx) {
        ST st = stGroup.getInstanceOf("id");
        st.add("id", ctx.ID().getText());
        return st;
    }
}
