  .data

# load 8 words into memory. Start at the address identified as numarray and print all 8 of the numbers out

numarray: .word 0
.word 1
.word 2
.word 3
.word 4
.word 5
.word 6
.word 7


.text

main:
  la  $s0, numarray   # starting location of data in memory
  addi  $t0, $zero, 8 # counter
  jal print_loop
  
  li  $v0, 10
  syscall

print:
  li  $v0, 1
  lw  $a0, ($s0)
  syscall

  addi  $s0, $s0, 4
  addi  $t0, $t0, -1
  beqz  $t0, end_loop
  
  j print

end_loop:
  jr  $ra