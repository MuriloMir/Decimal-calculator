// This module has functions to perform calculations using the decimal system, thus eliminating errors caused by the imprecise binary system.

module decimalcal;

import std.array : replace, split;
import std.bigint : BigInt;
import std.conv : to;
import std.math : abs;
import std.string : format;

// this is how many decimal places it is able to show, it rounds the last one only if it exceeds this limit
int precision = 20;

// this function adds the necessary padding 0s, so the operands will have the same number of decimal digits
void zeroing(ref string a, ref string b)
{
    // extract the decimal part of the strings
    string aDecimal = split(a, '.')[1], bDecimal = split(b, '.')[1];

    // do it based on the longest one, if 'aDecimal' is the shortest
    if (aDecimal.length < bDecimal.length)
        // append the 0s
        a ~= format("%0*d", bDecimal.length - aDecimal.length, 0);
    // if 'bDecimal' is the shortest
    else if (aDecimal.length > bDecimal.length)
        // append the 0s
        b ~= format("%0*d", aDecimal.length - bDecimal.length, 0);
}

// this function rounds the last digit, if necessary
void roundLastDigit(ref string result)
{
    // calculate how far beyond the precision we are, it must be ulong because of the '.length' variable
    ulong difference = split(result, '.')[1].length - precision;

    // if the digit which comes right after the precision is greater than or equal to 5
    if (result[$ - difference] >= '5')
        // if the result is negative, in this case we remove the '-' sign, round it and then put the '-' sign back
        if (result[0] == '-')
            // round it up, we have to make sure it doesn't create an infinite recursion
            result = '-' ~ addOrSubtract(result[1 .. $ - difference], format("0.%0*d", precision, 1), '+', false);
        // if the result is positive
        else
            // round it up, we have to make sure it doesn't create an infinite recursion
            result = addOrSubtract(result[0 .. $ - difference], format("0.%0*d", precision, 1), '+', false);
    // if the digit which comes right after the precision is less than 5
    else
        // truncate it
        result = result[0 .. $ - difference];
}

// this function will remove the extra 0s in the left and in the right of the result
string removeExtraZeros(string resultArg)
{
    // this boolean will tell if the number is negative
    bool isNegative;

    // if the number is negative, in this case we remove the '-' sign before removing the extra zeros, we put it back later
    if (resultArg[0] == '-')
    {
        // set this boolean to true
        isNegative = true;
        // remove the '-' sign
        resultArg = resultArg[1 .. $];
    }

    // while there are doubled 0s in the left
    while (resultArg[0 .. 2] == "00")
        // remove the doubled 0s
        resultArg = resultArg[1 .. $];

    // while there are doubled 0s in the right
    while (resultArg[$ - 2 .. $] == "00")
        // remove the doubled 0s
        resultArg = resultArg[0 .. $ - 1];

    // if the integer part of the number has more than 1 digit and there is an extra 0, this is for cases where the number is something like 01.4
    if (resultArg[0] == '0' && resultArg[1] != '.')
        // remove the extra 0
        resultArg = resultArg[1 .. $];

    // if the decimal part of the number has more than 1 digit and there is an extra 0, this is for cases where the number is something like 1.40
    if (resultArg[$ - 1] == '0' && resultArg[$ - 2] != '.')
        // remove the extra 0
        resultArg = resultArg[0 .. $ - 1];

    // if the number was negative at first
    if (isNegative)
        // put the '-' sign back
        resultArg = '-' ~ resultArg;

    // return the stripped string
    return resultArg;
}

// this function adds or subtracts the operands, the optional argument will tell if the function was called by you or by another function
string addOrSubtract(string a, string b, char operator, bool originalCall = true)
{
    // this is to increase the precision before doing the calculations, thus it only rounds in the very end, if this was the original call
    precision += 5 * cast(int) originalCall;
    // create the result string
    string result;

    // if it is an addition then change the operations in case you are adding negative operands
    if (operator == '+')
        // if 'b' is negative then we do 'a' - |'b'| because x + -y = x - y
        if (b[0] == '-')
        {
            // calculate the result with the updated operands
            result = addOrSubtract(a, b[1 .. $], '-', false);
            // this is to return the precision to its original value before returning, if this function was the original call
            precision -= 5 * cast(int) originalCall;

            // if the decimal part went beyond the precision
            if (split(result, '.')[1].length > precision)
                // round the last digit
                roundLastDigit(result);

            // remove the doubled extra 0s and return it
            return removeExtraZeros(result);
        }
        // if 'b' is positive but 'a' is negative then we do 'b' - |'a'| because -x + y = y - x
        else if (a[0] == '-')
        {
            // calculate the result with the updated operands
            result = addOrSubtract(b, a[1 .. $], '-', false);
            // this is to return the precision to its original value before returning, if this function was the original call
            precision -= 5 * cast(int) originalCall;

            // if the decimal part went beyond the precision
            if (split(result, '.')[1].length > precision)
                // round the last digit
                roundLastDigit(result);

            // remove the doubled extra 0s and return it
            return removeExtraZeros(result);
        }

    // organize them so they will have the same number of decimal places
    zeroing(a, b);

    // if it is a subtraction then we change the operations in case you are subtracting and you have negative operands or if you have 'b' > 'a'
    if (operator == '-')
        // if 'b' is negative then in this case we do 'a' + |'b'| because x - -y = x + y
        if (b[0] == '-')
        {
            // calculate the result with the updated operands
            result = addOrSubtract(a, b[1 .. $], '+', false);
            // this is to return the precision to its original value before returning, if this function was the original call
            precision -= 5 * cast(int) originalCall;

            // if the decimal part went beyond the precision
            if (split(result, '.')[1].length > precision)
                // round the last digit
                roundLastDigit(result);

            // remove the doubled extra 0s and return it
            return removeExtraZeros(result);
        }
        // if 'b' is positive but 'a' is negative then we do -(|'a'| + 'b') because -x - y = -(x + y)
        else if (a[0] == '-')
        {
            // calculate the result with the updated operands
            result = '-' ~ addOrSubtract(a[1 .. $], b, '+', false);
            // this is to return the precision to its original value before returning, if this function was the original call
            precision -= 5 * cast(int) originalCall;

            // if the decimal part went beyond the precision
            if (split(result, '.')[1].length > precision)
                // round the last digit
                roundLastDigit(result);

            // remove the doubled extra 0s and return it
            return removeExtraZeros(result);
        }
        // if you are trying to subtract a number from a smaller one then we swap the operation and add the '-' sign in front of it
        else if (BigInt(replace(a, ".", "")) < BigInt(replace(b, ".", "")))
        {
            // calculate the result with the updated operands
            result = '-' ~ addOrSubtract(b, a, '-', false);
            // this is to return the precision to its original value before returning, if this function was the original call
            precision -= 5 * cast(int) originalCall;

            // if the decimal part went beyond the precision
            if (split(result, '.')[1].length > precision)
                // round the last digit
                roundLastDigit(result);

            // remove the doubled extra 0s and return it
            return removeExtraZeros(result);
        }

    // store the number of decimal places which will be removed from both of them to make them integers, it has to be 'ulong' for the '.length' variable
    ulong decimalPlaces = split(a, '.')[1].length;
    // remove the radix point, so that they will be integers
    a = replace(a, ".", ""), b = replace(b, ".", "");
    // store the length of the longest operand
    ulong size = a.length >= b.length ? a.length : b.length;
    // define the result string with the sum or difference of the operands as integers
    result = to!string(operator == '+' ? BigInt(a) + BigInt(b) : BigInt(a) - BigInt(b));

    // if the result is shorter than the operands, this is for when the operands are like 0.0001 and 0.0002, we add the 0s in front of the result
    if (result.length < size)
        // add the 0s in front
        result = format("%0*d", size - result.length, 0) ~ result;

    // add the radix point in the correct place
    result = result[0 .. $ - decimalPlaces] ~ '.' ~ result[$ - decimalPlaces .. $];

    // this is to return the precision to its original value before returning, if this function was the original call
    precision -= 5 * cast(int) originalCall;

    // if it is longer than the precision then we round the last digit and remove it afterwards
    if (split(result, '.')[1].length > precision)
        // round the last digit
        roundLastDigit(result);

    // remove doubled extra 0s and return it
    return removeExtraZeros(result);
}

// this function multiplies the operands, the optional argument will tell if the function was called by you or by another function
string multiply(string a, string b, bool originalCall = true)
{
    // this is to increase the precision before doing the calculations, thus it only rounds in the very end, if this was the original call
    precision += 5 * cast(int) originalCall;
    // create the result string
    string result;

    // if 'a' is negative then we change the operations in case you are multiplying negative operands
    if (a[0] == '-')
        // if 'b' is also negative then the result will be |'a'| * |'b'| because -x * -y = x * y
        if (b[0] == '-')
        {
            // calculate the result with the updated operands
            result = multiply(a[1 .. $], b[1 .. $], false);
            // this is to return the precision to its original value before returning, if this function was the original call
            precision -= 5 * cast(int) originalCall;

            // if the decimal part went beyond the precision
            if (split(result, '.')[1].length > precision)
                // round the last digit
                roundLastDigit(result);

            // remove the doubled extra 0s and return it
            return removeExtraZeros(result);
        }
        // if only 'a' is negative then the result will be -(|'a'| * 'b') because -x * y = -(x * y)
        else
        {
            // calculate the result with the updated operands
            result = '-' ~ multiply(a[1 .. $], b, false);
            // this is to return the precision to its original value before returning, if this function was the original call
            precision -= 5 * cast(int) originalCall;

            // if the decimal part went beyond the precision
            if (split(result, '.')[1].length > precision)
                // round the last digit
                roundLastDigit(result);

            // remove the doubled extra 0s and return it
            return removeExtraZeros(result);
        }
    // if only 'b' is negative then the result will be -('a' * |'b'|) because x * -y = -(x * y)
    else if (b[0] == '-')
    {
        // calculate the result with the updated operands
        result = '-' ~ multiply(a, b[1 .. $], false);
        // this is to return the precision to its original value before returning, if this function was the original call
        precision -= 5 * cast(int) originalCall;

        // if the decimal part went beyond the precision
        if (split(result, '.')[1].length > precision)
            // round the last digit
            roundLastDigit(result);

        // remove the doubled extra 0s and return it
        return removeExtraZeros(result);
    }

    // store the number of decimal places which will be removed from both of them to make them integers, we add them because it's a multiplication,
    // it must be ulong because of the '.length' variable
    ulong decimalPlaces = split(a, '.')[1].length + split(b, '.')[1].length;
    // remove the radix point so they will be integers
    a = replace(a, ".", ""), b = replace(b, ".", "");
    // define the result string with the product of the operands as integers
    result = to!string(BigInt(a) * BigInt(b));

    // if the result is shorter than the number of decimal places
    if (result.length < decimalPlaces + 1)
        // add the extra 0s in front
        result = format("%0*d", decimalPlaces + 1, 0) ~ result;

    // add the radix point in the correct place
    result = result[0 .. $ - decimalPlaces] ~ '.' ~ result[$ - decimalPlaces .. $];

    // this is to return the precision to its original value before returning, if this function was the original call
    precision -= 5 * cast(int) originalCall;

    // if the decimal part went beyond the precision
    if (split(result, '.')[1].length > precision)
        // round the last digit
        roundLastDigit(result);

    // remove the doubled extra 0s and return it
    return removeExtraZeros(result);
}

// this function divides the 1st operand by the 2nd, as in a long division, the optional argument tells if it was called by you or by another function
string divide(string a, string b, bool originalCall = true)
{
    // this is to increase the precision before doing the calculations, thus it only rounds in the very end, if this was the original call
    precision += 5 * cast(int) originalCall;
    // this string will hold the quotient
    string result;

    // if 'a' is negative then you are dividing negative numbers, in which case we change the operations
    if (a[0] == '-')
        // if 'b' is also negative then the result will be |'a'| / |'b'| because -x / -y = x / y
        if (b[0] == '-')
        {
            // calculate the result with the updated operands
            result = divide(a[1 .. $], b[1 .. $], false);
            // this is to return the precision to its original value before returning, if this function was the original call
            precision -= 5 * cast(int) originalCall;

            // if the decimal part went beyond the precision
            if (split(result, '.')[1].length > precision)
                // round the last digit
                roundLastDigit(result);

            // remove the doubled extra 0s and return it
            return removeExtraZeros(result);
        }
        // if only 'a' is negative then the result will be -(|'a'| / 'b') because -x / y = -(x / y)
        else
        {
            // calculate the result with the updated operands
            result = '-' ~ divide(a[1 .. $], b, false);
            // this is to return the precision to its original value before returning, if this function was the original call
            precision -= 5 * cast(int) originalCall;

            // if the decimal part went beyond the precision
            if (split(result, '.')[1].length > precision)
                // round the last digit
                roundLastDigit(result);

            // remove the doubled extra 0s and return it
            return removeExtraZeros(result);
        }
    // if only 'b' is negative then the result will be -('a' / |'b'|) because x / -y = -(x / y)
    else if (b[0] == '-')
    {
        // calculate the result with the updated operands
        result = '-' ~ divide(a, b[1 .. $], false);
        // this is to return the precision to its original value before returning, if this function was the original call
        precision -= 5 * cast(int) originalCall;

        // if the decimal part went beyond the precision
        if (split(result, '.')[1].length > precision)
            // round the last digit
            roundLastDigit(result);

        // remove the doubled extra 0s and return it
        return removeExtraZeros(result);
    }

    // organize them so they will have the same number of decimal places
    zeroing(a, b);
    // remove the radix point so they will be integers
    a = replace(a, ".", ""), b = replace(b, ".", "");
    // create an integer version of the divisor because it makes the code cleaner than casting it many times
    BigInt divisor = BigInt(b);

    // in case something goes wrong and you try to divide by 0
    if (divisor == BigInt("0"))
    {
        // this is to return the precision to its original value before returning, if this function was the original call
        precision -= 5 * cast(int) originalCall;

        // return this error phrase
        return "Division by 0 is impossible.";
    }

    // define the result with the quotient, we start with the integer part of the quotient, there can be no 0s after the radix point here
    result = to!string(BigInt(a) / divisor) ~ '.';
    // calculate the remainder
    BigInt remainder = BigInt(a) % divisor;

    // use a loop to do the decimal part of the quotient according to the precision, for as long as there's a remainder and it's less than the precision
    for (int i; remainder > 0 && i++ < precision; remainder %= divisor)
    {
        // adjust the remainder in order to divide again
        remainder *= BigInt("10");
        // divide it and store the result
        result ~= to!string(remainder / divisor);
    }

    // do it 1 last time to make sure it will have at least 1 digit after the radix point
    result ~= to!string(remainder * 10 / divisor);

    // this is to return the precision to its original value before returning, if this function was the original call
    precision -= 5 * cast(int) originalCall;

    // if the decimal part went beyond the precision
    if (split(result, '.')[1].length > precision)
        // round the last digit
        roundLastDigit(result);

    // remove the doubled extra 0s and return it
    return removeExtraZeros(result);
}

// this function calculates powers, the exponent must be an integer and the optional argument tells if it was called by you or by another function
string power(string base, string exponent, bool originalCall = true)
{
    // this is to increase the precision before doing the calculations, thus it only rounds in the very end, if this was the original call
    precision += 5 * cast(int) originalCall;

    // if the exponent isn't an integer (it would be okay for 2.0, for example)
    if (exponent[$ - 2 .. $] != ".0")
    {
        // this is to return the precision to its original value before returning, if this function was the original call
        precision -= 5 * cast(int) originalCall;

        // return this error message
        return "I can only calculate powers if the exponent is an integer.";
    }

    // this string will contain the result, it starts with the value of the base
    string result = base;

    // if the exponent is 0
    if (exponent == "0.0")
    {
        // this is to return the precision to its original value before returning, if this function was the original call
        precision -= 5 * cast(int) originalCall;

        // return 1.0 since all numbers to the 0th power result in 1.0
        return "1.0";
    }
    // if the exponent is negative
    else if (exponent[0] == '-')
    {
        // we calculate the result as the inverse of the power with the positive exponent
        result = divide("1.0", power(base, exponent[1 .. $], false), false);
        // this is to return the precision to its original value before returning, if this function was the original call
        precision -= 5 * cast(int) originalCall;

        // if the decimal part went beyond the precision
        if (split(result, '.')[1].length > precision)
            // round the last digit
            roundLastDigit(result);

        // remove the doubled extra 0s and return it
        return removeExtraZeros(result);
    }

    // use a loop to multiply the base by itself a number of times equal to the exponent
    for (int i = to!int(exponent[0 .. $ - 2]); i > 1; i--)
        // multiply the base by itself
        result = multiply(result, base, false);

    // this is to return the precision to its original value before returning, if this function was the original call
    precision -= 5 * cast(int) originalCall;

    // if the decimal part went beyond the precision
    if (split(result, '.')[1].length > precision)
        // round the last digit
        roundLastDigit(result);

    // remove the doubled extra 0s and return it
    return removeExtraZeros(result);
}

// this function is going to calculate roots, it only calculates roots of non-negative numbers, the index must be a positive integer and the optional
// argument tells if it was called by you or by another function
string root(string radicand, string index, bool originalCall = true)
{
    // if the radicand or the index is negative or the index isn't a positive integer (it would work for 2.0, for example)
    if (radicand[0] == '-' || index[0] == '-' || index[$ - 2 .. $] != ".0" || index == "0.0")
        // return this error message
        return "I can't calculate roots of negative numbers and the index must be a positive integer.";

    // this is to increase the precision before doing the calculations, thus it only rounds in the very end, if this was the original call
    precision += 5 * cast(int) originalCall;
    // create the variables we will need, we will be using binary search to find the number which produces the most accurate result
    string approxResult, difference, midPoint, lowerBound = "1.0", upperBound = radicand, limit = format("0.%0*d", precision, 1);

    // if the radicand is less than 1.0, in this case we multiply it by 10.0, take the root and then divide it by the root of 10.0
    if (radicand[0] == '0')
    {
        // as in sqrt(0.5) = sqrt(5 / 10) = sqrt(5) / sqrt(10)
        midPoint = divide(root(multiply(radicand, "10.0", false), index, false), root("10.0", index, false), false);
    }
    // if the radicand is greater than or equal to 1.0
    else
        // start a loop to keep finding a root that is more and more accurate until it reaches a difference which is less than or equal to the precision
        do
        {
            // calculate the midpoint
            midPoint = divide(addOrSubtract(lowerBound, upperBound, '+'), "2.0", false);
            // calculate an approximate result by doing the midpoint risen to a power which is equal to the index
            approxResult = power(midPoint, index, false);
            // take the difference between the approximate result and the radicand, to see how close it got
            difference = addOrSubtract(radicand, approxResult, '-', false);
    
            // if the difference was negative
            if (difference[0] == '-')
            {
                // the result was too high, so the upper bound becomes the midpoint, therefore reducing the next result
                upperBound = midPoint;
                // remove the '-' sign (we want to know how close it got and therefore we want the absolute value)
                difference = difference[1 .. $];
            }
            // if the difference was positive
            else
                // the result was too low, so the lower bound becomes the midpoint, therefore increasing the result
                lowerBound = midPoint;
        }
        // keep doing it until the difference is smaller than the limit and also the upper bound is not yet almost identical to the lower bound
        while (difference > limit && addOrSubtract(upperBound, lowerBound, '-', false) > limit);

    // this is to return the precision to its original value before returning, if this function was the original call
    precision -= 5 * cast(int) originalCall;

    // if the decimal part went beyond the precision (the final midpoint is the result)
    if (split(midPoint, '.')[1].length > precision)
        // round the last digit
        roundLastDigit(midPoint);

    // remove the doubled extra 0s and return it
    return removeExtraZeros(midPoint);
}
