	.data
	
	blank: .asciiz " "
	Numberstring: .word 5589999993030302222222222224444455899999930303022222222222244444
	BWString: .asciiz "WWWWWWWWWWWW" #WWWWWWWWWWWWBWWWWWWWWWWWWBBBWWWWWWWWWWWWWWWWWWWWWWWWBWWWWWWWWWWWWWW"
	inputWord: .word BWString
	

	.text
.globl RunLengthEncoding
RunLengthEncoding:   
	la  $s0, Numberstring #load the string that you want to  use
	            
	add $s1, $s0, 0 #sets the  pointer to the frst space
	lw $s2, 0($s1) #this gets the first letter and sets it as the value
	move $t3, $s2	#$t3 is  the one you are comparing it with
	li $t0, 0 #pointer for the string
	li $t4, 0 #counter for the lettters

loop:
	beq $s2, $zero, exit #reaches end  of string
	add $s1, $s0, $t0   #moves the pointer along the string
	lw  $s2, 0($s1)      #Loading char to shift into $s2
	addi $t0, $t0, 4    #i++
	addi $t4, $t4, 1 #counter for the letter++
	bne $t3, $s2, reset
	move $t3, $s2
	
	#prints this out for testing. 
	#li $v0,  11
	#move $a0, $s2
	#syscall
	
	j loop
	
reset: 
	li $v0, 1
	move $a0, $t4	#prints out the counter
	syscall
	li $v0, 11
	move $a0, $t3	#prints out the character
	syscall
	li $t4, 0 #reset the character counter
	move $t3, $s2
	j loop
	
exit: 
	li $v0, 10
	syscall
