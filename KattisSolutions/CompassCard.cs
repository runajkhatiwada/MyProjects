using System;
using System.Collections.Generic;
using System.Linq;

namespace CompassCard
{
    public class Program
    {
        class CompassCard
        {
            public int r;
            public int g;
            public int b;
            public int id;
            public int uniqueness_r;
            public int uniqueness_g;
            public int uniqueness_b;
            public int agg_uniqueness;

            public CompassCard(int r, int g, int b, int id)
            {
                this.r = r;
                this.g = g;
                this.b = b;
                this.id = id;
            }
        }

        static void Main()
        {
            int n = 0;
            try
            {
                n = Convert.ToInt32(Console.ReadLine());
            }
            catch (Exception ex1)
            {
                Console.WriteLine(ex1);
                return;
            }

            if (n < 1 || n > 100000)
            {
                Console.WriteLine("Out of Range");
                return;
            }

            int r, g, b, id;
            List<CompassCard> list = new List<CompassCard>();
            int[] decision = new int[n];
            int[] check_id = new int[n];
            for (int i = 0; i < n; i++)
            {
                check_id[i] = -1;
            }

            for (int i = 0; i < n; i++)
            {

                string input = Console.ReadLine();
                string[] input_arr = input.Split(' ');
                try
                {
                    r = Convert.ToInt32(input_arr[0]);
                    g = Convert.ToInt32(input_arr[1]);
                    b = Convert.ToInt32(input_arr[2]);

                    if (r < 0 || r > 359 || g < 0 || g > 359 || b < 0 || b > 359)
                    {
                        Console.WriteLine("Angle Out of Range");
                        return;
                    }
                    id = Convert.ToInt32(input_arr[3]);
                    if (Array.IndexOf(check_id, id) != -1)
                    {
                        Console.WriteLine("Duplicate ID!!");
                        return;
                    }

                    check_id[i] = id;
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex);
                    return;
                }

                list.Add(new CompassCard(r, g, b, id));
            }

            if (n > 1)
                decision = checkUniqueness(list, n);
            else
                decision[0] = list[0].id;

            for (int i = 0; i < n; i++)
            {
                Console.WriteLine(decision[i]);
            }
        }

        static int[] checkUniqueness(List<CompassCard> list, int n)
        {
            int[,] angle = new int[n, 3];

            int[] angle_r = new int[n];
            int[] angle_g = new int[n];
            int[] angle_b = new int[n];
            int k = 0;
            foreach (var card in list)
            {

                angle[k, 0] = card.r;
                angle[k, 1] = card.g;
                angle[k, 2] = card.b;
                k++;
            }


            for (int i = 0; i < n; i++)
            {

                angle_r[i] = angle[i, 0];
                angle_g[i] = angle[i, 1];
                angle_b[i] = angle[i, 2];

            }

            Array.Sort(angle_r);
            Array.Sort(angle_g);
            Array.Sort(angle_b);
            int[] uniqueness_r = new int[n];
            int[] uniqueness_g = new int[n];
            int[] uniqueness_b = new int[n];

            uniqueness_r = calcUniqueness(angle_r);
            uniqueness_g = calcUniqueness(angle_g);
            uniqueness_b = calcUniqueness(angle_b);

            k = 0;
            foreach (var card in list)
            {
                card.uniqueness_r = uniqueness_r[Array.IndexOf(angle_r, card.r)];
                card.uniqueness_g = uniqueness_g[Array.IndexOf(angle_g, card.g)];
                card.uniqueness_b = uniqueness_b[Array.IndexOf(angle_b, card.b)];
                card.agg_uniqueness = card.uniqueness_r + card.uniqueness_g + card.uniqueness_b;
                k++;
            }
            k = 0;
            var cardOrder = new Dictionary<int, int>();

            foreach (var card in list)
            {
                cardOrder.Add(card.id, card.agg_uniqueness);
            }

            int[] ouput_arr = new int[n];
            k = 0;
            foreach (KeyValuePair<int, int> pair in cardOrder.OrderBy(value => value.Value).ThenByDescending(key => key.Key))
            {   
                ouput_arr[k] = pair.Key;
                k++;
            }

            return ouput_arr;
        }

        static int[] calcUniqueness(int[] i)
        {
            int a = 0, c = 0;
            int len = i.Length;
            int[] uniqueness = new int[len];

            for (int k = 0; k < len; k++)
            {
                if (k == 0)
                {
                    a = 360 - (i[len - 1] - i[0]);
                    c = i[1] - i[0];
                }
                else if (k < (len - 1))
                {
                    a = i[k] - i[k - 1];
                    c = i[k + 1] - i[k];
                }
                else
                {
                    a = i[k] - i[k - 1];
                    c = 360 - (i[k] - i[0]);
                }

                a = (a == 360 || a == -360) ? 0 : a;
                c = (c == 360 || c == -360) ? 0 : c;
                uniqueness[k] = a + c;
            }
            return uniqueness;
        }
    }
}