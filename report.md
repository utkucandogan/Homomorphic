The main purpose of this project is to implement a solution to the Tug of War problem under homomorphic encryption. Homomorphic encryption is done under Microsoft SEAL using Microsoft EVA on Python. Since Microsoft SEAL cannot do comparisons, we implemented a Trusted Third Party system. The main observation of this project is the time comparison between encrypted and unencrypted methods. It is observed that the implemented solution is much slower than the reference time observation.

Introduction
============

Tug of War is a set division problem where it is required to divide a set into two subsets with an equal number of elements where the difference of the sum of each subset element is minimum @Anand2022. The purpose of this project is to implement an algorithm to solve this problem under homomorphic encryption.

Homomorphic encryption is a method to encrypt data that allows us to execute certain operations without decrypting data @sealcrypto. This makes it possible for a server to execute algorithms for data without knowing the data itself. This increases the security of data and makes it possible to delegate calculations to the server without the concern of data exposure.

Homomorphic encryption of Microsoft SEAL only allows for certain operations such as addition, subtraction and multiplication. However, it does not allow to compare values with each other. Since a lot of algorithms require comparison, it is required to have a strategy for comparisons. We implemented this comparison using a trusted third party.

Since homomorphic encryption is relatively new, this problem is not studied enough.

My method consists of calculating all possible subset sums and giving them to Trusted Third Party, which executes comparison and finds the optimal solution.

Summary of Contributions
------------------------

-   Implementation of Tug of War algorithm solution with homomorphic encryption.

Background
==========

To understand the main algorithm we need to establish some definitions and classifications.

The client is the party that holds the values and wants a solution to the problem that we have. The Server is the party that will calculate the solution to the problem. It should not be aware of the values that the client has.

Microsoft SEAL cannot do comparisons under homomorphic encryption. To find a solution to most of the algorithms (including the Tug of War problem) we need to be able to do comparisons. To achieve that and still hide the values from the server, we have a trusted third party that can decrypt the homomorphic encryption and can do comparisons. To both hide the values from the trusted third party and delegate the least work, the server should do the most of the work possible.

Main Contribution
=================

The algorithm we designed to use will work in a loop of encryption, calculation, decryption and comparison [alg:ToW]. As the size of the set increases, the number of subsets to consider increases exponentially. Hence, it may not be appropriate to hold each value due to memory limitations. Due to the structure of Microsoft EVA, we have to recompile our algorithm and re-encrypt the data for every loop iteration.

regenerate $aa$ from $PrevI$

Results and Discussion
======================

Methodology
-----------

We simulated the algorithm using Microsoft EVA and measure how much time it takes to compile, encrypt, decrypt and execute. For different set element counts, we measured for 100 different sets and take the mean time. The code that is used is open source and available on Github @homomorphic.

Results
-------

We obtained the results and produce graphs for times and MSE. As we observe the , Key Generation Time and Execution Time take significantly longer than the other factors. This is due to the structure of our algorithm where we have to regenerate keys for each loop.

shows us a comparison between the total time that takes the algorithm to work under homomorphic encryption versus without homomorphic encryption. As we can see, encryption slows down our algorithm significantly. We can also observe that the required time increases exponentially. This is expected behavior as the solution for the Tug of War algorithm has the complexity of $O(2^n)$ @Anand2022.

Microsoft SEAL does not calculate the values exactly and it is important to know the error as it may cause results if it is too high. As we can observe from our error values are small enough to not cause errors in our algorithm.

[b]<span>.4</span> ![Graph of Times<span data-label="fig:Times"></span>](Figures/IndTimes.png "fig:"){width="linewidth"}

[b]<span>.4</span> ![Graph of Times<span data-label="fig:Times"></span>](Figures/TotalTimes.png "fig:"){width="linewidth"}

![Graph of Mean Square Errors<span data-label="fig:mse"></span>](Figures/Mse.png)

Discussion
----------

Our algorithm works under homomorphic encryption. However, the time it takes to calculate results may be too much for practical applications. Since we used small sets, we could obtain results. However, with larger sets, it becomes infeasible to use. If we have enough memory, we can eliminate much of the Key Generation Time.

Our algorithm also uses deterministic subset generation which is sent to the trusted third party. It may be more secure to randomize the indices for subsets.

Conclusion
==========

In conclusion, we have designed an algorithm for the Tug of War problem that can work under homomorphic encryption. We observed the performance of the said algorithm. As homomorphic encryption is relatively new, there is not much work done for a specific problem that we considered. However, the algorithm that we proposed may not be feasible for most situations as the time difference between unencrypted and encrypted algorithms rise too fast.
