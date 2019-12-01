#	zigzag.asm

.globl	zigzag

# ARGUMENTS: $a0 = pixel data to zig-zag scan; reordered data will rewrite old data
#            $a1 = address of unused space in memory to store intermediate data
zigzag:
	addi	$sp, $sp, -16		# make space on the stack
	sw	$ra, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)
	sw	$s3, 16($sp)
	
	### store copies of data addresses ###
	add	$s1, $zero, $a0		# original data
	add	$s2, $zero, $a1		# copied data
	
	### copy contents of quantized data to an old space in memory ###
	addi	$a2, $zero, 64
	jal	copy
	
	### reorder data; copy into original location ###
	jal	order
	
	lw	$s3, 16($sp)		# restore the stack
	lw	$s2, 12($sp)
	lw	$s1, 8($sp)
	lw	$ra, 4($sp)
	addi	$sp, $sp, 16
	jr $ra
	
order:
	### row 0 ###
	lw	$t0, ($s2)
	sw	$t0, ($s1)
	lw	$t0, 4($s2)
	sw	$t0, 4($s1)
	lw	$t0, 20($s2)
	sw	$t0, 8($s1)
	lw	$t0, 24($s2)
	sw	$t0, 12($s1)
	
	lw	$t0, 56($s2)
	sw	$t0, 16($s1)
	lw	$t0, 60($s2)
	sw	$t0, 20($s1)
	lw	$t0, 108($s2)
	sw	$t0, 24($s1)
	lw	$t0, 112($s2)
	sw	$t0, 28($s1)
	
	### row 1 ###
	lw	$t0, 8($s2)
	sw	$t0, 32($s1)
	lw	$t0, 16($s2)
	sw	$t0, 36($s1)
	lw	$t0, 28($s2)
	sw	$t0, 40($s1)
	lw	$t0, 52($s2)
	sw	$t0, 44($s1)
	
	lw	$t0, 64($s2)
	sw	$t0, 48($s1)
	lw	$t0, 104($s2)
	sw	$t0, 52($s1)
	lw	$t0, 116($s2)
	sw	$t0, 56($s1)
	lw	$t0, 168($s2)
	sw	$t0, 60($s1)
	
	### row 2 ###
	lw	$t0, 12($s2)
	sw	$t0, 64($s1)
	lw	$t0, 32($s2)
	sw	$t0, 68($s1)
	lw	$t0, 48($s2)
	sw	$t0, 72($s1)
	lw	$t0, 68($s2)
	sw	$t0, 76($s1)
	lw	$t0, 100($s2)
	sw	$t0, 80($s1)
	lw	$t0, 120($s2)
	sw	$t0, 84($s1)
	lw	$t0, 164($s2)
	sw	$t0, 88($s1)
	lw	$t0, 172($s2)
	sw	$t0, 92($s1)
	
	### row 3 ###
	lw	$t0, 36($s2)
	sw	$t0, 96($s1)
	lw	$t0, 44($s2)
	sw	$t0, 100($s1)
	lw	$t0, 72($s2)
	sw	$t0, 104($s1)
	lw	$t0, 96($s2)
	sw	$t0, 108($s1)
	
	lw	$t0, 124($s2)
	sw	$t0, 112($s1)
	lw	$t0, 160($s2)
	sw	$t0, 116($s1)
	lw	$t0, 176($s2)
	sw	$t0, 120($s1)
	lw	$t0, 212($s2)
	sw	$t0, 124($s1)
	
	### row 4 ###
	lw	$t0, 40($s2)
	sw	$t0, 128($s1)
	lw	$t0, 76($s2)
	sw	$t0, 132($s1)
	lw	$t0, 92($s2)
	sw	$t0, 136($s1)
	lw	$t0, 128($s2)
	sw	$t0, 140($s1)
	
	lw	$t0, 156($s2)
	sw	$t0, 144($s1)
	lw	$t0, 180($s2)
	sw	$t0, 148($s1)
	lw	$t0, 208($s2)
	sw	$t0, 152($s1)
	lw	$t0, 216($s2)
	sw	$t0, 156($s1)
	
	### row 5 ###
	lw	$t0, 80($s2)
	sw	$t0, 160($s1)
	lw	$t0, 88($s2)
	sw	$t0, 164($s1)
	lw	$t0, 132($s2)
	sw	$t0, 168($s1)
	lw	$t0, 152($s2)
	sw	$t0, 172($s1)
	
	lw	$t0, 184($s2)
	sw	$t0, 176($s1)
	lw	$t0, 204($s2)
	sw	$t0, 180($s1)
	lw	$t0, 220($s2)
	sw	$t0, 184($s1)
	lw	$t0, 240($s2)
	sw	$t0, 188($s1)
	
	### row 6 ###
	lw	$t0, 84($s2)
	sw	$t0, 192($s1)
	lw	$t0, 136($s2)
	sw	$t0, 196($s1)
	lw	$t0, 148($s2)
	sw	$t0, 200($s1)
	lw	$t0, 188($s2)
	sw	$t0, 204($s1)
	
	lw	$t0, 200($s2)
	sw	$t0, 208($s1)
	lw	$t0, 224($s2)
	sw	$t0, 212($s1)
	lw	$t0, 236($s2)
	sw	$t0, 216($s1)
	lw	$t0, 244($s2)
	sw	$t0, 220($s1)
	
	### row 7 ###
	lw	$t0, 140($s2)
	sw	$t0, 224($s1)
	lw	$t0, 144($s2)
	sw	$t0, 228($s1)
	lw	$t0, 192($s2)
	sw	$t0, 232($s1)
	lw	$t0, 196($s2)
	sw	$t0, 236($s1)
	
	lw	$t0, 228($s2)
	sw	$t0, 240($s1)
	lw	$t0, 232($s2)
	sw	$t0, 244($s1)
	lw	$t0, 248($s2)
	sw	$t0, 248($s1)
	lw	$t0, 252($s2)
	sw	$t0, 252($s1)

	jr	$ra

