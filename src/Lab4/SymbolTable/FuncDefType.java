package Lab4.SymbolTable;

import Lab3.interpreter.CalculateVisitor;
import org.antlr.v4.runtime.tree.ParseTree;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class FuncDefType {
    private final List<String> params = new ArrayList<>();
    private ParseTree body;
    private final Map<String, Integer> args = new HashMap<>();
    private int argumentIndex = 0;

    public void addParam(String param) {
        params.add(param);
    }

    public void setBody(ParseTree body) {
        this.body = body;
    }

    public void addArgument(Integer value) {
        if (argumentIndex >= params.size()) {
            throw new RuntimeException("Too many arguments");
        }

        String paramName = params.get(argumentIndex);
        args.put(paramName, value);
        argumentIndex++;
    }

    private void clearArguments() {
        args.clear();
        argumentIndex = 0;
    }

    public Integer invoke(CalculateVisitor visitor) {
        if (args.size() != params.size()) {
            throw new RuntimeException("Not enough arguments");
        }

        visitor.pushScope();

        for (String param : params) {
//            String paramName = param.getText();
            Integer value = args.get(param);
            visitor.setVariable(param, value);
        }

        Integer result = visitor.visit(body);

        visitor.popScope();

        clearArguments();

        return result;
    }
}
