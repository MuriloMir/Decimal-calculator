// This module has functions to do calculations using the decimal system, thus eliminating errors due to the imprecise binary system.
module decimalcal;

import std.algorithm.searching : canFind;
import std.array : replace, split;
import std.bigint : BigInt;
import std.conv : to;
import std.string : format;

// this function adds the necessary padding zeros
void zeroing(ref string a, ref string b)
{
    // choosing the longest one, we check if it is the integer or the decimal part
    if (a.length < b.length)
        while (a.length < b.length)
            if (canFind(a, '.'))
                a ~= '0';
            else
                a = '0' ~ a;
    else
        while (b.length < a.length)
            if (canFind(b, '.'))
                b ~= '0';
            else
                b = '0' ~ b;
    // in case the numbers are negative, the loop above pushed the "-" sign away
    if (canFind(a, '-'))
        a = '-' ~ replace(a, "-", "");
    if (canFind(b, '-'))
        b = '-' ~ replace(b, "-", "");
}

// this function organizes the numbers so they will have the same number of place values
void organize(ref string a, ref string b)
{
    // this is to remove a possible "+" sign in front of the numbers
    if (a[0] == '+')
        a = a[1 .. $];
    if (b[0] == '+')
        b = b[1 .. $];
    // in case there is no radix point
    if (!canFind(a, '.'))
        a ~= '.';
    if (!canFind(b, '.'))
        b ~= '.';
    // in case there is no integer digit before the radix point
    if (a[0] == '.')
        a = '0' ~ a;
    if (b[0] == '.')
        b = '0' ~ b;
    // in case you write a number like "-.08", we must add a 0 before the radix point
    if (a[0] == '-' && a[1] == '.')
        a = "-0" ~ a[1 .. $];
    if (b[0] == '-' && b[1] == '.')
        b = "-0" ~ b[1 .. $];
    // breaking the strings into integer and decimal part
    string[2] aPieces = split(a, '.'), bPieces = split(b, '.');
    // selecting the integer and decimal part
    string opaInt = aPieces[0], opaDec = '.' ~ aPieces[1];
    string opbInt = bPieces[0], opbDec = '.' ~ bPieces[1];
    // adding the necessary padding zeros to the numbers
    zeroing(opaDec, opbDec);
    zeroing(opaInt, opbInt);
    // updating the operands with their organized form
    a = opaInt ~ opaDec;
    b = opbInt ~ opbDec;
}

// this function pushes the radix point to the very end
void bubbleRadixes(ref string a, ref string b)
{
    a = replace(a, ".", "") ~ '.';
    b = replace(b, ".", "") ~ '.';
}

// this function adds the operands
string add(string a, string b)
{
    // this is how many decimal places it is able to show, it rounds the last one only if it reaches this limit
    int precision = 21;
    // first we organize them so they will have the same number of decimal places
    organize(a, b);
    // now we store the number of decimal places that will be removed from both of them to make them integers
    ulong n = split(a, '.')[1].length;
    // here we bubble the radix point so they will be integers
    bubbleRadixes(a, b);
    // now we store the number's size (without the radix point)
    ulong size = a.length - 1;
    // here we create the result string with the sum of the operands as integers
    string result = to!string(BigInt(a[0 .. $ - 1]) + BigInt(b[0 .. $ - 1]));
    // this is for cases when you add something like 0.0001 + 0.0002
    while (result.length < size)
        result = '0' ~ result;
    // this is to check if the result was negative so we can work with the "-" sign
    bool negative = canFind(result, '-');
    // this is for the case when there was a "-" sign in the result, the loop above just pushed it away from the beginning
    if (negative)
        result = '-' ~ replace(result, "-", "");
    // now we add the radix point in the correct place
    n = result.length - n;
    result = result[0 .. n] ~ '.' ~ result[n .. $];
    // this is to round the last digit and remove it afterwards, we make sure it doesn't create an infinite recursion
    if (split(result, '.')[1].length >= 21)
    {
        result = result[0 .. $ - (split(result, '.')[1].length - 21)];
        if (result[$ - 1] >= '5')
            result = add(result[0 .. $ - 1], "0.00000000000000000001");
        else
            result = result[0 .. $ - 1];
    }
    // this is to make sure it has at least 1 digit before and after the radix point
    if (result[$ - 1] == '.')
        result ~= '0';
    else if (result[0] == '.')
        result = '0' ~ result;
    return result;
}

// this function subtracts the operands
string subtract(string a, string b)
{
    // this is how many decimal places it is able to show, it rounds the last one only if it reaches this limit
    int precision = 21;
    // first we organize them so they will have the same number of decimal places
    organize(a, b);
    // now we store the number of decimal places that will be removed from both of them to make them integers
    ulong n = split(a, '.')[1].length;
    // here we bubble the radix point so they will be integers
    bubbleRadixes(a, b);
    // now we store the number's size (without the radix point)
    ulong size = a.length - 1;
    // here we create the result string with the difference of the operands as integers
    string result = to!string(BigInt(a[0 .. $ - 1]) - BigInt(b[0 .. $ - 1]));
    // this is for cases when you subtract something like 0.0002 - 0.0001
    while (result.length < size)
        result = '0' ~ result;
    // this is to check if the result was negative so we can work with the "-" sign
    bool negative = canFind(result, '-');
    // this is for the case when there was a "-" sign in the result, the loop above just pushed it away from the beginning
    if (negative)
        result = '-' ~ replace(result, "-", "");
    // now we add the radix point at the correct place, notice the length of the result here may be different from before
    // in case you subtract 2 positive numbers and the result is negative, in this case the "-" sign will make it longer
    n = result.length - n;
    result = result[0 .. n] ~ '.' ~ result[n .. $];
    // this is to round the last digit and remove it afterwards
    if (split(result, '.')[1].length >= 21)
    {
        result = result[0 .. $ - (split(result, '.')[1].length - 21)];
        if (result[$ - 1] >= '5')
            result = add(result[0 .. $ - 1], "0.00000000000000000001");
        else
            result = result[0 .. $ - 1];
    }
    // this is in cases when you subtract negative numbers, the result turns out positive and you are left with an extra 0
    if (result[0] == '0')
        result = result[1 .. $];
    // this is to make sure it has at least 1 digit before and after the radix point
    if (result[$ - 1] == '.')
        result ~= '0';
    else if (result[0] == '.')
        result = '0' ~ result;
    return result;
}

// this function multiplies the operands
string multiply(string a, string b)
{
    // this is how many decimal places it is able to show, it rounds the last one only if it reaches this limit
    int precision = 21;
    // first we organize them so they will have the same number of decimal places
    organize(a, b);
    // now we store the number of decimal places that will be removed from both of them to make them integers
    ulong n = split(a, '.')[1].length * 2;
    // here we bubble the radix point so they will be integers
    bubbleRadixes(a, b);
    // now we multiply them as integers and store as a string
    string result = format(format("%%0%dd", n + 1), BigInt(a[0 .. $ - 1]) * BigInt(b[0 .. $ - 1]));
    // now we add the radix point at the correct place
    n = result.length - n;
    result = result[0 .. n] ~ '.' ~ result[n .. $];
    // this is to make sure it doesn't have unnecessary zeros at the end
    while (result[$ - 1] == '0')
        result = result[0 .. $ - 1];
    // this is to round the last digit and remove it afterwards
    if (split(result, '.')[1].length >= 21)
    {
        result = result[0 .. $ - (split(result, '.')[1].length - 21)];
        if (result[$ - 1] >= '5')
            result = add(result[0 .. $ - 1], "0.00000000000000000001");
        else
            result = result[0 .. $ - 1];
    }
    // this is to make sure it has at least 1 digit before and after the radix point
    if (result[$ - 1] == '.')
        result ~= '0';
    else if (result[0] == '.')
        result = '0' ~ result;
    return result;
}

// this function divides the second operand into the first as in a long division
string divide(string a, string b)
{
    // this is how many decimal places it is able to show, it rounds the last one only if it reaches this limit
    int precision = 21;
    // first we organize them so they will have the same number of decimal places
    organize(a, b);
    // here we bubble the radix point so they will be integers
    bubbleRadixes(a, b);
    // here I create an integer version of the divisor because it makes the code cleaner than casting it many times
    BigInt divisor = BigInt(b[0 .. $ - 1]);
    if (divisor == 0)
        return "division by 0 is impossible";
    //the string that holds the quotient, we start with the integer part of the quotient
    string result = to!string(BigInt(a[0 .. $ - 1]) / divisor) ~ '.';
    // here we do the decimal part of the quotient according to the precision passed as argument
    for (BigInt rest = BigInt(a[0 .. $ - 1]) % divisor; rest && precision--; rest %= divisor)
    {
        rest *= 10;
        result ~= to!string(rest / divisor);
    }
    // this is to round the last digit and remove it afterwards
    if (split(result, '.')[1].length >= 21)
    {
        result = result[0 .. $ - (split(result, '.')[1].length - 21)];
        if (result[$ - 1] >= '5')
            result = add(result[0 .. $ - 1], "0.00000000000000000001");
        else
            result = result[0 .. $ - 1];
    }
    // this is to make sure it has at least 1 digit before and after the radix point
    if (result[$ - 1] == '.')
        result ~= '0';
    else if (result[0] == '.')
        result = '0' ~ result;
    return result;
}
