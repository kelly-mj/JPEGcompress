#   read_bmp.asm

	.data
buf:		.space	2	# space in mem so main contents of .bmp file are word-aligned
buffer:		.space	2000	# reserve space to store contents of .bmp file
fin:		.asciiz	"test_8x8_16-color_w.bmp"
fout:		.asciiz "testout.bmp"
br:		.asciiz "\n"

	.text
main:
	jal	read_bmp	# read bitmap image, get width and height
	jal	print_pixel_data
	j	exit

## VALUES USED ##
# $s0	address of the start of the actual image data (pixel data)
# $s1	bitmap image horizontal width
# $s2	bitmap image vertical height
# $s3	bits per pixel - "1" indicates monochrome image

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
	la	$s0, 44($t1)	# address of start of pixel data
	lw	$s1, 4($t1)	# store width  (4 bytes into the info header)
	lw	$s2, 8($t1)	# store height (8 bytes into the info header)
	lh	$s3, 14($t1)	# store bits per pixel
	
	jr $ra			# return to main program

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