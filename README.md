## Admin Airdrop

Given the high degree of centralisation — with only the single admin granting access to claiming — this project is heavily flawed.

However, it was used to practice and understand the role of signatures in airdrops and EIP-721 transactions.

**Project Features:**

- Admin generates a digest to allow a user to claim a certain amount of Gold Token. This is done via the getMessageHash() function.
- The admin then signs the digest.

- The claimer then calls claim(), entering the (v, r, s) — which the admin would provide to the claimer.
- The contract then validates the signature, which calls \_isValidSignature (which contains ECDSA.tryRecover()). It then compares the actual signer with the admin. If they are the same, we can conclude the admin signed the digest.
- The user is authorised to claim Gold Tokens in the quantity requested.
