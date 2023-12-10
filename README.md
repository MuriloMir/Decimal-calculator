# Decimal-Calculator
This is a module written in D which implements functions for you to perform calculations with the decimal number system rather than the binary number system. The idea is to bypass the precision loss that happens as a result of the binary system, with this module you can perform FP math with a total precision of 20 decimal places or more (you can change the precision at will), even for numbers that are very big or very tiny.

To use it you only need to download the module into your project's folder and import it in your code.

It contains the functions addOrSubtract(), multiply() and divide(), all of which will receive as arguments 2 numbers in string format, addOrSubtract() requires a third argument which is the operation in char format (it should be a '+' or a '-').

E.g. addOrSubtract("2.5", "0.004", '+'), addOrSubtract("-2.5", "0.004", '-'), multiply("-2.5", "0.004"), divide("-2.5", "-0.004");
