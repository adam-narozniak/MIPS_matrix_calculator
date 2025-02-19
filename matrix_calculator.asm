.data
greeting: 	.asciiz "It's a matrix calculator!\n\n"
file_path:	.asciiz "/home/adam/Desktop/MIPS/code/data3.txt"
error_open:	.asciiz "Error: opening file\nCheck file path!\n"
error_format:	.asciiz "Error: wrong format of the data in the file\nOperation not specified\n"
error_sizes:	.asciiz "Error: not correct sizes of matrices to perform specified operation\nCheck first line of the file\n"
buf:		.space 1024
#$s0 file descriptor
#$s1 m1
#$s2 n1
#$s3 m2
#$s4 n2
#$s5 current buf address
#$s6 operation type: 
# 1 '+',  2 "-', 3 '*', 4 'det'
.text
.globl main
main:
	li $v0,4			#printing greetings
	la $a0,greeting
	syscall
#OPEN FILE
	li $v0,13			#open file
	la $a0,file_path
	li $a1,0			#read-only flag
	syscall
	move $s0, $v0			#file descriptor to $s0
	blt $s0,$zero,end_err_open	#branch if file not opended properly
#READ FILE
	li $v0,14
	move $a0, $s0			#$a0 = file descriptor
	la $a1, buf			#$a1 = buf adress
	li $a2, 1024			#$a2 = max number of char to read(buf size)
	syscall	
#GET TYPE OF OPPERATION TO EXECUTE
	la $s5,buf			#current buf address
	jal get_operation_type
#SET FP IN MAIN TO GET EASY ACCESS TO LOCAL VARIABLE
	move $fp,$sp
	addiu $sp,$sp,-4		#space for two local variables(in main) m1*n1 and m2*n2
	addiu $sp,$sp,-8 		#space for two adresses of dynamically allocated memory for matrices
#GET FIRST MATRIX'S SIZE
	jal get_m_n
	move $s1,$v0			#m1 - first matrix
	move $s2,$v1			#n1 - first matrix
#GET FIRST MATRIX
	mul $t0,$s1,$s2			#$t0= n1*m1 number of elem in matrix
	sw $t0,($fp)			#storing m1*n1 in on stack as local variable in main							
	addiu $sp,$sp,-4		#agruments for functin get_matrix
	sw $t0,($sp)			#put on stack m1*n1
	# you should specify this each time !!!!
	la $t0,-8($fp)			#address where to store matrix1 address
	addiu $sp,$sp,-4
	sw $t0,($sp)			
	jal get_matrix
	addiu $sp,$sp,8 		#deaclocating space for args of get_matrix
#GET SECOND MATRIX'S SIZE
	jal get_m_n
	move $s3,$v0			#m2 - second matrix
	move $s4,$v1			#n2 - second matrix
#GET SECOND MATRIX
	mul $t0,$s3,$s4			#$t0= n2*m2 number of elem in matrix
	sw $t0,-4($fp)			#storing m2*n2 in on stack as local variable in main	
	addiu $sp,$sp,-4		#agruments for functin get_matrix
	sw $t0,($sp)			#put on stack m1*n1
	# you should specify this each time !!!!
	la $t0,-12($fp)			#address where to store matrix1 address
	addiu $sp,$sp,-4
	sw $t0,($sp)
	jal get_matrix
	addiu $sp,$sp,8 		#deaclocating space for args of get_matrix
	
#CONVENTION HERE	
#$t0 loop counter i=m*n
#$t7 present adddress of matrix1
#$t8 present address of matrix2
	lw $t7, -8($fp)
	lw $t8, -12($fp)
	addiu $sp,$sp,-4		#space for address of allocated memory for matrix
#$s6 holds type of opperation see description at the begging of the file
	bne $s6,1, c2_cond		#if $s6 != 1 
	j c1_body
c2_cond:
	bne $s6,2, c3_cond		#if else $s6 != 2
	j c2_body
c3_cond:
	bne $s6,3, c4_cond		#if else $s6 != 3
	j c3_body
c4_cond:				#else (no error can accur, taken care earlier) so $s6 == 4
	j c4_body 


c1_body:
	#check whether it is possible to add
	bne $s1,$s3,error_m_n		#if m1 !=m2 goto error_m_n
	bne $s2,$s4,error_m_n		#if n1 != n2 goto error_m_n

	lw $t0,($fp)			#load m1*n1 (it is equal to m2*n2) = size of new matrix in words
	sll $t1,$t0,2			#multiplying by 4 to get number of bytes 
	#allocating memory on heap
	li $v0, 9			#$v0 = 9; sbrk (allocate heap memory)
	move $a0, $t1			#specyfing size of memory to allocate 4*m*n
	syscall
	move $t9,$v0			#$t9 address of alocated memory
	sw $t9,-16($fp)			#save address of alocated memory
	addiu $sp,$sp,-4		#put on stack sizes of matrix to display(m,n); pritn_matrix arguments
	sw $s1,($sp)			
	addiu $sp,$sp, -4
	sw $s2,($sp)
#$t0 loop counter i = m*n
#$t7 present adddress of matrix1
#$t8 present address of matrix2		
add_loop:
	lw $t5, ($t7)			#$t5 = matrix1[i]
	lw $t6, ($t8)			#t6 = matrix2[i]
	addu $t4,$t5,$t6		#$t4 = matrix1[i] + matrix2[i]; 
	sw $t4, ($t9)			#save $t4 under address of new matrix
	addiu $t9,$t9,4			#go to the next word of new matrix (change address)
	addiu $t7,$t7,4			#go to the next word of matrix 1 (change address)
	addiu $t8,$t8,4			#go to the next word of matrix 2 (change address)
	addiu $t0,$t0,-1		#i--
	beqz $t0,cond_end		#if i == 0 goto cond_end
	j add_loop
c2_body:
	#check whether it is possible to subtract
	bne $s1,$s3,error_m_n		#if m1 !=m2 goto error_m_n
	bne $s2,$s4,error_m_n		#if n1 != n2 goto error_m_n
	
	lw $t0,($fp)			#load m1*n1 (it is equal to m2*n2) = size of new matrix in words
	sll $t1,$t0,2			#multiplying by 4 to get number of bytes 
	#allocating memory on heap
	li $v0, 9			#$v0 = 9; sbrk (allocate heap memory)
	move $a0, $t1			#specyfing size of memory to allocate 4*m*n
	syscall
	move $t9,$v0			#$t9 address of alocated memory
	sw $t9,-16($fp)			#save address of alocated memory
	addiu $sp,$sp,-4		#put on stack sizes of matrix to display(m,n);pritn_matrix arguments
	sw $s1,($sp)
	addiu $sp,$sp, -4
	sw $s2,($sp)
#$t0 loop counter i = m*n
#$t7 present adddress of matrix1
#$t8 present address of matrix2	
sub_loop:
	lw $t5, ($t7)			#$t5 = matrix1[i]
	lw $t6, ($t8)			#t6 = matrix2[i]
	subu $t4,$t5,$t6		#$t4 = matrix1[i] - matrix2[i]; 
	sw $t4,($t9)			#save $t4 under address of new matrix
	addiu $t9,$t9,4			#go to the next word of new matrix (change address)
	addiu $t7,$t7,4			#go to the next word of matrix 1 (change address)
	addiu $t8,$t8,4			#go to the next word of matrix 2 (change address)
	addiu $t0,$t0,-1		#i--
	beqz $t0,cond_end		#if i == 0 goto cond_end
	j sub_loop
c3_body:
	#check whether it is possible to subtract
	bne $s2,$s3,error_m_n		#if n1 != m2 goto error_m_n
	#allocate memory on heap for m1*n2 word
	mul $t0,$s1,$s4			#size (in words) of new matrix
	sll $t1,$t0,2			#size in bytes of new matrix = 4*m1*n2
	li $v0, 9			#$v0 = 9; sbrk (allocate heap memory)
	move $a0, $t1			#specyfing size of memory to allocate 4*m*n
	syscall
	move $t9,$v0			#$t9 address of alocated memory
	sw $t9,($sp)			#save address of alocated memory
	addiu $sp,$sp,-4		#put on stack size of matrix to display(m1,n2);pritn_matrix arguments
	sw $s1,($sp)
	addiu $sp,$sp, -4
	sw $s4,($sp)
	#CONVETNITON HERE		loop counters
	
	
	move $t1,$zero 			#$t1 = 0

#$t2 = m1		each row of matrix1 will be multiplied
#t3 = m2		column (each element of that column) of matrix2 will be mutiplied= n1
#$t4 = n2		each column of matrix2 will be multiplied
#$t1 = 0 sum of each element of new matrix for example matrix_new[0][0]
#$t5 temp matrix1 element holder
#$t6 temp matrix2 element holder
#$t7 present matrix1 address
#$t8 present matrix2 address
#$t9 address of alocated memory
	move $t2,$s1			#$t2 = m1 	
loop_m1:
	move $t4, $s4			#$t4 = n2 
loop_n2:
	move $t3,$s3			#t3 = m2	
#single value loop	
loop_m2:				
	beqz $t3,end_m2 		#if n1 == 0 break and go to end_m2
	lw $t5, ($t7)			#load value from curren matrix1 address v1
	lw $t6, ($t8)			#load value from curren matrix2 address v2
	mul $t0,$t5,$t6			#v1*v2
	add $t1,$t1,$t0			#sum = sum + v1*v2
	addiu $t7,$t7,4			#move current address of matix 1
	mul $t0, $s4,4			#size in bytes to move address of matrix 2 to get to nex elem in column
	add $t8,$t8,$t0			#move current address of matix 1
	addiu $t3,$t3,-1		#m2= m2-1
	bgtz $t3,loop_m2		#if present m2 > 0 got mult_loop_m2
	
end_m2:
	sw $t1,($t9)			#save product of addition of multiplication of the each row elem (of matrix 1) and each elem of column of matrix 2
	addiu $t9,$t9,4			#next address of new matrix
	mul $t0, $s2, -4		#restore matrix 1 to the beginning of the row 
	add $t7,$t7,$t0
	move $t0, $s3		
	mul $t0, $t0, -4
	mul $t0, $s4, $t0		#restore matrix 2 to the beginning of the matrix
	addiu $t0,$t0,4
	add $t8,$t8, $t0		#matrix2 current address = next element (according to prior loop)
	move $t1,$zero			#temp = 0
	addiu $t4,$t4,-1		#$t4 = $t4 -1 decreacing present n2
	bgtz $t4,loop_n2		#if present n2>0 goto mult_loop_n2
end_n2:	
	sll $t0,$s2,2			#move matrix 1 to the next row
	add $t7,$t7,$t0
	lw $t8,-12($fp)			#go back to the beginning of matrix2 (to the address of beginning)
	addiu $t2,$t2,-1		#$t2 = $t2 - 1 decreacing present m1
	blez $t2,cond_end		#if $t2 <= 0 goto cond_end
	j loop_m1
	
c4_body:
	#check whether it is possible to calculate determinant
	bne $s1,$s2,error_m_n
	addiu $sp,$sp,-8
	sw $s1,4($sp)			#store n which is this case can be m1 or n1 cause they are the same, and are in $s1, $s2 
	lw $t0,-8($fp)			#load matrix address
	sw $t0,($sp)			#put matrix adddress on stack
	jal get_determinant
	addiu $sp,$sp,8			#dealocate space reverved for get_determinant args
	move $t0,$v0			#get returned value
	li $v0, 1			
	move $a0,$t0
	syscall
	j close_f
	
	
cond_end:		#prep to call print_matrix(m,n,address)
	addiu $sp,$sp,-4
	lw $t0,-16($fp)		
	sw $t0,($sp)		#address od matrix
	addiu $sp,$sp,-4
	lw $t0,-24($fp)		#n
	sw $t0,($sp)
	addiu $sp,$sp,-4
	lw $t0,-20($fp)		#m
	sw $t0, ($sp)
	jal print_matrix		#void print_matrix(int m,int n,int *address)
	addiu $sp,$sp,12		#deallocate space reserved for arg of print_matrix
	
close_f:
	li $v0,16		#closing file
	move $a0, $s0		#$a0 = file descriptor
	syscall
end:
	li $v0,10		#exit
	syscall


end_err_open:
	li $v0,4		#printing error message
	la $a0,error_open
	syscall
	li $v0,10		#exit
	syscall
err_wrong_format:
	li $v0,16		#closing file
	move $a0, $s0		#$a0 = file descriptor
	syscall
	li $v0,4		#printing error message
	la $a0,error_format
	syscall
	li $v0,10		#exit
	syscall
error_m_n:
	li $v0,16		#closing file
	move $a0, $s0		#$a0 = file descriptor
	syscall
	li $v0,4		#printing error message
	la $a0,error_sizes
	syscall
	li $v0,10		#exit
	syscall



#get_m_n function to get matrx's sizes, it return m in $v0 and n in $v1
#$t0 holds result during counting and later on moves it to $s7
get_m_n:
	lbu $t0, ($s5)			#load first char
	addiu $s5,$s5,1			#go to the next byte
	subi $t0,$t0,'0'		#convert to int	
new_char1:
	lbu $t1,($s5)
	addiu $s5,$s5,1
	beqz $t1,end_int1		#check if there are more to chars of number (bytes) to read
	beq $t1,'\n',end_int1
	beq $t1,' ',end_int1
	subi $t1,$t1,'0'		#convert to int	
	mulo  $t0,$t0,10		
	add $t0,$t0,$t1
	j new_char1
end_int1:	
	move $v0, $t0			#return m
#second int
	lbu $t0, ($s5)			#load first char
	addiu $s5,$s5,1			#go to the next byte
	subi $t0,$t0,'0'		#convert to int	
new_char2:
	lbu $t1,($s5)
	addiu $s5,$s5,1
	beqz $t1,end_int2		#check if there are more to chars of number (bytes) to read
	beq $t1,'\n',end_int2
	beq $t1,' ',end_int2
	subi $t1,$t1,'0'		#convert to int	
	mulo  $t0,$t0,10		
	add $t0,$t0,$t1
	j new_char2	
end_int2:
	move $v1, $t0			#return n
	jr $ra
		

#function get matrix: int str_to_int(buf_adress, dynamic_memory_adress)
#return value is stored in 
#
get_matrix:
	addiu $sp,$sp,-4		#taking care of return adress and frame pointer 
	sw $ra,0($sp)			#accualy for convention cause I don't use it recursively nor need this two things
	addiu $sp,$sp,-4
	sw $fp,0($sp)
	move $fp,$sp
	lw $t8,12($fp)			#$t8, loop counter, starts at m*n and goes to 0 ten breaks loop
	mul  $t7,$t8,4			#multiplying by 4 to get number of words to store ints
	li $v0, 9			#allocating memory on heap
	move $a0, $t7			#loading 4*m*n
	syscall
	lw $t6,8($fp)
	sw $v0,($t6)
	move $t9,$v0			#storing address of memory allocated for matrix, as a place for current address

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
	move $sp,$fp			#dealocting space for $ra and $fp
	lw $fp,($sp)
	addiu $sp,$sp, 4
	lw $ra,($sp)
	addiu $sp,$sp, 4
	jr $ra
	
	
#function get operation typ (no argument, no return value) all predefined using registers
#$s5 current buf address
get_operation_type:
	lbu $t0, ($s5)				#load first char
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
	li $s6, 4		#moving after 'e' 'd' so 2 bytes
	addiu $s5,$s5,2		
	j op_end
op_end:				
	addiu $s5,$s5,1		#moving after '\n'
	jr $ra
	
	
	
	
	
	
	
print_matrix:	#print matrix (m,n, address)
	addiu $sp,$sp,-4
	sw $ra,($sp)
	addiu $sp,$sp, -4
	sw $fp,($sp)
	move $fp,$sp
	lw $t0,8($fp)		#m
	lw $t1,12($fp)		#n
	lw $t2,16($fp)		#address
fori:	#go until m=0
	beqz $t0,end_printing
	addiu $t0,$t0,-1
forj:	#go until n=0
	beqz $t1, end_forj
	addiu $t1,$t1,-1
	li $v0, 1			#printing sigle element
	lw $a0, ($t2)
	syscall
	addiu $t2,$t2,4
	li $v0,11		#printing ' '
	li $a0,' '
	syscall
	j forj
end_forj:
	lw $t1,12($fp)		#n renewed
	li $v0,11		#printing \n
	li $a0, '\n'
	syscall
	j fori
	
end_printing:

	#lw $ra,4($fp)
	move $sp,$fp
	lw $fp,($sp)
	addiu $sp,$sp,4
	lw $ra,($sp)
	addiu $sp,$sp,4
	jr $ra


	
	
###############################################################################
#get_cofactor(int *address_matrix, int * temp, int p, int q, int size)
#where p index of row which won't be copied
#where q index of column which won't be copied
#it has local variables, but it won't be called recursively
#so they are not put on stack for conviniece, only registers are being used
get_cofactor:	
	addiu $sp,$sp,-4
	sw $ra, ($sp)
	addiu $sp,$sp,-4
	sw $fp,($sp)
	move $fp,$sp
	
	move $t0,$zero			# $t0 = i = 0
	move $t1,$zero			# $t1 = j = 0
	
	
	lw $t4,24($fp)			#$t4 = n; it will stay const
	lw $t5,16($fp)			#$t5 = p
	lw $t6,20($fp)			#t6 = q
	lw $t7,8($fp)			#t7 = address of matrix
	lw $t8,12($fp)			#$t8 = address of temp
	addiu $s7,$t4,-1		#n of temp = n -1 
	
	move $t2,$zero			# $t2 = row = 0
	bge $t2,$t4,not_loop1_get_cofactor	#  for (int row = 0; row < n; row++) 
	
loop1_get_cofactor:
	move $t3,$zero				#$t3 = col = 0
	bge $t3,$t4,end_loop1_get_cofactor	#   for (int col = 0; col < n; col++) 
loop2_get_cofactor:
	
if1_get_cofactor:	
	beq $t2,$t5, end_ifs_get_cofactor	# if (!(row==p || col==q))
	beq $t3,$t6, end_ifs_get_cofactor
	#temp 
	mul $t9, $s7, $t0			#go to index ith row, so i * size (in words)
	add $t9,$t9,$t1				#go to the correct column
	sll $t9,$t9,2				#multiply by 4 (shifting 2 bits left)
	add $t8,$t8,$t9				#store correct address
	move $t9,$zero
	#matrix
	mul $t9, $t4, $t2			#go to index ith row, so row * size (in words)
	add $t9,$t9,$t3			#go to the correct column
	sll $t9,$t9,2				#multiply by 4 (shifting 2 bits left)
	add $t7,$t7,$t9				#store correct address
	
	lw $t9,($t7)				#$t9 = mat[row][col]; 
	sw $t9,($t8)				#temp[i][j] = $t9
	addiu $t1,$t1,1				#j++
	lw $t7,8($fp)				#t7 = address of matrix back to beginning
	lw $t8,12($fp)				#$t8 = address of temp back to beginning
if2_get_cofactor:				
	addiu $t9,$t4,-1			# if (j == n - 1) 
	bne $t1, $t9, end_ifs_get_cofactor
	move $t1,$zero				#j=0	
	addiu $t0,$t0,1				#i++
end_ifs_get_cofactor:
	addiu $t3,$t3,1				#col++
	blt $t3,$t4,loop2_get_cofactor		#   for (int col = 0; col < n; col++)
end_loop1_get_cofactor:
	addiu $t2,$t2,1				#row++
	blt $t2,$t4,loop1_get_cofactor		#  for (int row = 0; row < n; row++)
not_loop1_get_cofactor:	
	move $sp,$fp				#end of the function
	lw $fp,($sp)
	addiu $sp,$sp,4
	lw $ra,($sp)
	addiu $sp,$sp,4
	jr $ra

#FUNCTION int determinant(int address_matrix, int n)
#convetion
#return in $v0, n = matix's dimmention
get_determinant:
	addiu $sp,$sp,-4
	sw $ra, ($sp)
	addiu $sp,$sp,-4
	sw $fp,($sp)
	move $fp,$sp
	#if (n==1) return matrix[0][0]
	lw $t0, 12($fp)			#$t0 = n
	bne $t0,1,not_if_get_determinant
	lw $t1, 8($fp)			#address of matrix
	lw $v0, ($t1)			#return $v0 = matrix 1x1 (i.e.single element)
	move $sp,$fp
	lw $fp,($sp)
	addiu $sp,$sp,4
	lw $ra,($sp)
	addiu $sp,$sp,4
	jr $ra
	
not_if_get_determinant:
	addiu $sp,$sp,-20		#local variables
					#int D; int * address_of_temp; int sign = 1; int f = 0; int size_in_bytes;
	sw $zero,-4($fp)		#D = 0
	addiu $t1,$zero,1		
	sw $t1,-12($fp)			#sign = 1;
	sw $zero,-16($fp)		#f = 0;

	#int temp[n-1][n-1]
	addiu $t1,$t0,-1		#dimention of temp: n-1
	mul $t1,$t1,$t1			#size of temp in words 
	sll $t1,$t1,2			#size of temp in bytes
	sw $t1,-20($fp)			#store size of temp in bytes
	subu $sp,$sp,$t1		#allocate space for temp
	la $t1,($sp)			#$t1 = address of address of temp 
	sw $t1,-8($fp)			#address_of_temp = $t1
	
	
	lw $t1,-16($fp)			#$t1 = f
	bge $t1 ,$t0,not_loop_get_determinant
loop_get_determinant:
	#put args of get_cofactor on stack
	addiu $sp,$sp,-20
	lw $t9,8($fp)			#load address of matrix
	sw $t9, ($sp)			#put address of matrix on sack
	lw $t9, -8($fp)			#load address of temp
	sw $t9, 4($sp)			#put addres of temp on stack
	sw $zero,8($sp)			#put p=0 on stack; each funtion will be called to count
					#cofactor of row =0, col will differ
	lw $t1,-16($fp)			#$t1 = f
	sw $t1,12($sp)			#store q = f on stack, !!!!!caution potential bug if in lines abouve $t1 was used, and change value from f
	lw $t0, 12($fp)			#$t0 = n
	sw $t0, 16($sp)			#store n = n dimmention of matrix to get cofactor of
	jal get_cofactor
	addiu $sp,$sp,20		#dealocate space from get_cofactor args
	#call get_determinant recursively
	#prep args for get_determinant
	addiu $sp,$sp,-8
	lw $t0, 12($fp)			#$t0 = n
	addiu $t0,$t0,-1		#$t0 = n -1
	sw $t0,4($sp)			#put n-1 on stack
	lw $t9, -8($fp)			#load address of temp
	sw $t9, ($sp)			#put addres of temp on stack
	jal get_determinant
	addiu $sp,$sp, 8		#it can be done here cause it will executed only for 1x1 matrix so no space for matrix will be unwillingly deallocated
	#sw $v0, -24($fp)		#a = what get_determinant's returned
	lw $t0, -12($fp)		#load sign
	#load mat[0][f]
	lw $t1, -16($fp)		#load f
	move $t9,$t1			#get copy of f for later use
	sll $t1,$t1,2			#4*f; multiply by 4 to get how far move mat address
	lw $t2,8($fp)			#load beginnig of matrix
	add $t2,$t2,$t1		#get correct address of matrix to get value from 
					#&m + 4*n*i*0 + 4*j where m[i][j] and dimmention n
	lw $t3,($t2)			#get m[0][f]	
	lw $t4, -4($fp)			#load D
	mul $t5,$t0,$t3			#$t5 = sign* mat[0][f];
	mul $t5,$t5,$v0			#$t5 = $t5*a;
	add $t4,$t4,$t5			#$t4 = $t4 + $t5 which translates into d = d + $t5
	sw $t4,-4($fp)			#acutalize D on stack			
	mul $t0,$t0,-1			#sign = -sign #######this made a mistake
	sw $t0,-12($fp)			#acutualize sign on stack
	addiu $t9,$t9,1			#f++
	sw $t9, -16($fp)		#actualize f on stack
	lw $t8, 12($fp)			#$t8 = n
	blt $t9,$t8,loop_get_determinant
	
not_loop_get_determinant:
	lw $v0, -4($fp)			#$v0 = D it will be returned
	move $sp,$fp			#dealocated local variables, does it deallocates also temp matrix????
	lw $fp,($sp)	
	addiu $sp,$sp,4
	lw $ra,($sp)
	addiu $sp,$sp,4
	jr $ra
	
