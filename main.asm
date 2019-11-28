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
l0:             .byte	16	# luminance quantization table
l1:             .byte	11
l2:             .byte	10
l3:             .byte	16
l4:             .byte	24
l5:             .byte	40
l6:             .byte	51
l7:             .byte	61
l8:             .byte	12
l9:             .byte	12
l10:            .byte	14
l11:            .byte	19
l12:            .byte	26
l13:            .byte	58
l14:            .byte	60
l15:            .byte	55
l16:            .byte	14
l17:            .byte	13
l18:            .byte	16
l19:            .byte	24
l20:            .byte	40
l21:            .byte	57
l22:            .byte	69
l23:            .byte	56
l24:            .byte	14
l25:            .byte	17
l26:            .byte	22
l27:            .byte	29
l28:            .byte	51
l29:            .byte	87
l30:            .byte	80
l31:            .byte	62
l32:            .byte	18
l33:            .byte	22
l34:            .byte	37
l35:            .byte	56
l36:            .byte	68
l37:            .byte	109
l38:            .byte	103
l39:            .byte	77
l40:            .byte	24
l41:            .byte	35
l42:            .byte	55
l43:            .byte	64
l44:            .byte	81
l45:            .byte	104
l46:            .byte	113
l47:            .byte	92
l48:            .byte	49
l49:            .byte	64
l50:            .byte	78
l51:            .byte	87
l52:            .byte	103
l53:            .byte	121
l54:            .byte	120
l55:            .byte	101
l56:            .byte	72
l57:            .byte	92
l58:            .byte	95
l59:            .byte	98
l60:            .byte	112
l61:            .byte	100
l62:            .byte	103
l63:            .byte	99
c0:             .byte   17	# chrominance quantization table
c1:             .byte   18
c2:             .byte   24
c3:             .byte   47
c4:             .byte   99
c5:             .byte   99
c6:             .byte   99
c7:             .byte   99
c8:             .byte   18
c9:             .byte   21
c10:            .byte   26
c11:            .byte   66
c12:            .byte   99
c13:            .byte   99
c14:            .byte   99
c15:            .byte   99
c16:            .byte   24
c17:            .byte   26
c18:            .byte   56
c19:            .byte   99
c20:            .byte   99
c21:            .byte   99
c22:            .byte   99
c23:            .byte   99
c24:            .byte   47
c25:            .byte   66
c26:            .byte   99
c27:            .byte   99
c28:            .byte   99
c29:            .byte   99
c30:            .byte   99
c31:            .byte   99
c32:            .byte   99
c33:            .byte   99
c34:            .byte   99
c35:            .byte   99
c36:            .byte   99
c37:            .byte   99
c38:            .byte   99
c39:            .byte   99
c40:            .byte   99
c41:            .byte   99
c42:            .byte   99
c43:            .byte   99
c44:            .byte   99
c45:            .byte   99
c46:            .byte   99
c47:            .byte   99
c48:            .byte   99
c49:            .byte   99
c50:            .byte   99
c51:            .byte   99
c52:            .byte   99
c53:            .byte   99
c54:            .byte   99
c55:            .byte   99
c56:            .byte   99
c57:            .byte   99
c58:            .byte   99
c59:            .byte   99
c60:            .byte   99
c61:            .byte   99
c62:            .byte   99
c63:            .byte   99
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