using System;
using System.IO;

namespace MathPracticer
{
    class Program
    {
        static void Main(string[] args)
        {
            // create a Random object to generate random numbers:
            Random rnd = new Random();
            // initialize variables to keep track of correct answers, total questions, and game status
            int numCorrect = 0;
            int numQuestions = 0;
            bool stopGame = false;

            // ask the user to select a difficulty level
            Console.WriteLine("Select a difficulty level (easy, medium, or hard):");
            string difficulty = Console.ReadLine();

            // determine the range of the random numbers based on the selected difficulty level
            int minRange, maxRange;
            switch (difficulty)
            {
                case "easy":
                    minRange = 1;
                    maxRange = 10;
                    break;
                case "medium":
                    minRange = 10;
                    maxRange = 100;
                    break;
                case "hard":
                    minRange = 100;
                    maxRange = 1000;
                    break;
                default:
                    Console.WriteLine("Invalid difficulty level. Defaulting to easy.");
                    minRange = 1;
                    maxRange = 10;
                    break;
            }

            // Start the game loop:
            while (!stopGame)
            {
                // generate two random numbers and an operator
                int num1 = rnd.Next(minRange, maxRange + 1);
                int num2 = rnd.Next(minRange, maxRange + 1);
                int answer = 0;
                char operation = (char)rnd.Next(3);

                // print the math question based on the operator
                switch (operation)
                {
                    case (char)0:
                        Console.Write($"{num1} + {num2} = ");
                        answer = num1 + num2;
                        break;
                    case (char)1:
                        // for subtraction, make sure the answer is positive
                        Console.Write($"{num1} - {num2} = ");
                        answer = num1 - num2;
                        while (answer < 0)
                        {
                            num1 = rnd.Next(minRange, maxRange + 1);
                            num2 = rnd.Next(minRange, maxRange + 1);
                            Console.Write($"{num1} - {num2} = ");
                            answer = num1 - num2;
                        }
                        break;
                    case (char)2:
                        Console.Write($"{num1} * {num2} = ");
                        answer = num1 * num2;
                        break;
                }

                // get user input and check if it's correct
                int userAnswer = Convert.ToInt32(Console.ReadLine());
                if (userAnswer == answer)
                {
                    Console.WriteLine("Correct");
                    numCorrect++;
                }
                else
                {
                    Console.WriteLine($"Wrong, should be {answer}");
                }

                // increase the total number of questions asked
                numQuestions++;

                // ask the user if they want to continue or stop the game
                Console.WriteLine("Type 'stop' to end the game or press Enter to continue.");
                string input = Console.ReadLine();
                if (input == "stop")
                {
                    stopGame = true;
                }
            }

            // print the user's score and percentage
            Console.WriteLine($"You answered {numCorrect} out of {numQuestions} questions correctly.");
            Console.WriteLine($"Percentage: {numCorrect * 100.0 / numQuestions}%");

            // ask the user if they want to save their results to a file
            Console.WriteLine("Do you want to save your results to a file? (yes/no)");
            string saveToFile = Console.ReadLine();
            if (saveToFile == "yes")
            {
                // ask the user for a file name
                Console.WriteLine("Enter a file name:");
                string fileName = Console.ReadLine();
                // create a StreamWriter to write the results to the file
                StreamWriter writer = new StreamWriter(fileName);

                // write the user's score and percentage to the file
                writer.WriteLine($"You answered {numCorrect} out of {numQuestions} questions correctly.");
                writer.WriteLine($"Percentage: {numCorrect * 100.0 / numQuestions}%");

                // close the StreamWriter
                writer.Close();

                // let the user know that the results were saved
                Console.WriteLine($"Results saved to {fileName}");
            }

            // wait for the user to press Enter before closing the console window
            Console.ReadLine();
        }
    }
}
