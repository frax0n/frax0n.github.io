---
date: 2024-11-13 20:05:26
layout: post
title: "Generating Random Numbers"
subtitle: "Exploring the mechanics behind random number generators (RNGs), this article delves into their design, highlights their unpredictability, and recounts an experiment with a simple RNG implementation."
description: "Exploring the mechanics behind random number generators (RNGs), this article delves into their design, highlights their unpredictability, and recounts an experiment with a simple RNG implementation."
image: /assets/img/rng/Cover.png
optimized_image:
category: code
tags:
author:
paginate: false
---



# Exploring Random Number Generators 

Have you ever wondered how random number generators (RNGs) in computers work? It’s fascinating that these algorithms can produce sequences that seem so unpredictable, even though numbers often follow patterns. We often use RNG libraries without questioning their inner workings or appreciating the brilliance behind their design. So, I decided to dive into the mechanics of RNGs and experiment with implementing one myself.

First Attempt: A Simple RNG Generator

I started with a straightforward approach to RNG:

random_number = seed * seed / primeNumber

Here, the generated random number becomes the seed for the next iteration. However, as expected, this method quickly revealed its flaws. It tended to follow a discernible pattern, making it less "random" than ideal. To visualize this, I implemented a simple random traversal algorithm:

## Random Traversal Implementation
``` C++
void RandomTraverse::RandomTraverseSimple() {
    double randomNumber = static_cast<int>((this->seed * this->seed)) % 9973;
    double rand = randomNumber;
    randomNumber = static_cast<int>(randomNumber) % 360;

    Vector2 point = this->points.back();
    float x = point.x;
    float y = point.y;

    float rad = randomNumber * (PI / 180.0f);
    float newX = x + (length * cos(rad));
    float newY = y + (length * sin(rad));

    newX = static_cast<int>(newX + screenWidth) % screenWidth;
    newY = static_cast<int>(newY + screenHeight) % screenHeight;
    
    std::cout << randomNumber << " ";
    this->points.push_back({newX, newY});
    this->seed = static_cast<double>(rand);
    std::this_thread::sleep_for(std::chrono::milliseconds(25));

    this->Draw();
}
```
Here’s a breakdown of what happens:

The random number is computed by squaring the seed and taking the modulus with a prime number (9973 in this case).

This random number determines the angle for movement.

New points are calculated using trigonometric functions and adjusted to stay within screen bounds.

Points are stored and drawn sequentially.

## The Draw Function

The Draw function renders the points and connects them with lines:
``` C++
void RandomTraverse::Draw() {
    for (size_t i = 1; i < points.size(); ++i) {
        int pseudoLength = PointDistance(this->points[i - 1], this->points[i]);
        int distCentre = PointDistance({screenWidth / 2, screenHeight / 2}, this->points[i - 1]);

        if ((pseudoLength > this->length + 100) || (distCentre > 4000)) {
            this->skipIteration = true;
            continue;
        }

        DrawLineEx(this->points[i - 1], this->points[i], 2, GRAY);
        DrawCircle(this->points[i - 1].x, this->points[i - 1].y, 2.0, DARKGRAY);
    }
}
```
This function ensures:

The traversal stays within bounds.

Points don’t visually "jump" across the screen width or height.

The path is confined within a central circle for aesthetic purposes.

The result looks beautiful in motion, especially when visualizing the traversal over time.

Observing Patterns

At first glance, the random traversal appears sufficiently unpredictable. Larger step sizes create visually appealing results:

![Alt text](/assets/img/rng/simpleZoomedIn.gif)

However, zooming out reveals underlying patterns:

![Alt text](/assets/img/rng/simpleZoomedOut.gif)

The patterns make the traversal predictable—not ideal for a true RNG.
The lack of adjustable parameters to control the period of repetion is evident.

## Moving Forward: Linear Congruential Generator (LCG)

To address these shortcomings, the next step involves implementing a Linear Congruential Generator (LCG). LCGs are among the simplest and most widely used RNG algorithms. They rely on the following recurrence relation:

The **Linear Congruential Generator (LCG)** is one of the simplest and most commonly used random number generation algorithms. Its operation is based on the following formula:
\(Xn+1=aXn+c\)
Where:

- \(X_n\): The current state (or seed).
- \(a\): The multiplier.
- \(c\): The increment.
- \(m\): The modulus (the range of generated numbers).

``` Cpp
void RandomTraverse :: TranverseLCG(){

    int a = 16645; 
    int c = 101390; 
    int m = 4332; 
    long long result = static_cast<long long>(a) * this->seed + c; 

    long long modResult = result % m;

    
    if (modResult > INT_MAX) {
        modResult -= m;  
    }
    double randomNumber = static_cast<int>(modResult);

    randomNumber = static_cast<int>(randomNumber) % 360;

    Vector2 point = this->points.back();
    float x = point.x;
    float y = point.y;

    float rad = randomNumber * (PI / 180.0f);
    float newX = x + (length * cos(rad));
    float newY = y + (length * sin(rad));

    newX = static_cast<int>(newX + screenWidth) % screenWidth;
    newY = static_cast<int>(newY + screenHeight) % screenHeight;
    std::cout<<randomNumber<<" ";
    this->points.push_back({newX, newY});
    this->seed = static_cast<double>(modResult);
    std::this_thread::sleep_for(std::chrono::milliseconds(25));

    this->Draw();
}
```
![Alt text](/assets/img/rng/LCG.gif)


using this we can still predict where the pattern will lead a general direction, the period of exact repetion is significantly larger , Even though it might seem the pattern is repeating but there are subtle differences but the bias is clear.

## BitShift XOR Shift

So the search continues , well what does the library use 
if you have c++ you might have used std::mt19937
this is the Mersenne Twister

While I'm not employing the complexity of Mersenne Twister at the moment maybe later but the core concept remains the same but apply to an array created using the seed and deriving the result from that.
```C++
void RandomTraverse :: RandomTraverseBitShift() {
    this->seed = static_cast<int>(this->seed) ^ (static_cast<int>(this->seed) << 13);
    this->seed = static_cast<int>(this->seed) ^ (static_cast<int>(this->seed) >> 17);
    this->seed = static_cast<int>(this->seed) ^ (static_cast<int>(this->seed) << 5);

    double randomNumber = static_cast<int>(this->seed) % 360;

    Vector2 point = this->points.back();
    float x = point.x;
    float y = point.y;

    float rad = randomNumber * (PI / 180.0f);
    float newX = x + (length * cos(rad));
    float newY = y + (length * sin(rad));

    newX = static_cast<int>(newX + screenWidth) % screenWidth;
    newY = static_cast<int>(newY + screenHeight) % screenHeight;

    std::cout << randomNumber << " ";

    this->points.push_back({newX, newY});

    std::this_thread::sleep_for(std::chrono::milliseconds(25));

    this->Draw();
}
```

![Alt text](/assets/img/rng/Bitshift.gif)

This implementation introduces randomness through XOR operations and bit-shifting, effectively scrambling the bits of the seed. The result is a much less predictable sequence of numbers.


## Improve statistical randomness


Here comes an end to pursuit for understanding random numbers for now.
A true random number could be generated not using math or something predictable but using our surroundings

Like the cloudflare lavalamp wall or this website which generates Random number using atmospheric noise which is truly unpredictable , Entropy around is the best source , I actually thought of employing time to randomize it further based on cpu cycles but theres only so much uncertainity , while its true the same operation might take few nanoseconds here and there which might have randomness but then the gap is not large enough to be reliable. 


Huge Kudos to Raysan for making Raylib for experimentation , I dont need to write OpenGL code for drawing pixels and rendering models. (Which I have no idea about , Would love to do it if I'm paid for it)

I made a stupid SineWave lets see if I can create a shader file to actually use GPU to render it, Find out in the next episode of DragonBall Z

All my code is present in Vizcpp repository in Github under frax0n, Main branch might be behind cause most of the commits are in windows and MacOs is seriously behind.