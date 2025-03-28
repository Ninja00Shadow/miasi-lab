    MOV A,#0
    PUSH A
    MOV A,#1
    POP B
    CMP A, B
    JNE label_eq_
    MOV A, #1
    JMP label_eq_end_
    label_eq_:
    MOV A, #0
    label_eq_end_:
        JE label_else_0
            MOV A,#3

        JMP label_endif_0
    label_else_0:
            MOV A,#4

    label_endif_0:
    brk
    MOV A,#0
    PUSH A
    MOV A,#1
    POP B
    CMP A, B

        JE label_else_1
            MOV A,#5

        JMP label_endif_1
    label_else_1:
            MOV A,#6

    label_endif_1:
