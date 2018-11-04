.code16         # Use 16-bit assembly
.globl start    # Tells linker where to start executing

start:
    movb $0x00, %ah         # set video mode
    movb $0x03, %al         # -80x25 text mode
    int $0x10               # call into BIOS
    movb $0x00, %al         # access the seconds register and stores its content to %al
    out %al, $0x70          # sends address to CMOS register
    in $0x71, %al           # reads in value of register on port 0x71
    and $0x0F, %al          # clears all but last 4 bits (digit) of number on %al
    add $0x30, %al          # convert to ASCII value
    movb %al, %bl           # moves data in %al to %bl
    movb $0x0E, %ah         # 0x0E is the BIOS code to print the single character
    int $0x10               # calls into BIOS via interrupt 
    movb $0x0d, %al         # sets %al to carriage return character
    movb $0x0E, %ah         # prints carriage return
    int $0x10               # previously commented on this instruction, didn't see the need to comment on repeated instructions
    movb $0x0a, %al         # sets %al to newline character
    movb $0x0E, %ah         # prints newline
    int $0x10               
    movw $question, %si     # loads %si with question string

print_question:
    lodsb                   # loads a single byte from (%si) into %al and increments %si
    testb %al, %al          # checks to see if byte is 0 (end of string)
    jz compare              # jump to compare input with generated number (jz jumps if ZF in EFLAGS is set)
    movb $0x0E, %ah          
    int $0x10               
    jmp print_question      # go back to the start of the loop

compare:
    movb $0x00, %ah         # preparation for BIOS interrupt for input
    int $0x16               # BIOS interrupt for input mode
    movb $0x0E, %ah         
    int $0x10               
    movb %al, %cl           # stores input into %cl
    movb $0x0d, %al         # sets %al to carriage return character
    movb $0x0E, %ah         
    int $0x10               
    movb $0x0a, %al         # sets %ah to newline character
    movb $0x0E, %ah         
    int $0x10               
    movw $wrong, %si        # stores the wrong input string into %si
    cmp %bl, %cl            # compares the value of random number and user input
    jne print_wrong         # if not equal, jump to print the wrong message
    movw $correct, %si      # if equal, load correct string into %si
    je print_correct        # jump to print the right message

print_wrong:
    lodsb                   
    testb %al, %al          
    jz reprompt             # jump to reprompt to ask user for a new input
    movb $0x0E, %ah         
    int $0x10               
    jmp print_wrong         # repeat loop

print_correct:  
    lodsb           
    testb %al, %al
    jz done                 # if done, jump to done
    movb $0x0E, %ah
    int $0x10
    jmp print_correct

reprompt:
    movw $question, %si     # reload %si with question string
    jmp print_question      # jump back to print_question to restart loop

question:
    .string "What number am I thinking of (0-9)? "

correct:
    .string "Right! Congratulations! "

wrong:
    .string "Wrong! "

done:
    jmp done                # loop forever

# This part pads out the rest of the boot sector making sure we end up with 512 bytes in total
.fill 510 - (. - start), 1, 0
.byte 0x55
.byte 0xAA
