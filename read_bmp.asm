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
	
	### testing jump ###
	#addi $sp, $sp, -4
	#sw $ra, 4($sp)
	#jal test
	#lw $ra, 4($sp)
	#addi $sp, $sp, 4
	
	jr $ra			# return to main program

# ARGUMENTS: 
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
ccs_pixel:
	addi	$sp, $sp, -4		# make space on the stack so we can call subroutines
	sw	$ra, 4($sp)
	add	$t4, $zero, $a0		# store data to free up $a0
	addi	$t5, $s0, -64		# store start of color table
	
	### read value at each pixel in the half-word ###
	andi	$t0, $t4, 15		# extract rightmost pixel data (0x-------x)
	sll	$t0, $t0, 2		# multiply that value by 4
	add	$a0, $t5, $t0		# add to pointer to start of color table. Now points to corresponding value in the color table for our pixel.
	lw	$a0, ($a0)		# load data from the color table
	jal	transform_rgb_ybr	# call transform
	#andi	$t1, $a0, 240
	#srl	$t1, $t1, 4
	#andi	$t2, $a0, 3840
	#srl	$t2, $t2, 8
	#andi	$t3, $a0, 61440
	#srl	$t3, $t3, 12
	lw	$ra, 4($sp)	# return stack to original state
	addi	$sp, $sp, 4
	jr	$ra

# ARGUMENTS: $a0 = data from entry in color table
# RETURNS:   none
transform_rgb_ybr:
	and $t0, $a0, 255	# get R component
	and $t1, $a0, 65280	# get G component
	srl $t1, $t1, 8
	srl $a0, $a0, 8		# get B component
	and $t2, $a0, 255
		# calculate E_R = R/255
		# calculate E_G = G/255
		# calculate E_B = B/255
	### calculate E_Y  =  0.299E_R + 0.587E_G + 0.114E_B ###
	### calculate E_Cb = -0.169E_R - 0.331E_G + 0.500E_B ###
	### calulcate E_Cr =  0.500E_R - 0.419E_G - 0.081E_B ###
		# calculate Y  = 219*E_Y  + 16
		# calculate Cb = 224*E_Cb + 128
		# calculate Cr = 224*E_Cr + 128
	### Y  = 16  +  65.481E_R + 128.553E_G +  24.966E_B ###
	### Cb = 128 -  37.856E_R +  74.144E_G + 112.000E_B ###
	### Cr = 128 + 112.000E_R +  93.856E_G +  18.144E_B ###
	
	### Y  = 16  + 0.256788*R + 0.504129*G + 0.097905*B ###
	### Cb = 128 - 0.148454*R + 0.290760*G + 0.439216*B ###
	### Cr = 128 + 0.439216*R + 0.368063*G + 0.071152*B ###
	jr $ra
	
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
