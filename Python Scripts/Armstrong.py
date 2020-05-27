num = int(input('Please Give the number:'))

def check_armstrong(value):
    sum = 0
    temp = value
    while(temp > 0):
        digit = temp % 10
        sum += digit**3
        temp //= 10
    
    if value == sum:
        return True
    else:
        return False

if check_armstrong(num):
    print ('It is an Armstrong Number')
else:
    print ('It is not an Armstrong Number')