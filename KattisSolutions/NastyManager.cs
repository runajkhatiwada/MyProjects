using System;

public class Program
{
    public static void Main()
    {
        byte n; // number of cases
        n = Convert.ToByte(Console.ReadLine()); // casting the input cases into integer
        for (byte i = 1; i <= n; i++) // running the iteration for n number of times
        {
            string input = Console.ReadLine(); // input line add the values by giving the space after each input for r e and c
            string[] input_arr = input.Split(' ');
            int r = Convert.ToInt32(input_arr[0]); //expected revenue without advirtisement
            int e = Convert.ToInt32(input_arr[1]); //expected revenue with advirtisement
            int c = Convert.ToInt32(input_arr[2]); //advertisement cost
                
            int difference_in_revenue = r - (e - c); // calculating the difference in revenue

            if (difference_in_revenue < 0) //if difference is in negative then we need to advertisement
                Console.WriteLine("advertise\n");
            else if (difference_in_revenue > 0) //if difference is in positive then we should not advertisement
                Console.WriteLine("do not advertise\n");
            else // if there is no differene, then it does not really matter
                Console.Write("does not matter\n");            
        }
    }
}