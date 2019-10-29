#   read_bmp.asm

	.data
err:		.asciiz	"Error; program exiting.\n"
fin:		.asciiz	"test_8x8_checkered.bmp"
fout:		.asciiz "testout.bmp"
br:		.asciiz "\n"
buffer:		.space	2000	# reserve space to read from file
header:		.space	14	# file header - signature, filesize, reserved, dataOffset
infoHeader: 	.space	40	# bitmap info header
width:		.space	4	# horizontal width of image
height:		.space	4	# vertical height of image

	.text
main:
	jal	read_bmp
	j	exit

## VALUES USED ##
# $s0	file descriptor of original .bmp file
# $s1	bitmap image horizontal width
# $s2	bitmap image vertical height

read_bmp:
	### open original bmp file ###
	li	$v0, 13		# for file open
	la	$a0, fin	# file to open
	li	$a1, 0		# read-only
	li	$a2, 0		# ignore mode
	syscall
	move $s2, $v0		# save file descriptor

	### read from file ###
	li $v0, 14		# for file read
	la $a0, ($s2)		# file descriptor
	la $a1, buffer		# address of input buffer
	li $a2, 2000		# max num char to read
	syscall

	### close file ###
	li	$v0, 16		# for file close
	la	$a0, ($s2)	# load file descriptor
	syscall
	
	### extract header info ###
	la $t0, buffer		# get address of .bmp file data we just read
	la $t1, 14($t0)		# get address of info header (starts 14 bytes into the .bmp file data)
	lw $s1, 4($t1)		# get width  (4 bytes into the info header)
	lw $s2, 8($t1)		# get height (8 bytes into the info header)
	
	la $a0, ($s1)
	li $v0, 1
	syscall
	
	la $a0, ($s2)
	li $v0, 1
	syscall
	
	jr $ra

exit_err:
	li	$v0, 4
	la	$a0, err
	syscall
	j	exit

exit:
	li $v0, 10
	syscall

printBreak:
	li $v0, 4
	la $a0, br
	syscall
	jr $ra

checkErr:
	addi	$t0, $v0, 1
	beqz	$t0, exit_err
	jr $ra
