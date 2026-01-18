# Living in the Quantum Era

This policy mandates requirements needed for Arcanyx to survive the "Quantum Day" meaning the first successful brute force attack against modern cryptographic algorithm done by a quantum computer, for the sake of cryptographic safety we assume that this day already happen so that if it ever happened before this policy that our infrastructure is prepared to mitigate it.

### Terminology

* T.0. IND-CCA2 stands for "Indistinguishability under Adaptive Chosen Ciphertext Attack", a strong security standard for encryption ensures that secure system prevents an adversary from distinguishing between two different messages after the adversary has the ability to query a decryption oracle for any ciphertext of their choice, even after receiving a "challenge" ciphertext.
* T.1. "Kyber" means "CRYSTALS-Kyber" an IND-CCA2-secure key encapsulation mechanism (KEM)
* T.2. "NTRU Prime" is small lattice-based KEM aiming for the standard goal of IND-CCA2 security

### Threat model

#### Harvesting Age Keys
As explained in Ref.3 and Ref.4 in detail it's very easy to download all `.age` files from GitHub for Harvest Now, Decrypt later (also called "Store Now, Decrypt Later") which we are as of 231025 using right now. Anyone can easily download these keys and decrypt them if they have a resourceful enough quantum computer which would be done without our knowledge.

### Mandates
Pending..

### References

1. The Crypto blog "The inability to count correctly" article: https://blog.cr.yp.to/20231003-countcorrectly.html
2. SimpleX retionales for NTRU Prime over Kyber: https://simplex.chat/blog/20240314-simplex-chat-v5-6-quantum-resistance-signal-double-ratchet-algorithm.html
3. Discussion about PQC in age repository: https://github.com/FiloSottile/age/discussions/231
4. Administrator's highlights of the issue: https://github.com/FiloSottile/age/issues/578
