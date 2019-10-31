#   read_bmp.asm

	.data
buf:		.space	2	# space in mem so main contents of .bmp file are word-aligned
buffer:		.space	2000	# reserve space to store contents of .bmp file
ybr:		.space	2000	# reserve space to store YCbCr color space data
fin:		.asciiz	"test_8x8_16-color_wb.bmp"
fout:		.asciiz "testout.bmp"
br:		.asciiz "\n"

	.text
main:
	jal	read_bmp		# read bitmap image, get width and height
	jal	convert_color_space	# convert RGB color space to YCbCr
	#jal	print_pixel_data
	j	exit

## VALUES USED ##
# $s0	address of the start of the actual image data (pixel data)
# $s1	bitmap image horizontal width
# $s2	bitmap image vertical height
# $s3	bits per pixel - "1" indicates monochrome image <-- MIGHT JUST WANT TO ASSUME 16-BIT

# ARGUMENTS: $a0 = name of file
#            $a1 = compression ratio
# RETURNS:   $s0 = address of start of image data in bitmap file
#	     $s1 = bitmap image width
#	     $s2 = bitmap image height
read_bmp:
	### open original bmp file ###
	li	$v0, 13		# for file open
	la	$a0, fin	# file to open
	li	$a1, 0		# read-only
	li	$a2, 0		# ignore mode
	syscall
	move	$t0, $v0	# save file descriptor
	
	### read from file ###
	li	$v0, 14		# for file read
	la	$a0, ($t0)	# file descriptor
	la	$a1, buffer	# address of input buffer (puts data in buffer)
	li	$a2, 2000	# max num char to read
	syscall

	### close file ###
	li	$v0, 16		# for file close
	la	$a0, ($t0)	# load file descriptor
	syscall
	
	### extract header info ###
	la	$t0, buffer	# get address of .bmp file data we just read
	la	$t1, 14($t0)	# get address of info header (starts 14 bytes into the .bmp file data)
	la	$s0, 100($t1)	# address of start of pixel data
	addi	$s0, $s0, 4	# address of start of pixel data - corrected
	lw	$s1, 4($t1)	# store width  (4 bytes into the info header)
	lw	$s2, 8($t1)	# store height (8 bytes into the info header)
	lh	$s3, 14($t1)	# store bits per pixel
	
	jr $ra			# return to main program

# ARGUMENTS: none
# RETURNS:   none
convert_color_space:
	addi	$sp, $sp, -4	# make space on the stack so we can call subroutines
	sw	$ra, 4($sp)
	
	lhu	$a0, ($s0)	# loads 0x----xxxx data from word
	jal	ccs_pixel
	
	#lhu	$t1, 2($s0)	# loads 0xxxxx---- data from word
	
	lw	$ra, 4($sp)	# return stack to original state
	addi	$sp, $sp, 4
	jr $ra

# ARGUMENTS: $a0 = half-word of pixel data
# RETURNS:   none
# ALTERS:    $s4, $s5
ccs_pixel:
	addi	$sp, $sp, -4		# make space on the stack so we can call subroutines
	sw	$ra, 4($sp)
	add	$s4, $zero, $a0		# pixel data in $s4 to free up $a0
	addi	$s5, $s0, -64		# store start of color table in $s5
	
	### read value at each pixel in the half-word ###
	andi	$t0, $s4, 15		# extract rightmost pixel data (0x-------x)
	sll	$t0, $t0, 2		# multiply that value by 4
	add	$a0, $s5, $t0		# add to pointer to start of color table. Now points to corresponding value in the color table for our pixel.
	lw	$a0, ($a0)		# load data from the color table
	jal	transform_rgb_ybr	# call transform
	#andi	$t1, $a0, 240
	#srl	$t1, $t1, 4
	#andi	$t2, $a0, 3840
	#srl	$t2, $t2, 8
	#andi	$t3, $a0, 61440
	#srl	$t3, $t3, 12
	lw	$ra, 4($sp)		# return stack to original state
	addi	$sp, $sp, 4
	jr	$ra

# ARGUMENTS: $a0 = data from entry in color table
# RETURNS:   none
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
	
	### Y  = 16  + 0.256788*R + 0.504129*G + 0.097905*B ###
	addi	$a0, $zero, 256788	# R coefficient, *10^6
	addi	$a1, $zero, 504129	# G coefficient, *10^6
	addi	$a2, $zero,  97905	# B coefficient, *10^6
	addi	$a3, $zero,     16	# Constant to add
	jal	rgb_ybr_equ
	add	$s7, $zero, $v0
	### Cb = 128 - 0.148454*R - 0.290760*G + 0.439216*B ###
	addi	$a0, $zero, -148454	# R coefficient, *10^6
	addi	$a1, $zero, -290760	# G coefficient, *10^6
	addi	$a2, $zero, 439216	# B coefficient, *10^6
	addi	$a3, $zero,    128	# Constant to add
	jal	rgb_ybr_equ
	add	$t8, $zero, $v0
	### Cr = 128 + 0.439216*R - 0.368063*G - 0.071152*B ###
	addi	$a0, $zero, 439216	# R coefficient, *10^6
	addi	$a1, $zero, -368063	# G coefficient, *10^6
	addi	$a2, $zero, -71152	# B coefficient, *10^6
	addi	$a3, $zero,    128	# Constant to add
	jal	rgb_ybr_equ
	add	$t9, $zero, $v0
	
	lw	$ra, 4($sp)		# return stack to original state
	addi	$sp, $sp, 4
	jr $ra				# return to caller

# ARGUMENTS: $a0=R_coeff, $a1=G_coeff, $a2=B_coeff, $a3=constant, $f0=R_value, $f2=G_value, $f4=B_value
# RETURNS  : $v0 = equation result rounded to the nearest integer
rgb_ybr_equ:
	addi	$sp, $sp, -4		# make space on the stack so we can call subroutines
	sw	$ra, 4($sp)
	
	addi	$t0, $zero, 1000000	# store number to adjust coefficient
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
	div.s	$f6, $f6, $f28		#     divide by 10^6
	mtc1	$a1, $f8		# convert G coeff to fp
	cvt.s.w	$f8, $f8		#     convert from word
	div.s	$f8, $f8, $f28		#     divide by 10^6
	mtc1	$a2, $f10		# convert B coeff to fp
	cvt.s.w	$f10, $f10		#     convert from word
	div.s	$f10, $f10, $f28	#     divide by 10^6
	
	### Multiply by R, G, B values, add results ###
	mul.s	$f6, $f6, $f0		# R' = R_coeff*R
	mul.s	$f8, $f8, $f2		# G' = G_coeff*G
	mul.s	$f10, $f10, $f4		# B' = B_coeff*B
	add.s	$f6, $f6, $f8		# =  R' + G'
	add.s	$f6, $f6, $f10		# = (R' + G') + B'
	add.s	$f6, $f6, $f12		# = (R' + B' + G') + constant
	
	### Round to nearest int and return value ###
	add.s	$f6, $f6, $f26
	cvt.w.s	$f6, $f6
	mfc1	$v0, $f6
	
	lw	$ra, 4($sp)		# restore stack
	addi	$sp, $sp, 4
	jr	$ra			# return to caller
			
print_pixel_data:
	subi	$t0, $s0, 4
	j	ppd_loop
	
ppd_loop:
	addi	$t0, $t0, 4
	lw	$t1, ($t0)
	la	$a0, ($t1)
	li	$v0, 34
	syscall
	j	ppd_loop

exit:
	li	$v0, 10
	syscall

printBreak:
	li	$v0, 4
	la	$a0, br
	syscall
	jr $ra
