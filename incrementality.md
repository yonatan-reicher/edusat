# Notes On Implementing Incrementality

Incrementality is implemented via adding special variables called "selectors".
Each selector appears exactly in one clause, and only at the end. Selectors
are not looked at when making decision.

## How it works

A clause is active only if it's selector is active. This is achieved by having
the selector appear in a negative literal at the end of the clause.
