def add(*x):
    return x[0] + x[1]
    
def substract(*x):
    return x[0] - x[1]

def multiply(*x):
    return x[0] * x[1]

def divide(*x):
    return x[0] / x[1]

print ('Please choose your choice')
operator = input ('''
    Press 1 for Addition
    Press 2 for Substraction
    Press 3 for Multiplication
    Press 4 for Division
''')

if int(operator) > 4 or int(operator) < 1:
    print('Invalid Choice')
    exit ()
    
a = int(input('Please enter the first number: '))
b = int(input('Please enter the second number: '))

if operator == '1':
    print (a, " + ", b, " = ", add(a,b))
elif operator == '2':
    print (a, " - ", b, " = ", substract(a,b))
elif operator == '3':
    print (a, " * ", b, " = ", multiply(a,b))
elif operator == '4':
    print (a, " / ", b, " = ", divide(a,b))
else:
    print ('no option')