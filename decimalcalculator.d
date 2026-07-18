/*
    This library has functions to perform calculations using the decimal system, thus eliminating errors caused by the imprecise binary system.

    Here are the instructions: always write the numbers with no unnecessary 0s and with at least 1 decimal place, do NOT add a + sign in front, do it
    always as in "2.0" or "-1.0". If you want to calculate a modulo, then both operands must be positive integers. It only works with powers which have a
    non-negative integer exponent and with roots which are a non-negative number with a positive integer index. NEVER define the variable 'precision'
    as 0.
*/

// give it a name
module decimalcalculator;

// import the tools we need
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
        // append the 0s to the end of 'a'
        a ~= format("%0*d", bDecimal.length - aDecimal.length, 0);
    // if 'bDecimal' is the shortest
    else if (aDecimal.length > bDecimal.length)
        // append the 0s to the end of 'b'
        b ~= format("%0*d", aDecimal.length - bDecimal.length, 0);
}

// this function rounds the last digit, if necessary, it uses the result by reference
void roundLastDigit(ref string result)
{
    // calculate how far beyond the precision we are, it must be ulong because '.length' is 'ulong'
    ulong difference = split(result, '.')[1].length - precision;

    // if the digit which comes right after the precision is greater than or equal to 5
    if (result[$ - difference] >= '5')
    {
        // if the result is positive
        if (result[0] != '-')
            // round it up, we have to make sure it doesn't create an infinite recursion, hence we remove here the part which goes beyond the precision, otherwise this
            // function 'roundLastDigit()' would be called again inside the 'addOrSubtract()' function
            result = addOrSubtract(result[0 .. $ - difference], format("0.%0*d", precision, 1), '+', false);
        // if the result is negative, in this case we have to remove the '-' sign, round it and then put the '-' sign back
        else
            // round it up, we have to make sure it doesn't create an infinite recursion, hence we remove here the part which goes beyond the precision, otherwise this
            // function 'roundLastDigit()' would be called again inside the 'addOrSubtract()' function
            result = '-' ~ addOrSubtract(result[1 .. $ - difference], format("0.%0*d", precision, 1), '+', false);
    }
    // if the digit which comes right after the precision is less than 5
    else
        // truncate it
        result = result[0 .. $ - difference];
}

// this function will remove the extra 0s in the left and in the right of the result, the extra 0s can happen during calculations
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

    // while there are doubled 0s in the left (all numbers will have at least the length of 3 because they all have at least 1 decimal place)
    while (resultArg[0 .. 2] == "00")
        // remove the doubled 0s
        resultArg = resultArg[1 .. $];

    // while there are doubled 0s in the right (all numbers will have at least the length of 3 because they all have at least 1 decimal place)
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

    // return the new string which is stripped of extra 0s
    return resultArg;
}

// this function adds or subtracts the operands, the optional parameter will tell if the function was called by you or by another function
string addOrSubtract(string a, string b, char operator, bool originalCall = true)
{
    // if this was the original call
    if (originalCall)
        // this is to increase the precision before doing the calculations, thus it only rounds it in the very end
        precision += 5;

    // create the result string
    string result;

    // if it is an addition then change the operations in case you are adding negative operands
    if (operator == '+')
    {
        // if 'b' is negative then we do 'a' - |'b'| because x + -y = x - y
        if (b[0] == '-')
        {
            // recursively calculate the result with the updated operands (we removed the '-' sign in front of 'b')
            result = addOrSubtract(a, b[1 .. $], '-', false);

            // if this was the original call
            if (originalCall)
                // this is to return the precision to its original value before returning
                precision -= 5;

            // if the decimal part went beyond the precision
            if (split(result, '.')[1].length > precision)
                // round the last digit, with the 'roundLastDigit()' function
                roundLastDigit(result);

            // remove any possible doubled 0s, with the 'removeExtraZeros()' function, and return it
            return removeExtraZeros(result);
        }
        // else if 'b' is positive but 'a' is negative then we do 'b' - |'a'| because -x + y = y - x
        else if (a[0] == '-')
        {
            // recursively calculate the result with the updated operands (we removed the '-' sign in front of 'a')
            result = addOrSubtract(b, a[1 .. $], '-', false);

            // if this was the original call
            if (originalCall)
                // this is to return the precision to its original value before returning
                precision -= 5;

            // if the decimal part went beyond the precision
            if (split(result, '.')[1].length > precision)
                // round the last digit, with the 'roundLastDigit()' function
                roundLastDigit(result);

            // remove any possible doubled 0s, with the 'removeExtraZeros()' function, and return it
            return removeExtraZeros(result);
        }
    }

    // organize them so they will have the same number of decimal places, with the 'zeroing()' function
    zeroing(a, b);

    // if it is a subtraction then we change the operations in case you are subtracting and you have negative operands or if you have 'b' > 'a'
    if (operator == '-')
    {
        // if 'b' is negative then in this case we do 'a' + |'b'| because x - -y = x + y
        if (b[0] == '-')
        {
            // recursively calculate the result with the updated operands (we removed the '-' sign in front of 'b')
            result = addOrSubtract(a, b[1 .. $], '+', false);

            // if this was the original call
            if (originalCall)
                // this is to return the precision to its original value before returning
                precision -= 5;

            // if the decimal part went beyond the precision
            if (split(result, '.')[1].length > precision)
                // round the last digit, with the 'roundLastDigit()' function
                roundLastDigit(result);

            // remove any possible doubled 0s, with the 'removeExtraZeros()' function, and return it
            return removeExtraZeros(result);
        }
        // else if 'b' is positive but 'a' is negative then we do -(|'a'| + 'b') because -x - y = -(x + y)
        else if (a[0] == '-')
        {
            // recursively calculate the result with the updated operands
            result = '-' ~ addOrSubtract(a[1 .. $], b, '+', false);

            // if this was the original call
            if (originalCall)
                // this is to return the precision to its original value before returning
                precision -= 5;

            // if the decimal part went beyond the precision
            if (split(result, '.')[1].length > precision)
                // round the last digit, with the 'roundLastDigit()' function
                roundLastDigit(result);

            // remove any possible doubled 0s, with the 'removeExtraZeros()' function, and return it
            return removeExtraZeros(result);
        }
        // else if you are trying to subtract a number from a smaller one then we swap the operation and add the '-' sign in front of it
        else if (BigInt(replace(a, ".", "")) < BigInt(replace(b, ".", "")))
        {
            // recursively calculate the result with the updated operands
            result = '-' ~ addOrSubtract(b, a, '-', false);

            // if this was the original call
            if (originalCall)
                // this is to return the precision to its original value before returning
                precision -= 5;

            // if the decimal part went beyond the precision
            if (split(result, '.')[1].length > precision)
                // round the last digit, with the 'roundLastDigit()' function
                roundLastDigit(result);

            // remove any possible doubled 0s, with the 'removeExtraZeros()' function, and return it
            return removeExtraZeros(result);
        }
    }

    // store the number of decimal places which will be removed from both of them to make them integers, it has to be 'ulong' for the '.length' variable
    ulong decimalPlaces = split(a, '.')[1].length;
    // remove the radix point, so that they will be integers
    a = replace(a, ".", ""), b = replace(b, ".", "");
    // store the length of the longest operand, we use a ternary in order to check which is the longest
    ulong size = a.length >= b.length ? a.length : b.length;
    // define the result string with the sum or difference of the operands as big integers, we use a ternary in order to check which operation it is
    result = to!string(operator == '+' ? BigInt(a) + BigInt(b) : BigInt(a) - BigInt(b));

    // if the result is shorter than the operands, this is for cases when the operands are like 0.0001 and 0.0002, we add the 0s in front of the result
    if (result.length < size)
        // add the 0s in front
        result = format("%0*d", size - result.length, 0) ~ result;

    // return the radix point to the correct place
    result = result[0 .. $ - decimalPlaces] ~ '.' ~ result[$ - decimalPlaces .. $];

    // if this was the original call
    if (originalCall)
        // this is to return the precision to its original value before returning
        precision -= 5;

    // if the decimal part went beyond the precision
    if (split(result, '.')[1].length > precision)
        // round the last digit, with the 'roundLastDigit()' function
        roundLastDigit(result);

    // remove any possible doubled 0s, with the 'removeExtraZeros()' function, and return it
    return removeExtraZeros(result);
}

// this function multiplies the operands, the optional parameter will tell if the function was called by you or by another function
string multiply(string a, string b, bool originalCall = true)
{
    // this is to increase the precision before doing the calculations, thus it only rounds in the very end, if this was the original call (a boolean)
    precision += 5 * cast(int) originalCall;
    // create the result string
    string result;

    // if 'a' is negative then we change the operations in case you are multiplying negative operands
    if (a[0] == '-')
    {
        // if 'b' is also negative then the result will be |'a'| * |'b'| because -x * -y = x * y
        if (b[0] == '-')
        {
            // calculate the result with the updated operands (no '-' sign)
            result = multiply(a[1 .. $], b[1 .. $], false);
            // this is to return the precision to its original value before returning, if this function was the original call (a boolean)
            precision -= 5 * cast(int) originalCall;

            // if the decimal part went beyond the precision, notice we split it where the radix point is
            if (split(result, '.')[1].length > precision)
                // round the last digit, with the 'roundLastDigit()' function
                roundLastDigit(result);

            // remove the doubled extra 0s, with the 'removeExtraZeros()' function, and then return it
            return removeExtraZeros(result);
        }
        // else, meaning only 'a' is negative then the result will be -(|'a'| * 'b') because -x * y = -(x * y)
        else
        {
            // calculate the result with the updated operands (no '-' sign in front of 'a')
            result = '-' ~ multiply(a[1 .. $], b, false);
            // this is to return the precision to its original value before returning, if this function was the original call (a boolean)
            precision -= 5 * cast(int) originalCall;

            // if the decimal part went beyond the precision, notice we split it where the radix point is
            if (split(result, '.')[1].length > precision)
                // round the last digit, with the 'roundLastDigit()' function
                roundLastDigit(result);

            // remove the doubled extra 0s, with the 'removeExtraZeros()' function, and then return it
            return removeExtraZeros(result);
        }
    }
    // else if only 'b' is negative then the result will be -('a' * |'b'|) because x * -y = -(x * y)
    else if (b[0] == '-')
    {
        // calculate the result with the updated operands (no '-' sign in front of 'b')
        result = '-' ~ multiply(a, b[1 .. $], false);
        // this is to return the precision to its original value before returning, if this function was the original call (a boolean)
        precision -= 5 * cast(int) originalCall;

        // if the decimal part went beyond the precision, notice we split it where the radix point is
        if (split(result, '.')[1].length > precision)
            // round the last digit, with the 'roundLastDigit()' function
            roundLastDigit(result);

        // remove the doubled extra 0s, with the 'removeExtraZeros()' function, and then return it
        return removeExtraZeros(result);
    }

    // split the operands where the radix point is, then store the number of decimal places which will be removed from both of them in order to make them
    // integers, we add their quantities because it's a multiplication, it must be 'ulong' because the '.length' variable is an 'ulong'
    ulong decimalPlaces = split(a, '.')[1].length + split(b, '.')[1].length;
    // remove the radix point so that they will be integers
    a = replace(a, ".", ""), b = replace(b, ".", "");
    // calculate the result string with the product of the operands as integers
    result = to!string(BigInt(a) * BigInt(b));

    // if the result is shorter than the number of decimal places (it could occur when you multiply by something like 0.00001)
    if (result.length < decimalPlaces + 1)
        // add the extra 0s in front, some extra 0s to the left may appear but they will be removed later
        result = format("%0*d", decimalPlaces + 1, 0) ~ result;

    // add the radix point in the correct place
    result = result[0 .. $ - decimalPlaces] ~ '.' ~ result[$ - decimalPlaces .. $];
    // this is to return the precision to its original value before returning, if this function was the original call (a boolean)
    precision -= 5 * cast(int) originalCall;

    // if the decimal part went beyond the precision
    if (split(result, '.')[1].length > precision)
        // round the last digit, with the 'roundLastDigit()' function
        roundLastDigit(result);

    // remove the doubled extra 0s, with the 'removeExtraZeros()' function, and then return it
    return removeExtraZeros(result);
}

// this function divides the 1st operand by the 2nd, as in a long division, the optional parameter tells if it was called by you or by another function
string divide(string a, string b, bool originalCall = true)
{
    // this is to increase the precision before doing the calculations, thus it only rounds in the very end, if this was the original call (a boolean)
    precision += 5 * cast(int) originalCall;
    // this string will hold the quotient
    string result;

    // if 'a' is negative then you are dividing negative numbers, in which case we change the operations
    if (a[0] == '-')
    {
        // if 'b' is also negative then the result will be |'a'| / |'b'| because -x / -y = x / y
        if (b[0] == '-')
        {
            // calculate the result with the updated operands (no '-' sign anymore)
            result = divide(a[1 .. $], b[1 .. $], false);
            // this is to return the precision to its original value before returning, if this function was the original call (a boolean)
            precision -= 5 * cast(int) originalCall;

            // if the decimal part went beyond the precision
            if (split(result, '.')[1].length > precision)
                // round the last digit, with the 'roundLastDigit()' function
                roundLastDigit(result);

            // remove the doubled extra 0s, with the 'removeExtraZeros()' function, and then return it
            return removeExtraZeros(result);
        }
        // else, meaning only 'a' is negative then the result will be -(|'a'| / 'b') because -x / y = -(x / y)
        else
        {
            // calculate the result with the updated operands (no '-' sign anymore)
            result = '-' ~ divide(a[1 .. $], b, false);
            // this is to return the precision to its original value before returning, if this function was the original call (a boolean)
            precision -= 5 * cast(int) originalCall;

            // if the decimal part went beyond the precision
            if (split(result, '.')[1].length > precision)
                // round the last digit, with the 'roundLastDigit()' function
                roundLastDigit(result);

            // remove the doubled extra 0s, with the 'removeExtraZeros()' function, and then return it
            return removeExtraZeros(result);
        }
    }
    // else if only 'b' is negative then the result will be -('a' / |'b'|) because x / -y = -(x / y)
    else if (b[0] == '-')
    {
        // calculate the result with the updated operands (no '-' sign anymore)
        result = '-' ~ divide(a, b[1 .. $], false);
        // this is to return the precision to its original value before returning, if this function was the original call (a boolean)
        precision -= 5 * cast(int) originalCall;

        // if the decimal part went beyond the precision
        if (split(result, '.')[1].length > precision)
            // round the last digit, with the 'roundLastDigit()' function
            roundLastDigit(result);

        // remove the doubled extra 0s, with the 'removeExtraZeros()' function, and then return it
        return removeExtraZeros(result);
    }

    // organize them so that they will have the same number of decimal places, with the 'zeroing()' function
    zeroing(a, b);
    // remove the radix point so that they will be integers
    a = replace(a, ".", ""), b = replace(b, ".", "");
    // create a 'BigInt' version of the divisor because it makes the code cleaner than casting it many times later
    BigInt divisor = BigInt(b);

    // if something went wrong and you tried to divide by 0
    if (divisor == BigInt("0"))
    {
        // this is to return the precision to its original value before returning, if this function was the original call (a boolean)
        precision -= 5 * cast(int) originalCall;

        // return this error phrase
        return "Division by 0 is impossible.";
    }

    // define the result with the quotient, we start with the integer part of the quotient, there can be no 0s after the radix point here
    result = to!string(BigInt(a) / divisor) ~ '.';
    // create a variable to hold the remainder of the division and calculate it
    BigInt remainder = BigInt(a) % divisor;

    // start a loop to do the decimal part of the quotient according to the precision, for as long as there's a remainder and it's less than the precision
    for (int i; remainder > 0 && i++ < precision; remainder %= divisor)
    {
        // adjust the remainder in order to divide again, moving to the next decimal place value
        remainder *= BigInt("10");
        // divide it and store the result
        result ~= to!string(remainder / divisor);
    }

    // do it 1 last time in order to make sure it will have at least 1 digit after the radix point
    result ~= to!string(remainder * 10 / divisor);
    // this is to return the precision to its original value before returning, if this function was the original call (a boolean)
    precision -= 5 * cast(int) originalCall;

    // if the decimal part went beyond the precision
    if (split(result, '.')[1].length > precision)
        // round the last digit, with the 'roundLastDigit()' function
        roundLastDigit(result);

    // remove the doubled extra 0s, with the 'removeExtraZeros()' function, and then return it
    return removeExtraZeros(result);
}

// this function calculates modulos, the numbers must be both positive
string modulo(string a, string b)
{
    // remove the decimal part from the numbers, in order to make them integers
    a = split(a, '.')[0], b = split(b, '.')[0];

    // turn them into 'BigInt', calculate the modulo, turn it back into a string and add the decimal part, then return this result
    return to!string(BigInt(a) % BigInt(b)) ~ ".0";
}

// this function calculates powers, the exponent must be an integer and the optional parameter tells if it was called by you or by another function
string power(string base, string exponent, bool originalCall = true)
{
    // this is to increase the precision before doing the calculations, thus it only rounds in the very end, if this was the original call (a boolean)
    precision += 5 * cast(int) originalCall;

    // if the exponent isn't an integer (it would be okay for 2.0, for example)
    if (exponent[$ - 2 .. $] != ".0")
    {
        // this is to return the precision to its original value before returning, if this function was the original call (a boolean)
        precision -= 5 * cast(int) originalCall;

        // return this error message
        return "I can only calculate powers if the exponent is an integer.";
    }

    // this string will contain the result, it starts with the value of the base
    string result = base;

    // if the exponent is 0
    if (exponent == "0.0")
    {
        // this is to return the precision to its original value before returning, if this function was the original call (a boolean)
        precision -= 5 * cast(int) originalCall;

        // return 1.0 since all numbers to the 0th power result in 1.0
        return "1.0";
    }
    // else if the exponent is negative
    else if (exponent[0] == '-')
    {
        // we calculate the result as the inverse of the power with the positive exponent, we must call the 'power()' and the 'divide()' functions
        result = divide("1.0", power(base, exponent[1 .. $], false), false);
        // this is to return the precision to its original value before returning, if this function was the original call (a boolean)
        precision -= 5 * cast(int) originalCall;

        // if the decimal part went beyond the precision
        if (split(result, '.')[1].length > precision)
            // round the last digit, with the 'roundLastDigit()' function
            roundLastDigit(result);

        // remove the doubled extra 0s and return it
        return removeExtraZeros(result);
    }

    // if the exponent is no bigger than 7, then do it iteratively, it will be faster, notice we must convert it to a 'float' first
    if (to!float(exponent) <= 7.0)
    {
        // use a loop to multiply the base by itself a number of times equal to the exponent
        for (int i = to!int(exponent[0 .. $ - 2]); i > 1; i--)
            // multiply the base by itself
            result = multiply(result, base, false);
    }
    // else, meaning the exponent is bigger than 7, then do it with the Binary Exponentiation algorithm, it is much faster
    else
    {
        // create a variable which will contain the exponent as an 'int', notice we remove the decimal part first
        int exponentInt = to!int(exponent[0 .. $ - 2]);
        // create a string which will contain the result of the base multiplied by itself (we are applying the Binary Exponentiation algorithm)
        string product = multiply(base, base, false);
        // calculate the result by recursively calling this function with half the exponent (we are applying the Binary Exponentiation algorithm)
        result = power(product, to!string(exponentInt / 2) ~ ".0");

        // if the exponent was odd
        if (exponentInt % 2 == 1)
            // calculate the result multiplied by the base (we are applying the Binary Exponentiation algorithm)
            result = multiply(result, base);
    }

    // this is to return the precision to its original value before returning, if this function was the original call (a boolean)
    precision -= 5 * cast(int) originalCall;

    // if the decimal part went beyond the precision
    if (split(result, '.')[1].length > precision)
        // round the last digit, with the 'roundLastDigit()' function
        roundLastDigit(result);

    // remove the doubled extra 0s, with the 'removeExtraZeros()' function, and then return it
    return removeExtraZeros(result);
}

// this function is going to calculate roots, it only calculates roots of non-negative numbers, the index must be a positive integer and the optional
// parameter tells if it was called by you or by another function
string root(string radicand, string index, bool originalCall = true)
{
    // if the radicand or the index is negative or the index isn't a positive integer (it would work for 2.0, for example)
    if (radicand[0] == '-' || index[0] == '-' || index[$ - 2 .. $] != ".0" || index == "0.0")
        // return this error message
        return "I can't calculate roots of negative numbers and the index must be a positive integer.";

    // this is to increase the precision before doing the calculations, thus it only rounds in the very end, if this was the original call (a boolean)
    precision += 5 * cast(int) originalCall;
    // create the variables we will need when we find the number with a binary search and produce the most accurate result, notice the number will be
    // between 1.0 and the radicand (unless the radicand is less than 1.0), 'midPoint' and 'difference' must start as 1.0 for the loop which comes later
    string approxResult, midPoint = "1.0", difference = "1.0", lowerBound = "1.0", upperBound = radicand, limit = format("0.%0*d", precision, 1);

    // if the radicand is less than 1.0, in this case we multiply it by 10.0, take the root and then divide it by the root of 10.0, as in
    // sqrt(0.5) = sqrt(5 / 10) = sqrt(5) / sqrt(10)
    if (radicand[0] == '0')
    {
        // multiply the radicand by 10 and take the root, thus you find the numerator of the fraction, then calculate the denominator as the root of 10,
        // using the 'multiply()' and 'root()' functions
        string numerator = root(multiply(radicand, "10.0", false), index, false), denominator = root("10.0", index, false);
        // now divide the numerator by the denominator, using the 'divide()' function
        midPoint = divide(numerator, denominator, false);
    }
    // else, meaning the radicand is greater than or equal to 1.0
    else
    {
        // start a loop to keep finding a root that is more accurate until it reaches a difference <= precision, and the upper bound is not yet almost
        // identical to the lower bound, notice we use the 'addOrSubtract()' function
        while (difference > limit && addOrSubtract(upperBound, lowerBound, '-', false) > limit)
        {
            // calculate the midpoint by adding the lower and upper bounds and then dividing them by 2, with the 'addOrSubtract()' and 'divide()' functions
            midPoint = divide(addOrSubtract(lowerBound, upperBound, '+'), "2.0", false);
            // calculate an approximate result by doing the midpoint risen to a power which is equal to the index, with the 'power()' function
            approxResult = power(midPoint, index, false);
            // take the difference between the approximate result and the radicand, in order to see how close it got, with the 'addOrSubtract()' function
            difference = addOrSubtract(radicand, approxResult, '-', false);

            // if the difference was negative
            if (difference[0] == '-')
            {
                // then the result was too high, therefore the upper bound becomes the next midpoint, thus reducing the next result
                upperBound = midPoint;
                // remove the '-' sign (we want to know how close it got and therefore we want the absolute value)
                difference = difference[1 .. $];
            }
            // else, meaning the difference was positive
            else
                // then the result was too low, therefore the lower bound becomes the next midpoint, thus increasing the next result
                lowerBound = midPoint;
        }
    }

    // this is to return the precision to its original value before returning, if this function was the original call (a boolean)
    precision -= 5 * cast(int) originalCall;

    // if the decimal part went beyond the precision (the last midpoint is used as the result)
    if (split(midPoint, '.')[1].length > precision)
        // round the last digit, with the 'roundLastDigit()' function
        roundLastDigit(midPoint);

    // remove the doubled extra 0s, with the 'removeExtraZeros()' function, and then return it
    return removeExtraZeros(midPoint);
}

// this function lets you do any computations by typing the 1st operand, the operation symbol and the 2nd operand, thus making the code more understandable
string compute(string firstOperand, char operationSymbol, string secondOperand)
{
    // check which operation you are performing
    switch (operationSymbol)
    {
        // if you are adding numbers, then use the 'addOrSubtract()' function with an addition operator and return the value
        case '+': return addOrSubtract(firstOperand, secondOperand, '+');
        // if you are subtracting numbers, then use the 'addOrSubtract()' function with a subtraction operator and return the value
        case '-': return addOrSubtract(firstOperand, secondOperand, '-');
        // if you are multiplying numbers, then use the 'multiply()' function and return the value
        case '*': return multiply(firstOperand, secondOperand);
        // if you are dividing numbers, then use the 'divide()' function and return the value
        case '/': return divide(firstOperand, secondOperand);
        // if you are calculate the modulo of 2 numbers, then use the 'modulo()' function and return the value
        case '%': return modulo(firstOperand, secondOperand);
        // if you are calculating a power, then use the 'power()' function and return the value
        case '^': return power(firstOperand, secondOperand);
        // if you are calculating a root, then use the 'root()' function and return the value
        case 'r': return root(firstOperand, secondOperand);
        // if you've typed the wrong symbol, then create an error and display a message to instruct the user
        default: assert(0, "The compute() function only accepts 7 operation symbols: '+' (addition), '-' (subtraction), '*' (multiplication), '/' (division), '%' (modulo), '^' (power) and 'r' (root).");
    }
}
