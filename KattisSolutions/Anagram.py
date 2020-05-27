import fileinput
##################################Logic###########################################

#                      N! (Total Factorial of String including duplicates)
# Anagram Count => ------------------------------------------------------------
#                  DuplicateCount1! * DuplicateCount1! * .... * DuplicateCountN!

##################################Logic###########################################

def get_fact(num): #recursive function to calculate factorial of n
    if num <= 1: #Base case 
        return 1
    else:
        return num * get_fact(num-1) #self call to the function

def sum_of_duplicate_factorials(input_str): #function to calulate the value of sub factorial for denominator [DuplicateCount1! * DuplicateCount1! * .... * DuplicateCountN!]
    input_arr_asci = []
    
    for i in range(len(input_str)):
        input_arr_asci.append(ord(input_str[i]))
    
    duplicate_count = [] #define the array to store the duplicate counts
    sub_factorial = 1 #set the value as 1 by default
    count = {}
    
    for s in input_arr_asci: #run loop to find duplicate chars in the string
      if s in count:
        count[s] += 1
      else:
        count[s] = 1

    for key in count: #append the count of duplicate_count in new array
      if count[key] > 1:
        duplicate_count.append(count[key])
    
    for i in range(len(duplicate_count)):
        sub_factorial = sub_factorial * duplicate_count[i]
    
    return sub_factorial

for line in fileinput.input(): #ask for input string
    line = line[:-1]
    total = get_fact(len(line)) # calculate N! using recursive get_factorial function
    sub_factorial = sum_of_duplicate_factorials(line) #calculate the value of sub factorial for denominator
    anagram_count = total//sub_factorial #use the formula to calculate anagram count

    print(anagram_count) #Give the output