# Decimal-Calculator
This is a module written in D which implements functions for you to perform calculations with the decimal number system rather than the binary number system. The idea is to bypass the precision loss that happens as a result of the binary system, with this module you can perform FP math with a total precision of 20 decimal places or more (you can change the precision at will), even for numbers that are very big or very tiny.

To use it you only need to download the module into your project's folder and import it in your code.

It contains only the function compute(), which will receive 3 parameters: the first operand, the operation symbol and the second operand. Remember to write the numbers properly, always write them with no unnecessary 0s and with at least 1 decimal place, do NOT add a + sign in front, do it always as in "2.0" or "-1.0".

If you want to calculate a modulo, then both operands must be positive integers. Also keep in mind it only works with powers which have a positive integer exponent, never try to calculate a number to the power of 1.5, or 0. And if you are calculating roots then it only works for non-negative numbers with a positive integer index, therefore never try to calculate the square root of -3.0, the 0 root of a number, the -2.0 root of a number or the 1.5 root of a number.

There is a variable called 'precision' which can be used to set the precision, it is 20 by default, but you can define it to be any number bigger than 0, as in precision = 10 or precision = 65. NEVER define it as 0.

E.g. compute("2.5", '+', "0.004"), compute("-2.5", '-', "0.004"), compute("-2.5", '*', "0.004"), compute("-2.5", '/', "-0.004"), compute("17.0", '%', "5.0"), compute("12.0", '^', "4.0"), compute("10.9", 'r', "4.0"). Here we have done an addition, then a subtraction, then a multiplication, then a division, then a modulo, then a power and then a root, respectively.

It is very fast, running on my AMD FX-4300 CPU it was able to perform 183k additions per sec, 134k subtractions per sec, 240k multiplications per sec, 31k divisions per sec, 555k modulos per sec, 30k powers per sec and 80 roots per sec, all with a precision of 20 digits, very impressive. I know the roots are much slower than the other operations, but it is still quite fast.
