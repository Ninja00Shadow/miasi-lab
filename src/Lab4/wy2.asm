        DD x
        MOV A,#2
        MOV [x], A

        DD y
        MOV A,#10
        MOV [y], A

    MOV A,#3
    MOV B, A
    MOV A, [x]
    CMP A, B
    JG GT_TRUE_GT0
    MOV A, #0
    JMP GT_END_GT0
    GT_TRUE_GT0:
        MOV A, #1
    GT_END_GT0:
    MOV B,A
    MOV A,#0
    CMP A,B
    JE else
                    MOV A,#1
                    MOV [y], A


    JMP end
    else:
                    MOV A,#3
                    MOV [y], A


    end:
        DD z
        MOV A,#2
        MOV B, A
        MOV A,#3
        ADD A,B
        MOV [z], A

        DD w
        MOV A,#2
        MOV B, A
        MOV A,#3
        SUB A, B
        MOV [w], A

        DD v
        MOV A,#2
        MOV B, A
        MOV A,#3
        MUL A, B
        MOV [v], A

        DD u
        MOV A,#2
        MOV B, A
        MOV A,#6
        DIV A, B
        MOV [u], A

        DD t
        MOV A,#2
        MOV B, A
        MOV A,#3
        CMP A, B
        JG GT_TRUE_GT1
        MOV A, #0
        JMP GT_END_GT1
        GT_TRUE_GT1:
            MOV A, #1
        GT_END_GT1:
        MOV [t], A

        DD s
        MOV A,#2
        MOV B, A
        MOV A,#3
        CMP A, B
        JLE LE_TRUE_LE2
        MOV A, #0
        JMP LE_END_LE2
        LE_TRUE_LE2:
            MOV A, #1
        LE_END_LE2:
        MOV [s], A

