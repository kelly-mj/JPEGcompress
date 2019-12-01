#	helpers.asm

.globl end_loop
.globl exit

end_loop:
	jr	$ra
 
exit:
	li	$v0, 10
	syscall