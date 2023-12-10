# Decimal-Calculator
This is a module written in D which implements functions for you to perform calculations with the decimal number system rather than the binary number system. The idea is to bypass the precision loss that happens as a result of the binary system, with this module you can perform FP math with a total precision of 20 decimal places or more (you can change the precision at will), even for numbers that are very big or very tiny.

To use it you only need to download the module into your project's folder and import it in your code.

It contains the functions addOrSubtract(), multiply(), divide(), power() and root(), all of which will receive as parameters 2 numbers in string format, addOrSubtract() requires a third parameter which is the operation in char format (it should be a '+' or a '-'). Remember to write the numbers properly, always write them with no unnecessary 0s and with at least 1 decimal place, don't add a + sign, do it as in "2.0" or "-1.0".

There is a variable called precision which can be used to set the precision, it is 20 by default, but you can define it to be any number bigger than 0, as in precision = 10 or precision = 65. Never define it as 0.

E.g. addOrSubtract("2.5", "0.004", '+'), addOrSubtract("-2.5", "0.004", '-'), multiply("-2.5", "0.004"), divide("-2.5", "-0.004"), power("12.0", "4.0"), root("10.9", "4.0");
