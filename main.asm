#	main.asm

	.data
buf:		.space	2	# space in mem so main contents of .bmp file are word-aligned
buffer:		.space	514	# reserve space to store contents of .bmp file
y_table:	.space	64	# reserve space to store Y color space data
cb_table:	.space	64	# reserve space to store Cb color space data
cr_table:	.space	64	# reserve space to store Cr color space data
y_pixel:	.space	256	# reserve space for shifted luminance data
cb_pixel:	.space	256	# reserve space for shifted Cb chrominance data
cr_pixel:	.space	256	# reserve space for shifted Cr chrominance data
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
	la	$a0, y_table
	la	$a1, y_pixel
	jal	convert_color_space	# convert RGB color space to YCbCr
	
	# TODO: Implement DCT transformation
	# TODO: Implement matrix quantization
	# TODO: Implement run-length encoding
	# TODO: Implement entropy encoding

	j	exit