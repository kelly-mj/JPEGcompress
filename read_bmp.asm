#   read_bmp.asm

.globl	read_bmp

## VALUES USED ##
# $s0	address of the start of the actual image data (pixel data)
# $s1	bitmap image horizontal width
# $s2	bitmap image vertical height

# ARGUMENTS: $a0 = name of file
#            $a1 = compression ratio
# RETURNS:   $s0 = address of start of image data in bitmap file
#	     $s1 = bitmap image width
#	     $s2 = bitmap image height
read_bmp:
	add	$t9, $zero, $a2	# get address of buffer

	### open original bmp file ###
	li	$v0, 13		# for file open
	li	$a1, 0		# read-only
	li	$a2, 0		# ignore mode
	syscall
	move	$t0, $v0	# save file descriptor
	
	### read from file ###
	li	$v0, 14		# for file read
	la	$a0, ($t0)	# file descriptor
	add	$a1, $t9, $zero	# address of input buffer (puts data in buffer)
	li	$a2, 2000	# max num char to read
	syscall

	### close file ###
	li	$v0, 16		# for file close
	la	$a0, ($t0)	# load file descriptor
	syscall
	
	### extract header info ###
	la	$t1, 14($t9)	# get address of info header (starts 14 bytes into the .bmp file data)
	la	$s0, 100($t1)	# address of start of pixel data
	addi	$s0, $s0, 4	# address of start of pixel data - corrected
	lw	$s1, 4($t1)	# store width  (4 bytes into the info header)
	lw	$s2, 8($t1)	# store height (8 bytes into the info header)
	#lh	$s3, 14($t1)	# store bits per pixel
	
	jr $ra			# return to main program