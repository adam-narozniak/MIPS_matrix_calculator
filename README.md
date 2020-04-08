# MIPS Matrix Calculator
Program enables to do the following operation:
* addition,
* subtraction,
* multiplication,
* calculation of determinant.
It gets input from a file of specific format.
Matrices are read to bufor, then dynamically allocated on heap. The same goes for a result.
Program outputs (prints) a product of calculation. Determinant is calculated using Laplace expansion.
## Funtions
Program has few specified funtions:
* get_matrix
* get_m_n
* get_determinant ...
Not all of them allocate local variables, some of them return using secified registers.

### File format
\<operation\><br>
\<matrix1's size\><br>
\<matrix1\><br>
\<matrix2's size\><br>
\<matrix2\><br>

```
+
2 3
134 2 3
-2 8 72
2 3
1 0 -3
6 2 9
```

Operation: + - * det
Numbers can be positive or negative.
## Constrains
If a specified operation isn't doable, then program throw an error communating that. The same applies to path address, 
which is stored in the .data segment.
Please be cautious about additional whitespace: space and newline. Program won't work properly if this is violeted.


### Restrictions
An error will accur (during for example multipliacation or determinant computation) if the intiger can't be represted in 32 bits in U2.
