#Inputs (double format): v,u,N,C(u),C(v),x
#Output(double format) in $f26
#Currently has a print function that needs to be removed

.data
#substitutes
PI: .double 3.141593
V: .double 1
N: .double 2
U: .double 1
one: .double 1
two: .double 2
X: .double 1
Cu: .double 1
Cv: .double 1

.text
.globl DCT, result, innerMult

DCT:
#initializing i variable
li $s4, 0
mtc1 $s4, $f26
cvt.d.w $f26, $f26

#storing N
la $s3, N
l.d $f18, 0($s3)
cvt.w.d $f18, $f18

#comparator N
mfc1 $s3, $f18

#Outer Summation calculation
outerSummation:

#Initializing j variable
li $s1, 0
mtc1 $s1, $f24
cvt.d.w $f24, $f24
jal innerSummation1

add.d $f26, $f24, $f26
addi $s4, $s4, 1
beq $s4, $s3, result
j outerSummation

#Inner summation calculation
innerSummation1:
addi $s5, $ra, 0
innerSummation2:
mtc1 $s1, $f0
cvt.d.w $f0, $f0
jal innerMult
add.d $f24, $f22, $f24
addi $s1, $s1, 1
bne  $s3, $s1, innerSummation2
addi $ra, $s5, 0
jr $ra

innerMult:
addi $s2, $ra, 0
la $t3, N
l.d $f6, 0($t3)
la $t0, PI
l.d $f2, 0($t0)
la $t1, V
l.d $f4, 0($t1)
la $t4, one
l.d $f8, 0($t4)
la $t5, two
l.d $f10, 0($t5)

mul.d $f0, $f10, $f0
add.d $f0, $f8, $f0
mul.d $f0, $f0, $f4
mul.d $f0, $f0, $f2
div.d $f0, $f0, $f10
div.d $f0, $f0, $f6

jal cos
mov.d $f14, $f22

la $t0, PI
l.d $f2, 0($t0)
la $t3, N
l.d $f6, 0($t3)
la $t4, one
l.d $f8, 0($t4)
la $t5, two
l.d $f10, 0($t5)
mtc1 $s4, $f0
cvt.d.w $f0, $f0
la $t7, U
l.d $f12, 0($t7)

mul.d $f0, $f10, $f0
add.d $f0, $f8, $f0
mul.d $f0, $f0, $f12
mul.d $f0, $f0, $f2
div.d $f0, $f0, $f10
div.d $f0, $f0, $f6

jal cos
mul.d $f22, $f22, $f14

la $t8, X
l.d $f16, 0($t8)
mul.d $f22, $f22, $f16

addi $ra, $s2, 0
jr $ra

result:
la $s6, Cu
l.d $f28, 0($s6)
la $s6, Cv
l.d $f0, 0($s6)
la $s6, two
l.d $f2, 0($s6)
la $s6, N
l.d $f4, 0($s6)

mul.d $f26, $f26, $f28
mul.d $f26, $f26, $f0
mul.d $f26, $f26, $f2
div.d $f26, $f26, $f4

li $v0, 3
mov.d $f12, $f26
syscall

li $v0, 10
syscall
