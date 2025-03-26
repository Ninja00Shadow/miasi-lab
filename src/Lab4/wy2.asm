    DD x
    DD y
    DD a
    DD b
            MOV A,#2
            MOV [x], A

            MOV A,#10
            MOV [y], A

        MOV A,#3
        PUSH A
        MOV A, [x]
        POP B
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

            MOV A,#3
            PUSH A
            MOV A, [x]
            POP B
            MUL A, B
            PUSH A
            MOV A,#3
            PUSH A
                MOV A,#2
                PUSH A
                MOV A,#1
                POP B
                ADD A,B

            POP B
            DIV A, B
            POP B
            SUB A, B
            MOV [a], A

            MOV A,#2
            PUSH A
            MOV A,#3
            POP B
            DIV A, B
            MOV [b], A

