package Lab2;

public class CalcVisitor extends CalcParserBaseVisitor<Integer> {
    @Override
    public Integer visitEquation(CalcParser.EquationContext ctx) {
        return visit(ctx.expr());
    }

    @Override
    public Integer visitExpr(CalcParser.ExprContext ctx) {
        System.out.println("visitExpr: " + ctx.getText());
        if (ctx.ADD() != null) {
            return visit(ctx.expr(0)) + visit(ctx.expr(1));
        } else if (ctx.SUB() != null) {
            return visit(ctx.expr(0)) - visit(ctx.expr(1));
        } else if (ctx.MULT() != null) {
            return visit(ctx.expr(0)) * visit(ctx.expr(1));
        } else if (ctx.DIV() != null) {
            return visit(ctx.expr(0)) / visit(ctx.expr(1));
        } else if (ctx.INT() != null) {
            return Integer.parseInt(ctx.INT().getText());
        } else {
            return visit(ctx.expr(0));
        }
    }
}