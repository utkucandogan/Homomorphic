# Homomorphic
Tug of War algorithm implemented in privacy-preserving manner using homomorphic encryption (Microsoft EVA).

Tug of War algorithm works by calculating every possible sums of each subset and finding the minimum absolute difference with the half of total sum.
Algorithm under homomorphic encryption works basically:
  1. Client encrypts values and sends them to server.
  2. Server chooses one subset division and calculates its sum.
  3. Server calculates total sum and halves it.
  4. Server calculates the difference.
  5. Server sends the calculated difference and subset index to trusted third party.
  6. Trusted third party decrypts the value and takes absolute value.
  7. Trusted third party compares it with previous result and updates the result and index with minimum value.
  8. Process continues until all subsets are considered.
  9. Finally trusted third party sends back the index and server/client can regenerate subset with it.

The code itself does not clearly differentiate between client, server and trusted third party and they are considered more like a concept.
