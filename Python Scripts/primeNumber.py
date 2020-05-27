given_number = input('Please insert your number: ')
given_number = int(given_number)

def is_prime(num):
    if num > 1:
        for i in range(2, num):
            if (num % i) == 0: return False
        else: return True
    else: return False

if is_prime(given_number):
    print ('It is prime number')
else:
    print ('It is not a prime number')