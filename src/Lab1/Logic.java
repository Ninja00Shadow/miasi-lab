package Lab1;

public class Logic extends ExprParserBaseVisitor<Boolean> {
    @Override
    public Boolean visitProgram(ExprParser.ProgramContext ctx) {
        if(ctx.stat() != null) return visit(ctx.stat());
        else return false;
    }

    @Override
    public Boolean visitStat(ExprParser.StatContext ctx) {
//        if(ctx.expr() != null) return visit(ctx.expr());
//        else return false;
        return true;
    }
}