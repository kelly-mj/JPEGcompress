#   read_bmp.asm

	.data
err:		.asciiz	"Error; program exiting.\n"
fin:		.asciiz	"test.bmp"
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
# $s2	file descriptor of original .bmp file

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
	li $v0, 4
	la $a0, buffer
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
