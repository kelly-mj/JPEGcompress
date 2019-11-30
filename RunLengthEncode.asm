	.data
	
	blank: .asciiz " "
	string: .asciiz "WWWWWWWWWWWWBWWWWWWWWWWWWBBBWWWWWWWWWWWWWWWWWWWWWWWWBWWWWWWWWWWWWWW"

	.text
main:   
	la $s0, string     
	            
	add $s1, $s0, 0 
	lb $s2, 0($s1)
	move $t3, $s2
	li $t0, 0
	li $t4, 0 #counter

counting:
	beq $s2, $zero, exit
	add $s1, $s0, $t0   
	lb $s2, 0($s1)      #Loading char to shift into $s2
	addi $t0, $t0, 1    #i++
	addi $t4, $t4, 1
	bne $t3, $s2, reset
	move $t3, $s2

	#prints this out for testing. 
	#li $v0,  11
	#move $a0, $s2
	#syscall
	
	j counting
	
reset: 
	li $v0, 1
	move $a0, $t4	#prints out the counter
	syscall
	li $v0, 11
	move $a0, $t3	#prints out the character
	syscall
	li $t4, 0 #reset the character counter
	move $t3, $s2
	j counting
	
exit: 
	li $v0, 10
	syscall