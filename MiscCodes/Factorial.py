def get_factorial(value):
    factorial = 1

    if num > 0:
        for i in range(1, num + 1):
            factorial = factorial * i
    
    return factorial

num = int(input('Please enter the number: '))
print ('The factorial of ', num, ' is : ', get_factorial(num))