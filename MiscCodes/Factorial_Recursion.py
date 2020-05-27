import collections

string = "Hello world"
frequencies = collections.Counter(string)
duplicate_count = []

for key, value in frequencies.items():
    if value > 1:
        duplicate_count.append(value)



print(duplicate_count)


'''
def get_fact(num):
    if num <= 1:
        return 1
    else:
        return num * get_fact(num-1)
    
print (get_fact(100))
'''