#	main.asm

	.data
buf:		.space	2	# space in mem so main contents of .bmp file are word-aligned
buffer:		.space	514	# reserve space to store contents of .bmp file
y_table:	.space	64	# reserve space to store Y color space data
cb_table:	.space	64	# reserve space to store Cb color space data
cr_table:	.space	64	# reserve space to store Cr color space data
y_pixel:	.space	256	# reserve space for shifted luminance data; each pixel gets one word of space
cb_pixel:	.space	256	# reserve space for shifted Cb chrominance data; each pixel gets one word of space
cr_pixel:	.space	256	# reserve space for shifted Cr chrominance data; each pixel gets one word of space
wip_pixel:	.space	256	# reserce space for pixels currently being processed; each pixel gets one word of space
quant_l:	.byte	16	# luminance quantization table
flag: 		.word 0		# Flag counter used to track memory spaces during RLE
	.byte	11
	.byte	10
        .byte	16
        .byte	24
        .byte	40
        .byte	51
        .byte	61
        .byte	12
        .byte	12
        .byte	14
        .byte	19
        .byte	26
        .byte	58
        .byte	60
        .byte	55
        .byte	14
        .byte	13
        .byte	16
        .byte	24
        .byte	40
        .byte	57
        .byte	69
        .byte	56
        .byte	14
        .byte	17
        .byte	22
        .byte	29
        .byte	51
        .byte	87
        .byte	80
        .byte	62
        .byte	18
        .byte	22
        .byte	37
        .byte	56
        .byte	68
        .byte	109
        .byte	103
        .byte	77
        .byte	24
        .byte	35
        .byte	55
        .byte	64
        .byte	81
        .byte	104
        .byte	113
        .byte	92
        .byte	49
        .byte	64
        .byte	78
        .byte	87
        .byte	103
        .byte	121
        .byte	120
        .byte	101
        .byte	72
        .byte	92
        .byte	95
        .byte	98
        .byte	112
        .byte	100
        .byte	103
        .byte	99
quant_c:	.byte   17	# chrominance quantization table
        .byte   18
        .byte   24
        .byte   47
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   18
        .byte   21
        .byte   26
        .byte   66
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   24
        .byte   26
        .byte   56
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   47
        .byte   66
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
        .byte   99
fin:		.asciiz	"test_8x8_16-color_bggw.bmp"
fout:		.asciiz "testout.bmp"
br:		.asciiz "\n"

	.text
main:
	# TODO: read in the file name from user input
	la	$a0, fin		# file to open
	# TODO: get compression ratio
	la	$a2, buffer		# buffer space address
	jal	read_bmp		# read bitmap image, get width and height
	
	# DONE: store color table data in y_table, cb_table, cr_table color spaces
	# convert RGB color space to YCbCr; store YCbCr data in the reserved "pixel" spaces in .data segment
	la	$a0, y_table
	la	$a1, y_pixel
	jal	convert_color_space
	
	### Compress Y portion of pixel data ###
	# TODO: Implement DCT transformation
	### FOR TESTING PURPOSES: I have copied the y_pixel data into the wip_pixel data block. ###
	la	$a0, y_pixel
	la	$a1, wip_pixel
	la	$a2, 64
	jal	copy
	
	# DONE: Implement matrix quantization
	la	$a0, wip_pixel		# load address of beginning of pixel block we wish to manipulate (manipulated data will overwrite existing data in this block)
	la	$a1, quant_l		# load address of beginning of quantization table (quant_l for manipulating Y (luminance data); quant_c for Cb, Cr (chrominance data))
	jal	quantize
	
	# DONE: Implement zig-zag scan; leave re-ordered data in wip_pixel
	la	$a0, wip_pixel
	la	$a1, buffer
	addi	$a1, $a1, 2		# align copy data location on word boundary (buffer is 2 bytes off)
	jal	zigzag
	
	# TODO: Implement run-length encoding
	# TODO: Implement entropy encoding
	
	### Compress Cb portion of pixel data ###
	# TODO: Implement DCT transformation
	### FOR TESTING PURPOSES: I have copied the y_pixel data into the wip_pixel data block. ###
	la	$a0, cb_pixel
	la	$a1, wip_pixel
	la	$a2, 64
	jal	copy
	
	# DONE: Implement matrix quantization
	la	$a0, wip_pixel		# load address of beginning of pixel block we wish to manipulate (manipulated data will overwrite existing data in this block)
	la	$a1, quant_c		# load address of beginning of quantization table (quant_l for manipulating Y (luminance data); quant_c for Cb, Cr (chrominance data))
	jal	quantize
	
	# DONE: Implement zig-zag scan; leave re-ordered data in wip_pixel
	la	$a0, wip_pixel
	la	$a1, buffer
	addi	$a1, $a1, 2		# align copy data location on word boundary (buffer is 2 bytes off)
	jal	zigzag
	
	# TODO: Implement run-length encoding
	# TODO: Implement entropy encoding
	
	### Compress Cr portion of pixel data ###
	# TODO: Implement DCT transformation
	### FOR TESTING PURPOSES: I have copied the y_pixel data into the wip_pixel data block. ###
	la	$a0, cr_pixel
	la	$a1, wip_pixel
	la	$a2, 64
	jal	copy
	
	# DONE: Implement matrix quantization
	la	$a0, wip_pixel		# load address of beginning of pixel block we wish to manipulate (manipulated data will overwrite existing data in this block)
	la	$a1, quant_c		# load address of beginning of quantization table (quant_l for manipulating Y (luminance data); quant_c for Cb, Cr (chrominance data))
	jal	quantize
	
	# DONE: Implement zig-zag scan; leave re-ordered data in wip_pixel
	la	$a0, wip_pixel
	la	$a1, buffer
	addi	$a1, $a1, 2		# align copy data location on word boundary (buffer is 2 bytes off)
	jal	zigzag
	
	# DONE: Implement run-length encoding
	move $s0, $a0			# Move contents of pixel-data to s0
    	addi $t0, $zero, 64 		# t0 is the counter variable
    	jal process
    	
    	li $v0, 10
    	syscall
    	
    
    	process:
    	bnez $s0, non_zero		# if nonzero, go to the function for handling non-zero entries
    	beqz $s0, zero			# If it is not a non-zero, must be zero
    	#lw $t5, 0x4($s0)		# Otherwise, the number is a zero and we need to store it and it's frequency (value precedes frequency, e.g. 1 2 0 0 0 => 1 2 0 3
    	#sw $s6, ($t5)
    	
    	# move s6 to a0 before doing jr $ra
    	beqz $t0, end
    	
   	
    	non_zero:			# Number is not a zero, increment counter by 1, increment s0 by 4, keep looping and store the current data
    	lw $t5, 0x4($s0) 		# Load current cell of s0 into t5
    	sw $s6, flag($t5)		# Store current cell (pixel data) of t5 into s6 -- Flag is a pointer to keep track of where we need to add new values in s6, and where to access in t5
    	addi $s6, $s6, 4		# Increment current cell for next value to be added into s6
    	addi flag, flag, 4		# Incremenet flag 
    	
    	addi $s0, $s0, 4		# Increment s0
    	addi $t0, $t0, -1		# Decrement
    	
    	j process
    	
    
    	zero:				# Current entry is a zero, we need to first store 0 to output, and then count number of succeeding zeroes (storing into the next cell of output)
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
    	
    
    	end:
    	move $a0, $s6 			# Move contents of RLE output to a0
    	jr $ra
	
	# TODO: Implement huffman encoding

	j	exit
