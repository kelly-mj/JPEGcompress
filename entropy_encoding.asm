    # RLE/Hoffman Encoding
    # Given quantized data in zig-zag form, perform RLE encoding followed by Huffman encoding to produce compressed data.
    
    .data
    
    blank: .asciiz " "
    flag: .word 0
    
		# s6 holds the output for RLE encoding, is input for huffman encoding step
		# t5 is a temp register for moving elements of s0 to s6
		# t4 holds the count for succeeding zeroes
    .text
    .globl 
    entropy_encoding:
    	move $s0, $a0		# Move contents of pixel-data to s0
    	addi $t0, $zero, 64 	# t0 is the counter variable
    	jal process
    	
    	li $v0, 10
    	syscall
    	
    .globl
    process:
    	bnez $s0, non_zero	# if nonzero, go to the function for handling non-zero entries
    	beqz $s0, zero			# If it is not a non-zero, must be zero
    	#lw $t5, 0x4($s0)	# Otherwise, the number is a zero and we need to store it and it's frequency (value precedes frequency, e.g. 1 2 0 0 0 => 1 2 0 3
    	#sw $s6, ($t5)
    	
    	# move s6 to a0 before doing jr $ra
    	beqz $t0, end
    	
    .globl	
    non_zero:			# Number is not a zero, increment counter by 1, increment s0 by 4, keep looping and store the current data
    	lw $t5, 0x4($s0) 	# Load current cell of s0 into t5
    	sw $s6, flag($t5)	# Store current cell (pixel data) of t5 into s6 -- Flag is a pointer to keep track of where we need to add new values in s6, and where to access in t5
    	addi $s6, $s6, 4	# Increment current cell for next value to be added into s6
    	addi flag, flag, 4	# Incremenet flag 
    	
    	addi $s0, $s0, 4	# Increment s0
    	addi $t0, $t0, -1	# Decrement
    	
    	j process
    	
    .globl
    zero:			# Current entry is a zero, we need to first store 0 to output, and then count number of succeeding zeroes (storing into the next cell of output)
    	lw $t5, 0x4($s0) 	
    	sw $s6, flag($t5)
    	addi $s6, $s6, 4
    	addi flag, flag, 4
    	addi $s0, $s0, 4
    	addi $t0, $t0, -1
 	addi $t4, $zero, 1
 	sw $s6, ($t4)
 	
 	# Now, we have a running count of the number of succeeding zeroes, and we have stored the initial zero into s6
 	
 	
    	beqz, $t0, end
    	
    .globl
    end:
    	move $a0, $s6 		# Move contents of RLE output to a0
    	jr $ra
    		
    	
