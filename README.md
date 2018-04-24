# 04-2018-StepTransactions

Remember in this source filter, each step must be on a single line!!!
If you desire something more accommodating, consider yourself to be
empowered. This is only a proof of concept.

24-Apr-2018
  Tau Station's blog on 20-Apr-2018 announced a new behavior, ASSERT, and
gave a new example code snipet where the Oject of SubjectVerbObject could
be an anonymous hash. Title of blog post is "Extending Economic Exchange 
Conditions "

1. Made changes to the source filter
2. Updated 'Steps' function

   Assumptions
   
     ASSERT step(s) are grouped at the top.
     A grouping of FAILURE/ALWAYS step(s) signals a RDBMS transaction.
        i.e. There could be multiple RDMBS transactions.
3. Updated test program to have the latest code snipet.

Note: Did NOT update the markdown presentation, step.mdp.

