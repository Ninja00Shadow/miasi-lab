package Lab2;

public class CalcVisitor extends CalcParserBaseVisitor<Integer> {
    @Override
    public Integer visitEquation(CalcParser.EquationContext ctx) {
        return visit(ctx.expr());
    }

    @Override
    public Integer visitExpr(CalcParser.ExprContext ctx) {
        System.out.println("visitExpr: " + ctx.getText());
        if (ctx.ZER() != null) {
            return 0;
        } else if (ctx.FAC() != null) {
            return factorial(visit(ctx.expr(0)));
        } else if (ctx.ADD() != null) {
            return visit(ctx.expr(0)) + visit(ctx.expr(1));
        } else if (ctx.SUB() != null) {
            return visit(ctx.expr(0)) - visit(ctx.expr(1));
        } else if (ctx.MULT() != null) {
            return visit(ctx.expr(0)) * visit(ctx.expr(1));
        } else if (ctx.DIV() != null) {
            return visit(ctx.expr(0)) / visit(ctx.expr(1));
        } else if (ctx.INT() != null) {
            return Integer.parseInt(ctx.INT().getText());
        } else if (ctx.LPAREN() != null) {
            return visit(ctx.expr(0));
        } else {
            throw new RuntimeException("Unexpected expression: " + ctx.getText());
        }
    }

    private int factorial(int number) {
        int result = 1;

        for (int factor = 2; factor <= number; factor++) {
            result *= factor;
        }

        return result;
    }
}