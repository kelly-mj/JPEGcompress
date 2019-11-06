.data
    prompt: .asciiz "Input an integer x:\n"
    one: .double 1
.text
main:
	la $t8, one
	l.d $f8, 0($t8)
    
    # show prompt
    li        $v0, 4
    la        $a0, prompt
    syscall
    
    # read x
    li        $v0, 7 #double is stored in $f0
    syscall
    # function call
    jal      exponents       # jump factorial and save position to $ra
    
    add $a0, $zero, 2
    jal factorial
    move $t1, $v0 #2! is in $t1 as an int.
    
    add $a0, $zero, 4
    jal factorial
    move $t2, $v0 #4! is iin $t2 as an int
    
    add $a0, $zero, 6
    jal factorial
    move $t3, $v0 #6! is in $t3 as an int
    
    #converts the 2! to a float  value
    mtc1.d $t1, $f10
    cvt.d.w $f10, $f10
    
    #value of x squared divided by 2! stored in $f2
    div.d $f2, $f2, $f10
    
    sub.d $f8, $f8, $f2        
       
    #converts the 4! to a float version
    mtc1.d $t2, $f10
    cvt.d.w $f10, $f10
             
    
    #value of x to the fourth divided by 4! stored in $f4
    div.d $f4, $f4, $f10     
    
    add.d $f8, $f8, $f4
   
            
    #converts the 6! to a float version
    mtc1.d $t3, $f10
    cvt.d.w $f10, $f10
    
    #value of x to the sixth divided by 6! stored in $f6
    div.d $f6, $f6, $f10
    
    sub.d $f8, $f8, $f6
    
    # print the result
    li        $v0, 3      # system call #1 - print int
    mov.d $f12, $f8
    syscall                # execute
    # return 0
    li        $v0, 10        # $v0 = 10
    syscall


.text
exponents:
	#squares the input
	mul.d $f2 $f0, $f0
	
	#power to the fourth
	mul.d $f4, $f2, $f2

	 #power to the sixth
	mul.d $f6, $f4, $f4
	
	jr $ra

factorial:
    # base case -- still in parent's stack segment
    # adjust stack pointer to store return address and argument
    addi    $sp, $sp, -8
    # save $s0 and $ra
    sw      $s0, 4($sp)
    sw      $ra, 0($sp)
    bne     $a0, 0, else
    addi    $v0, $zero, 1    # return 1
    j fact_return

else:
    # backup $a0
    move    $s0, $a0
    addi    $a0, $a0, -1 # x -= 1
    jal     factorial
    # when we get here, we already have Fact(x-1) store in $v0
    multu   $s0, $v0 # return x*Fact(x-1)
    mflo    $v0
fact_return:
    lw      $s0, 4($sp)
    lw      $ra, 0($sp)
    addi    $sp, $sp, 8
    jr      $ra