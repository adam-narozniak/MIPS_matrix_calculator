.data
greeting: 	.asciiz "It's a matrix calculator!\n"
file_path:	.asciiz "/home/adam/Desktop/MIPS/code/data.txt"
error_open:	.asciiz "Error: opening file\nCheck file path!\n"
error_format:	.asciiz "Error: wrong format of the data in the file\nOperation not specified\n"
error_sizes:	.asciiz "Error: not correct sizes of matrices to perform specified operation\nCheck first line of the file\n"
endl:		.asciiz "\n"
if_testing:	.asciiz "Loop testing\n"
plus:		.asciiz "+\n"
minus:		.asciiz "-"
val1:		.word 2
val2:		.word 1
buf:		.space 1024
.text
#$s0 file descriptor
#$s1 m1
#$s2 n1
#$s3 m2
#$s4 n2
#$s5 current buff address
#$s6 operation type: 
# 1 '+',  2 "-', 3 '*', 4 'det'
#$s7 
.globl main
main:
	li $v0,4		#printing greetings
	la $a0,greeting
	syscall
open_f:	
	li $v0,13		#open file
	la $a0,file_path
	li $a1,0		#read-only flag
	syscall
	
	move $s0, $v0			#file descriptor to $s0
	blt $s0,$zero,end_err_open	#branch if file not opended properly
	
read_f:
	li $v0,14
	move $a0, $s0		#$a0 = file descriptor
	la $a1, buf		#$a1 = buff adress
	li $a2, 1024		#$a2 = max number of char to read(buff size)
	syscall
	
	move $t0, $v0		#storing number of char read
	li $v0,1		#printing number of char read
	move $a0, $t0
	syscall	
	jal print_endl
		
	#getting type of operation to execute
	la $s5,buf		#current buf address
	jal get_operation_type
	
	
m1_n1:	#first matrix read
	jal get_m_n
	move $s1,$s7		#m1 - first matrix
	jal get_m_n
	move $s2,$s7		#n1 - first matrix
	
	
	
	addiu $sp,$sp,-8 	#space for two adresses of dynamically allocated memory for matrices - local(in main) variables
	
matrix1:	#this is each call routine
	mul $t0,$s1,$s2		#$t0= n1*m1 number of elem in matrix
	addiu $sp,$sp,-4		#space for $t0 (argument of the fuction), which contains m*n
	sw $t0,($sp)		#store $t0
	# you should specify this each time 
	la $t0, 8($sp)		#store address of space to write address of memory
	addiu $sp,$sp,-4
	sw $t0,($sp)
	jal get_matrix
	addiu $sp,$sp,8 	#deaclocating space for arg of function
	
m2_n2:	#second matrix read
	jal get_m_n
	move $s3,$s7		#m2 - second matrix
	jal get_m_n
	move $s4,$s7		#n2 - second matrix
matrix2:	#this is each call routine
	mul $t0,$s3,$s4		#$t0= n*m number of elem in matrix
	addiu $sp,$sp,-4		#space for $t0 (argument of the fuction), which contains m*n
	sw $t0,($sp)		#store $t0
	# you should specify this each time 
	la $t0, 4($sp)		#store address of space to write address of memory
	addiu $sp,$sp,-4
	sw $t0,($sp)
	jal get_matrix
	addiu $sp,$sp,8 	#deaclocating space for arg of function
	
	
	#------------------------
	#la $t0,buff-redundant	#testing buffor output
	#lb $t1, buff
	#subi $t1,$t1,'0'
	li $v0,1		#printing m1 n1
	move $a0, $s1
	syscall
	jal print_endl
	li $v0,1
	move $a0, $s2
	syscall
	#------------------
	#fuction print_matrix(int* matrix_begin, int m, int n):
	#addiu $sp,$sp,-4
	
	bne $s6,1, c2_cond		#if $s6 != 1 check 
	j c1_body
c2_cond:
	bne $s6,2, c3_cond		#if else $s6 != 2
	j c2_body
c3_cond:
	bne $s6,3, c4_cond		#if else $s6 != 3
	j c3_body
c4_cond:				#else (no error can accur, taken care earlier) so $s6 == 4
	j c4_body 

#here in loop add sub $t0 loop counter $t7 $8 respectively adddress of matrix1 and 2
	lw $t7, 8($sp)
	lw $t8, 4($sp)
c1_body:#check whether it is possible to add
	jal check_add_sub
	
add_loop:
	beqz $t0,add_end
	mulo $t0, $s1, $s2
	mulo $t1,$t0,4			#multiplying by 4 to get number of words to store ints
	li $v0, 9			#allocating memory on heap
	move $a0, $t1			#loading 4*m*n
	move $t9,$v0			#address of alocated memory
	
	#$t5, $t6 temp value of matrix holders
	lw $t5, ($t7)
	lw $t6, ($t8)
	# $t4 is sum/product of subtraction
	addu $t4,$t5,$t6
	sw $t4, ($t9)
	addiu $t9,$t9,4
	addiu $t0,$t0,-1
add_end:
	j cond_end
c2_body:
	jal check_add_sub
sub_loop:
	beqz $t0,add_end
	mulo $t0, $s1, $s2
	mulo $t1,$t0,4			#multiplying by 4 to get number of words to store ints
	li $v0, 9			#allocating memory on heap
	move $a0, $t1			#loading 4*m*n
	move $t9,$v0			#address of alocated memory
	
	#$t5, $t6 temp value of matrix holders
	lw $t5, ($t7)
	lw $t6, ($t8)
	# $t4 is sum/product of subtraction
	subu $t4,$t5,$t6
	sw $t4,($t9)
	addiu $t9,$t9,4
	addiu $t0,$t0,-1
sub_end:
	j cond_end
c3_body:
	jal check_mult	
c4_body:
	jal check_det
cond_end:

close_f:
	li $v0,16		#closing file
	move $a0, $s0		#$a0 = file descriptor
	syscall
	j end
end_err_open:
	li $v0,4		#printing error message
	la $a0,error_open
	syscall
	j end
err_wrong_format:
	li $v0,4		#printing error message
	la $a0,error_format
	syscall
	j end
error_m_n:
	li $v0,4		#printing error message
	la $a0,error_sizes
	syscall
	j end
	
		
end:	li $v0,10		#exit
	syscall

	
#---------------------------------------------------------
#function to get matrx size
#$t0 holds result during counting and later on moves it to $s2 
get_m_n:

	#la $t9, buf		#load buf address
	#add $t9,$t9,$s6
	#addiu $s6,$s6,1
				#first char
				
	lbu $t0, ($s5)		#load first char
	addiu $s5,$s5,1
	subi $t0,$t0,'0'	#convert to int
	
	#move $t8,$zero		
new_char:
	#addi $s6,$s6,1	
	#addiu $t8,$t8,1		#loop counter
	#mulo $t7,$t7, $t8	#
	#addiu $t9,$t9,1		#next bait in buf
	#lb $t1, 4(buff)
	lbu $t1,($s5)
	addiu $s5,$s5,1
	beqz $t1,end_int	#check if there are more to baits to read
	beq $t1,'\n',end_int
	beq $t1,' ',end_int
	subi $t1,$t1,'0'
	mulo $t0,$t0,10
	add $t0,$t0,$t1
	j new_char
end_int:	
	move $s7, $t0
	move $t0,$zero
	move $t1,$zero
	jr $ra
		
#---------------------------------------------------------
#function: int str_to_int(buf_adress, dynamic_memory_adress)
#return value is stored in 
#
get_matrix:
	addiu $sp,$sp,-4		#taking care of return adress and frame pointer 
	sw $ra,0($sp)			#accualy for convention cause I don't use it recursively nor need this two things
	addiu $sp,$sp,-4
	sw $fp,0($sp)
	move $fp,$sp
	#addi $sp,$sp,-4			#store m*n as local variable, since it is argument of the function
	
	
	#addi $sp,$sp,-4			#place for local current addres of allocated memory for matrix
	
	
	lw $t8,12($fp)			#$t8, loop counter, starts at m*n and goes to 0 ten breaks loop
	mulo $t7,$t8,4			#multiplying by 4 to get number of words to store ints
	li $v0, 9			#allocating memory on heap
	move $a0, $t7			#loading 4*m*n
	syscall
	sw $v0,8($fp)			#storing address of memory allocated for matrix
					#in adrress given as *address
	move $t9,$v0			#storing address of memory allocated for matrix, as a place for current address
	
#-----------------------------------------
#reading matrix	
whole_loop:		#loop to get all numbers,
			#whereas the lower ones are to get sigle number
			#$t9 as place for local current addres of allocated memory for matrix
			#$t8, loop counter, starts at m*n and goes to 0 ten breaks loop
	beqz $t8,done
	subiu $t8,$t8,1
			
			
	lbu $t0, ($s5)			#load first char, $s5 current buff adress
	addiu $s5,$s5,1
	beq $t0,'-', negative		#negative number - >jump
	subi $t0,$t0,'0'		#convert to int
pos_loop:
	lbu $t1,($s5)
	addiu $s5,$s5,1
	beqz $t1,end_int_pos		#check if there are more to baits to read
	beq $t1,'\n',end_int_pos
	beq $t1,' ',end_int_pos
	subi $t1,$t1,'0'
	mulo $t0,$t0,10
	add $t0,$t0,$t1
	j pos_loop
end_int_pos:
	
	sw $t0,($t9)
	addiu $t9,$t9,4
	move $t0,$zero
	move $t1,$zero
	j whole_loop
	
	
negative:
	lbu $t0, ($s5)			#start reading digits
	addiu $s5,$s5,1
	subi $t0,$t0,'0'		#convert to int
neg_loop:	
	lbu $t1,($s5)
	addiu $s5,$s5,1
	beqz $t1,end_int_neg		#check if there are more to baits to read
	beq $t1,'\n',end_int_neg
	beq $t1,' ',end_int_neg
	subi $t1,$t1,'0'
	mulo $t0,$t0,10
	add $t0,$t0,$t1
	j neg_loop
end_int_neg:
	mul $t0,$t0, -1			#getting negative
	sw $t0,($t9)
	addiu $t9,$t9,4
	move $t0,$zero
	move $t1,$zero
	j whole_loop
	
	
done:	
	addiu $sp,$sp,8		#dealocting space for $ra and $fp
	jr $ra
	

	
#	li $v0,1		#printing file descriptor
#	move $a0, $t0
#	syscall
#----------------------------------
print_endl:
	li $v0,4		#printing endl
	la $a0, endl
	syscall
	jr $ra
	
#function get operation typ operation_type(int * buf_address) where $s5 have buf address
get_operation_type:
	addiu $sp,$sp,-4
	sw $ra,($sp)
	lbu $t0, ($s5)			#load first char
	addiu $s5,$s5,1
	beq $t0, '+', addition
	beq $t0, '-', subtraction
	beq $t0, '*', multiplication
	beq $t0 'd', determinant
	j err_wrong_format
addition:
	li $s6, 1
	j op_end
subtraction:
	li $s6, 2
	j op_end
multiplication:
	li $s6, 3
	j op_end
determinant:
	li $s6, 4		#'d' already read, but 'e' 't'
	addiu $s5,$s5,2		
	j op_end
	
op_end:				
	addiu $s5,$s5,1		#moving after '\n'
	
	
	jr $ra
#fuction print_matrix(int* matrix_begin, int m, int n):
#

check_add_sub:
	bne $s1,$s2,error_m_n
	bne $s3,$s4,error_m_n
	jr $ra
check_mult:
	bne $s2,$s3,error_m_n
	jr $ra
check_det:
	bne $s1,$s2,error_m_n
	jr $ra
print_matrix:	
	
	