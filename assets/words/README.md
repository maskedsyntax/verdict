# Word data

The generated word lists use SCOWL release `rel-2026.02.25`:

https://github.com/en-wl/wordlist/releases/tag/rel-2026.02.25

`valid_words.txt` is generated from SCOWL size 80, American spelling, variant
level 6, excluding abbreviations. `answers.txt` is generated from SCOWL size
35, American spelling, variant level 1. Both outputs are restricted to exactly
five lowercase ASCII letters, which excludes capitalized names and punctuation.
The committed answer pool receives a deterministic shuffle so dates do not
progress alphabetically. Its order must remain append-only after release.

The exact source license is bundled at `assets/licenses/SCOWL_COPYRIGHT.txt`.
The answer pool should receive an additional editorial fairness review before
store release.
