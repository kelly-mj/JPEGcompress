#	quantize.asm

.globl	quantize

# ARGUMENTS: $a0 = address of beginning of pixel data block we're manipulating
#	     $a1 = address of beginning of quantization table
# RETURNS:   nothing
# MODIFIES:  data in the pixel data block passed in from $a0
quantize:
# loop backwards through ecah word from quantization table
# order: 0x000000xx, 0x0000xx00, 0x00xx0000, 0xxx000000
	addi	$sp, $sp, -16		# make space on the stack
	sw	$ra, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)
	sw	$s3, 16($sp)
	
	add	$s1, $zero, $a0		# save address of beginning of pixel data
	add	$s2, $zero, $a1		# save address of beginning of quantization table
	add	$t9, $zero, $zero	# variable to store word offset from beginning of quantization table
	jal	q_loop
	
	lw	$s3, 16($sp)		# restore the stack
	lw	$s2, 12($sp)
	lw	$s1, 8($sp)
	lw	$ra, 4($sp)
	addi	$sp, $sp, 16
	jr $ra


q_loop:
	addi	$sp, $sp, -4		# make space on the stack
	sw	$ra, 4($sp)
	
	add	$t0, $s2, $t9		# get address of next word in quantization table (beginning + offset)		
	lw	$s3, ($t0)		# get data from entry in quantization table
	
	addi	$t7, $zero, 4		# set counter to loop through quantization entry
	jal	q_inner_loop
	
	lw	$ra, 4($sp)		# restore the stack
	addi	$sp, $sp, 4
	
	addi	$t9, $t9, 4		# add offset to point to next word in quantization table
	addi	$t0, $zero, 64		# store a comparison number (64) in a register
	beq	$t0, $t9, end_loop	# check whether the quantization offset = 64
	j	q_loop
	
q_inner_loop:
	###  get next lower bits of entry from quantization table  ###
	andi	$t1, $s3, 255		# store lower bits in $t1
	srl	$s3, $s3, 8		# shift unneeded bits out of the data entry
	
	###  load, transform, store pixel data  ###
	lw	$t0, ($s1)		# load pixel data
	div	$t0, $t1		# divide value in pixel data by value from quantization table
	mflo	$t0
	sw	$t0, ($s1)
	
	### increment/decrement variables ###
	addi	$t7, $t7, -1		# decrement the quantization table entry counter
	addi	$s1, $s1, 4		# point to next word in pixel data
	
	beqz	$t7, end_loop		# check whether the quantization pointer = 16
	j	q_inner_loop
	
	
	
	
	
	
	
	