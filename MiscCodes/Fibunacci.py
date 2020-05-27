def get_fibunacci(length):
    if length <= 1:
        return length
    else:
        return get_fibunacci(length-1) + get_fibunacci(length-2)
        
num = int(input('Give the length for series:' ))

print ('Fibunacci Series:')
for i in range(num):
    print(get_fibunacci(i))
