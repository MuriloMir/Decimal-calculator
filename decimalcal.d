// This module has functions to do calculations using the decimal system, thus eliminating errors caused by the imprecise binary system.
module decimalcal;

import std.array : replace, split;
import std.bigint : BigInt;
import std.conv : to;
import std.string : format;

// this is how many decimal places it is able to show, it rounds the last one only if it exceeds this limit
const int precision = 20;

// this routine adds the necessary padding zeros so the operands will have the same number of decimal digits
void zeroing(ref string a, ref string b)
{
    // extracting the decimal part of the strings
    string aDecimal = split(a, '.')[1], bDecimal = split(b, '.')[1];
    // we do it based on the longest one
    if (aDecimal.length < bDecimal.length)
        a ~= format("%0*d", bDecimal.length - aDecimal.length, 0);
    else if (aDecimal.length > bDecimal.length)
        b ~= format("%0*d", aDecimal.length - bDecimal.length, 0);
}

// this routine will be used to round the last digit, if necessary
void roundLastDigit(ref string result)
{
    // we calculate how far beyond the precision we are
    ulong difference = split(result, '.')[1].length - precision;
    // we check to see if the digit which comes right after the precision is greater than or equal to 5
    if (result[$ - difference] >= '5')
        // then we round it up, we have to make sure it doesn't create an infinite recursion
        result = addOrSubtract(result[0 .. $ - difference], format("0.%0*d", precision, 1), '+');
    // or we round it down
    else
        result = result[0 .. $ - difference];
}

// this function will remove the extra 0s in the left and in the right of the result
string removeExtraZeros(string resultArg)
{
    // we keep removing doubled 0s in the left
    while (resultArg[0 .. 2] == "00")
        resultArg = resultArg[1 .. $];
    // then we keep removing doubled 0s in the right
    while (resultArg[$ - 2 .. $] == "00")
        resultArg = resultArg[0 .. $ - 1];
    return resultArg;
}

// this function adds or subtracts the operands
string addOrSubtract(string a, string b, char operator)
{
    // we change the operations in case you are adding negative operands
    if (operator == '+')
        // if b is negative then we do a - |b| because x + -y = x - y
        if (b[0] == '-')
            return addOrSubtract(a, b[1 .. $], '-');
        // if b is positive but a is negative then we do b - |a| because -x + y = y - x
        else if (a[0] == '-')
            return addOrSubtract(b, a[1 .. $], '-');
    // first we organize them so they will have the same number of decimal places
    zeroing(a, b);
    // we change the operations in case you are subtracting and you have negative operands or you have b > a
    if (operator == '-')
        // if b is negative then in this case we do a + |b| because x - -y = x + y
        if (b[0] == '-')
            return addOrSubtract(a, b[1 .. $], '+');
        // if b is positive but a is negative then we do - (|a| + b) because -x - y = - (x + y)
        else if (a[0] == '-')
            return '-' ~ addOrSubtract(a[1 .. $], b, '+');
        // if you are trying to subtract a number from another one smaller then we swap the operation and add the negative sign in front of it
        else if (BigInt(replace(a, ".", "")) < BigInt(replace(b, ".", "")))
            return '-' ~ addOrSubtract(b, a, '-');
    // now we store the number of decimal places that will be removed from both of them to make them integers
    ulong decimalPlaces = split(a, '.')[1].length;
    // here we remove the radix point so they will be integers
    a = replace(a, ".", ""), b = replace(b, ".", "");
    // now we store the number's size
    ulong size = a.length >= b.length ? a.length : b.length;
    // here we create the result string with the sum or difference of the operands as integers
    string result = to!string(operator == '+' ? BigInt(a) + BigInt(b) : BigInt(a) - BigInt(b));
    // this is for cases when you add or subtract numbers like 0.0001 and 0.0002, we add the zeros in front of the result
    if (result.length < size)
        result = format("%0*d", size - result.length, 0) ~ result;
    // now we add the radix point in the correct place
    result = result[0 .. $ - decimalPlaces] ~ '.' ~ result[$ - decimalPlaces .. $];
    // this is to round the last digit and remove it afterwards, we check if the decimal part went beyond the precision
    if (split(result, '.')[1].length > precision)
        roundLastDigit(result);
    // we remove doubled extra 0s before returning it
    return removeExtraZeros(result);
}

// this function multiplies the operands
string multiply(string a, string b)
{
    // we change the operations in case you are multiplying negative operands
    if (a[0] == '-')
        // if both are negatives then the result will be |a| * |b|
        if (b[0] == '-')
            return multiply(a[1 .. $], b[1 .. $]);
        // if only a is negative then the result will be -(|a| * b)
        else
            return '-' ~ multiply(a[1 .. $], b);
    // if only b is negative then the result will be -(a * |b|)
    else if (b[0] == '-')
        return '-' ~ multiply(a, b[1 .. $]);
    // now we store the number of decimal places that will be removed from both of them to make them integers, we use both of them because are doing multiplication here
    ulong decimalPlaces = split(a, '.')[1].length + split(b, '.')[1].length;
    // here we remove the radix point so they will be integers
    a = replace(a, ".", ""), b = replace(b, ".", "");
    // here we create the result string with the product of the operands as integers
    string result = to!string(BigInt(a) * BigInt(b));
    // in case the result was shorter than the number of decimal places, you need to add an extra 0 here
    if (result.length < decimalPlaces + 1)
        result = format("%0*d", decimalPlaces + 1, 0) ~ result;
    // now we add the radix point in the correct place
    result = result[0 .. $ - decimalPlaces] ~ '.' ~ result[$ - decimalPlaces .. $];
    // this is to round the last digit and remove it afterwards, we check if the decimal part went beyond the precision
    if (split(result, '.')[1].length > precision)
        roundLastDigit(result);
    // we remove doubled extra 0s before returning it
    return removeExtraZeros(result);
}

// this function divides the second operand into the first as in a long division
string divide(string a, string b)
{
    // we change the operations in case you are dividing negative operands
    if (a[0] == '-')
        // if both are negatives then the result will be |a| / |b|
        if (b[0] == '-')
            return divide(a[1 .. $], b[1 .. $]);
        // if only a is negative then the result will be -(|a| / b)
        else
            return '-' ~ divide(a[1 .. $], b);
    // if only b is negative then the result will be -(a / |b|)
    else if (b[0] == '-')
        return '-' ~ divide(a, b[1 .. $]);
    // first we organize them so they will have the same number of decimal places
    zeroing(a, b);
    // here we remove the radix point so they will be integers
    a = replace(a, ".", ""), b = replace(b, ".", "");
    // here I create an integer version of the divisor because it makes the code cleaner than casting it many times
    BigInt divisor = BigInt(b);
    // in case something goes wrong and you try to divide by 0
    if (divisor == 0)
        return "division by 0 is impossible";
    //the string that holds the quotient, we start with the integer part of the quotient
    string result = to!string(BigInt(a) / divisor) ~ '.';
    // here we do the decimal part of the quotient according to the precision, for as long as there is a remainder
    BigInt remainder = BigInt(a) % divisor;
    for (int i; remainder > 0 && i++ < precision; remainder %= divisor)
    {
        remainder *= 10;
        result ~= to!string(remainder / divisor);
    }
    // we have to do it one last time to make sure it will have at least 1 digit after the radix point
    result ~= to!string(remainder * 10 / divisor);
    // this is to round the last digit and remove it afterwards, we check if the decimal part went beyond the precision
    if (split(result, '.')[1].length > precision)
        roundLastDigit(result);
    // there is no way it could have extra 0s here, so we just return it right away
    return result;
}
