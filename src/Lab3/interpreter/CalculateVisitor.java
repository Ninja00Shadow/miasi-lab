package Lab3.interpreter;

import Lab3.SymbolTable.LocalSymbols;
import Lab3.grammar.*;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.TokenStream;
import org.antlr.v4.runtime.misc.Interval;

import java.util.Objects;

public class CalculateVisitor extends firstBaseVisitor<Integer> {
    private LocalSymbols<Integer> localSymbols;

    private TokenStream tokStream = null;
    private CharStream input=null;
    public CalculateVisitor(CharStream inp) {
        super();
        this.input = inp;
    }

    public CalculateVisitor(TokenStream tok) {
        super();
        this.tokStream = tok;
    }
    public CalculateVisitor(CharStream inp, TokenStream tok) {
        super();
        this.input = inp;
        this.tokStream = tok;
    }
    private String getText(ParserRuleContext ctx) {
        int a = ctx.start.getStartIndex();
        int b = ctx.stop.getStopIndex();
        if(input==null) throw new RuntimeException("Input stream undefined");
        return input.getText(new Interval(a,b));
    }
    @Override
    public Integer visitIf_stat(firstParser.If_statContext ctx) {
        Integer result = 0;
        if (visit(ctx.cond)!=0) {
            result = visit(ctx.then);
        } else if (ctx.elseif!=null && visit(ctx.econd)!=0) {
            result = visit(ctx.elseif);
        }
        else {
            if(ctx.else_ != null)
                result = visit(ctx.else_);
        }
        return result;
    }

    @Override
    public Integer visitPrint_stat(firstParser.Print_statContext ctx) {
        var st = ctx.expr();
        var result = visit(st);
        System.out.printf("|%s=%d|\n", st.getText(), result); //nie drukuje ukrytych ani pominiętych spacji
//        System.out.printf("|%s=%d|\n", getText(st),  result); //drukuje wszystkie spacje
//        System.out.printf("|%s=%d|\n", tokStream.getText(st),  result); //drukuje spacje z ukrytego kanału, ale nie ->skip
        return result;
    }

    @Override
    public Integer visitInt_tok(firstParser.Int_tokContext ctx) {
        return Integer.valueOf(ctx.INT().getText());
    }

    @Override
    public Integer visitPars(firstParser.ParsContext ctx) {
        return visit(ctx.expr());
    }

    @Override
    public Integer visitBinOp(firstParser.BinOpContext ctx) {
        Integer result=0;
        switch (ctx.op.getType()) {
            case firstLexer.ADD:
                result = visit(ctx.l) + visit(ctx.r);
                break;
            case firstLexer.SUB:
                result = visit(ctx.l) - visit(ctx.r);
                break;
            case firstLexer.MUL:
                result = visit(ctx.l) * visit(ctx.r);
                break;
            case firstLexer.DIV:
                try {
                    result = visit(ctx.l) / visit(ctx.r);
                } catch (Exception e) {
                    System.err.println("Div by zero");
                    throw new ArithmeticException();
                }
        }
        return result;
    }

    @Override
    public Integer visitVar_decl_stat(firstParser.Var_decl_statContext ctx) {
        return super.visitVar_decl_stat(ctx);
    }

    @Override
    public Integer visitWhile_stat(firstParser.While_statContext ctx) {
        while (ctx.cond != null && visit(ctx.cond) != 0) {
            visit(ctx.block());
        }
        return 0;
    }

    @Override
    public Integer visitVar_decl(firstParser.Var_declContext ctx) {
//        return super.visitVar_decl(ctx);
        localSymbols.newSymbol(ctx.ID().getText());
        localSymbols.setSymbol(ctx.ID().getText(), visit(ctx.expr()));
        return localSymbols.getSymbol(ctx.ID().getText());
    }

    @Override
    public Integer visitLogicOp(firstParser.LogicOpContext ctx) {
        return switch (ctx.op.getType()) {
            case firstLexer.AND -> visit(ctx.l) > 0 && visit(ctx.r) > 0 ? 1 : 0;
            case firstLexer.OR -> visit(ctx.l) > 0 || visit(ctx.r) > 0 ? 1 : 0;
            default -> 0;
        };
    }

    @Override
    public Integer visitAssign(firstParser.AssignContext ctx) {
        Integer value = visit(ctx.expr());
        localSymbols.setSymbol(ctx.ID().getText(), value);
        return value;
    }

    @Override
    public Integer visitCompOp(firstParser.CompOpContext ctx) {
        return switch (ctx.op.getType()) {
            case firstLexer.LT -> visit(ctx.l) < visit(ctx.r) ? 1 : 0;
            case firstLexer.GT -> visit(ctx.l) > visit(ctx.r) ? 1 : 0;
            case firstLexer.LE -> visit(ctx.l) <= visit(ctx.r) ? 1 : 0;
            case firstLexer.GE -> visit(ctx.l) >= visit(ctx.r) ? 1 : 0;
            case firstLexer.EQ -> Objects.equals(visit(ctx.l), visit(ctx.r)) ? 1 : 0;
            case firstLexer.NEQ -> !Objects.equals(visit(ctx.l), visit(ctx.r)) ? 1 : 0;
            default -> 0;
        };
    }

    @Override
    public Integer visitBlock_single(firstParser.Block_singleContext ctx) {
        return super.visitBlock_single(ctx);
    }

    @Override
    public Integer visitBlock_real(firstParser.Block_realContext ctx) {
        localSymbols.enterScope();
        Integer result = super.visitBlock_real(ctx);
        localSymbols.leaveScope();
        return result;
    }

    @Override
    public Integer visitProg(firstParser.ProgContext ctx) {
//        return super.visitProg(ctx);
        localSymbols = new LocalSymbols<>();
        return super.visitProg(ctx);
    }

    @Override
    public Integer visitExpr_stat(firstParser.Expr_statContext ctx) {
        return super.visitExpr_stat(ctx);
    }

    @Override
    public Integer visitId_tok(firstParser.Id_tokContext ctx) {
        return localSymbols.getSymbol(ctx.ID().getText());
    }
}
