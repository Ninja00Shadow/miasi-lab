        DD x
        PUSH #2
        POP [x]

        DD y
        PUSH #10
        POP [y]

    PUSH [x]
    PUSH #3
    SUB
    PUSH #GT_TRUE_GT0
    JG
    PUSH #0
    PUSH #GT_END_GT0
    JMP
    GT_TRUE_GT0:
        PUSH #1
    GT_END_GT0:
    PUSH #else
    JE
                PUSH #1
                POP [y]


    PUSH #end
    JMP
    else:
                PUSH #3
                POP [y]


    end:
