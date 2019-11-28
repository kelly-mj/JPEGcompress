#	convert_color_space.asm

.globl	convert_color_space

# ARGUMENTS: $a0 = address of y_table, $a1 = address of y_pixel data
# RETURNS:   none
# USES:      $s4, $s5, $s6
convert_color_space:
	addi	$sp, $sp, -20		# make space on the stack
	sw	$ra, 4($sp)
	sw	$s4, 8($sp)
	sw	$s5, 12($sp)
	sw	$s6, 16($sp)
	sw	$s7, 20($sp)

	addi	$s4, $s0, -64		# store start of color table in $s4
	addi	$s5, $s5, 0		# offset
	add	$s6, $zero, $a0		# address of Y table
	add	$s7, $zero, $a1		# address of Y pixel data
	
	### loop through each entry in color table and convert RGB -> YCbCr ###
	jal	convert_color_space_loop
	
	### use the YCbCr data to store values for each pixel ###
	jal	get_ycbcr_pixel_data

	lw	$s7, 20($sp)		# return stack to original state
	lw	$s6, 16($sp)
	lw	$s5, 12($sp)
	lw	$s6, 8($sp)
	lw	$ra, 4($sp)
	addi	$sp, $sp, 20
	jr	$ra

# ARGUMENTS: $s4 = address of next entry in color table, $s5 = offset
# RETURNS:   none
convert_color_space_loop:
	addi	$sp, $sp, -4		# make space on the stack
	sw	$ra, 4($sp)
	
	### convert RBG to YCbCr; store converted values in memory ###
	add	$a0, $zero, $s4
	lw	$a0, ($a0)
	
	jal	transform_rgb_ybr
	
	add	$t0, $s6, $s5		# get address of next spot in Y table
	sw	$v0, ($t0)		# store returned Y value
	add	$t0, $s6, $s5		# get address of next spot in Cb table
	sw	$v1, 64($t0)		# store returned Cb value
	add	$t0, $s6, $s5		# get address of next spot in Cr table
	sw	$a0, 128($t0)		# store returned Cr value
	
	lw	$ra, 4($sp)		# restore stack
	addi	$sp, $sp, 4
	### advance pointer; end loop if we went through every value in the color table ###
	addi	$s4, $s4, 4
	beq	$s4, $s0, end_loop
	
	addi	$s5, $s5, 4		# increase offset and loop
	j	convert_color_space_loop


# ARGUMENTS: $a0 = data from entry in color table
# RETURNS:   $v0 = y-value (Y component), $v1 = u-value (Cr component), $a0 = v-value (Cb component)
transform_rgb_ybr:
	addi	$sp, $sp, -4		# make space on the stack so we can call subroutines
	sw	$ra, 4($sp)
	### Get RGB components and store as FP values ###
	and	$t0, $a0, 255		# R: mask G,B components in color value (get 0x------xx portion)
	and	$t1, $a0, 65280		# G: mask R,B components in color value (get 0x----xx-- portion)
	srl	$t1, $t1, 8		#    shift right so significant bits are in the lowest-order position
	srl	$t2, $a0, 16		# B: shift right so significant bits for B component are in the lowest-order position
	mtc1	$t0, $f0		# convert R to fp
	cvt.s.w	$f0, $f0
	mtc1	$t1, $f2		# convert G to fp
	cvt.s.w	$f2, $f2
	mtc1	$t2, $f4		# convert B to fp
	cvt.s.w	$f4, $f4
	
	### Y  = 0  + 0.299*R + 0.587*G + 0.144*B ###
	addi	$a0, $zero, 299		# R coefficient * 10^3
	addi	$a1, $zero, 587		# G coefficient * 10^3
	addi	$a2, $zero, 114		# B coefficient * 10^3
	addi	$a3, $zero, 0		# Constant to add
	jal	rgb_ybr_equ
	add	$t7, $zero, $v0
	### Cb = 128 - 0.169*R - 0.331*G + 0.499*B ###
	addi	$a0, $zero, -169	# R coefficient * 10^3
	addi	$a1, $zero, -331	# G coefficient * 10^3
	addi	$a2, $zero,  499	# B coefficient * 10^3
	addi	$a3, $zero,  128	# Constant to add
	jal	rgb_ybr_equ
	add	$t8, $zero, $v0
	### Cr = 128 + 0.499*R - 0.419*G - 0.081*B ###
	addi	$a0, $zero,  499	# R coefficient * 10^3
	addi	$a1, $zero, -419	# G coefficient * 10^3
	addi	$a2, $zero, -81		# B coefficient * 10^3
	addi	$a3, $zero,  128	# Constant to add
	jal	rgb_ybr_equ
	add	$t9, $zero, $v0
	
	add	$v0, $zero, $t7
	add	$v1, $zero, $t8
	add	$a0, $zero, $t9
	
	lw	$ra, 4($sp)		# return stack to original state
	addi	$sp, $sp, 4
	jr $ra				# return to caller


# ARGUMENTS: $a0=R_coeff, $a1=G_coeff, $a2=B_coeff, $a3=constant, $f0=R_value, $f2=G_value, $f4=B_value
# RETURNS  : $v0 = equation result rounded to the nearest integer
rgb_ybr_equ:
	addi	$sp, $sp, -4		# make space on the stack so we can call subroutines
	sw	$ra, 4($sp)
	
	addi	$t0, $zero, 1000	# store number to adjust coefficient
	mtc1	$t0, $f28
	cvt.s.w	$f28, $f28
	addi	$t0, $zero, 10		# store 0.5 in $f26 to aid in rounding
	mtc1	$t0, $f26
	cvt.s.w	$f26, $f26
	addi	$t0, $zero, 5
	mtc1	$t0, $f24
	cvt.s.w	$f24, $f24
	div.s	$f26, $f24, $f26
	
	mtc1	$a3, $f12		# store constant to add
	cvt.s.w	$f12, $f12
	
	### Convert coefficients to decimal values ###
	mtc1	$a0, $f6		# convert R coeff to fp
	cvt.s.w	$f6, $f6		#     convert from word
	div.s	$f6, $f6, $f28		#     divide by 10^3
	mtc1	$a1, $f8		# convert G coeff to fp
	cvt.s.w	$f8, $f8		#     convert from word
	div.s	$f8, $f8, $f28		#     divide by 10^3
	mtc1	$a2, $f10		# convert B coeff to fp
	cvt.s.w	$f10, $f10		#     convert from word
	div.s	$f10, $f10, $f28	#     divide by 10^3
	
	### Multiply by R, G, B values, add results ###
	mul.s	$f6, $f6, $f0		# R' = R_coeff*R
	mul.s	$f8, $f8, $f2		# G' = G_coeff*G
	mul.s	$f10, $f10, $f4		# B' = B_coeff*B
	add.s	$f6, $f6, $f8		# =  R' + G'
	add.s	$f6, $f6, $f10		# = (R' + G') + B'
	add.s	$f6, $f6, $f12		# = (R' + G' + B') + constant
	
	### Round to nearest int and return value ###
	add.s	$f6, $f6, $f26
	cvt.w.s	$f6, $f6
	mfc1	$v0, $f6
	
	lw	$ra, 4($sp)		# restore stack
	addi	$sp, $sp, 4
	jr	$ra			# return to caller
	
	
get_ycbcr_pixel_data:
	addi	$sp, $sp, -4		# make space on the stack so we can call subroutines
	sw	$ra, 4($sp)
	
	add	$a0, $s7, $zero		# y pixel data buffer
	add	$a1, $s6, $zero		# address of y color table
	jal	pixel
	
	lw	$ra, 4($sp)		# restore stack
	addi	$sp, $sp, 4
	jr $ra

pixel:
	addi	$sp, $sp, -12		# make space on the stack so we can call subroutines
	sw	$ra, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)
	
	add	$s1, $zero, $zero
	addi	$s2, $zero, 1
	jal pixel_loop
	
	lw	$s2, 12($sp)
	lw	$s1, 8($sp)
	lw	$ra, 4($sp)		# restore stack
	addi	$sp, $sp, 12
	jr $ra
	
pixel_loop:
	addi	$sp, $sp, -4		# make space on the stack so we can call subroutines
	sw	$ra, 4($sp)
	
	jal	pixel_row		# process next row of pixel data
	addi	$s1, $s1, 1		# increment counter
	
	lw	$ra, 4($sp)		# restore stack
	addi	$sp, $sp, 4
	
	beq	$s1, $s2, end_loop	# end loop after 8 iterations
	
pixel_row:
	addi	$sp, $sp, -4		# make space on the stack so we can call subroutines
	sw	$ra, 4($sp)
	
	### get row offset (row number * 4) ###
	#   each row is one word in memory (32 bits, 4 bits per pixel)  #
	addi	$t8, $zero, 4
	mult	$t8, $s1
	mflo	$t1
	
	### get pixel row ###
	add	$t0, $s0, $t1		# now holds starting address of row we're pointing to
	lw	$t9, ($t0)		# $t9 now holds data from the row we're pointing to
	
	# pixel 0
	andi	$a0, $t9, 15		# get data from position 0x--------x in the row
	jal	pixel_process
	
	#andi	$t0, $t9, 15		# get data from position 0x--------x in the row
	#mult	$t0, $t8		# use to calculate offset in color table (multiply by 4 because table is word-aligned)
	#mflo	$t0			
	#add	$t0, $t0, $s6		# add offset to beginning address of Y table
	#lw	$t0, ($t0)		# get data from Y table
	#add	$t1, $s7, $t1		# add pixel position offset to beginning of Y table
	#sw	$t0, ($t1)		# store pixel data
	
	# pixel 1
	# pixel 2
	# pixel 3
	# pixel 4
	# pixel 5
	# pixel 6
	# pixel 7
	
	lw	$ra, 4($sp)		# restore stack
	addi	$sp, $sp, 4
	
	jr	$ra
	
pixel_process:
	mult	$a0, $t8		# use to calculate offset in color table (multiply by 4 because table is word-aligned)
	mflo	$a0			
	
	add	$t2, $a0, $s6		# add offset to beginning address of Y table
	lw	$t0, ($t2)		# get data from Y table
	addi	$t0, $t0, -128		# shift range
	add	$t1, $s7, $t1		# add pixel position offset to beginning of Y pixel data
	sw	$t0, ($t1)		# store pixel data
	
	addi	$t2, $t2, 256		# get beginning address + offset of Cb table
	lw	$t0, ($t2)		# get data from Cb table
	addi	$t0, $t0, -128		# shift range
	addi	$t1, $t1, 256		# get beginning address + offset of Cb pixel data
	sw	$t0, ($t1)		# store pixel data
	
	addi	$t2, $t2, 256		# get beginning address + offset of Cb table
	lw	$t0, ($t2)		# get data from Cb table
	addi	$t0, $t0, -128		# shift range
	addi	$t1, $t1, 256		# get beginning address + offset of Cb pixel data
	sw	$t0, ($t1)		# store pixel data
	
	jr	$ra