#	copy.asm

.globl	copy

# ARGUMENTS: $a0 = location of data to copy
#            $a1 = location to copy data into
#	     $a2 = number of elements to copy
copy:
	addi	$sp, $sp, -4		# make space on the stack
	sw	$ra, 4($sp)
	
	add	$a3, $zero, $zero
	jal	copy_loop
	
	lw	$ra, 4($sp)		# restore the stack
	addi	$sp, $sp, 4
	jr $ra
	
copy_loop:
	lw	$t0, ($a0)		# load word from current location in original data
	sw	$t0, ($a1)		# store word in current location in copy data
	addi	$a0, $a0, 4		# point to next word in original data
	addi	$a1, $a1, 4		# point to next word in copy data
	
	addi	$a3, $a3, 1		# increment the counter
	beq	$a2, $a3, end_loop	# end loop if specified number of elements have been copied
	j	copy_loop