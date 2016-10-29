# CiBunde (WIP)

Doesn't isn't that creative, a placeholder I guess.

Based on a script I made awhile ago that ran RSpec tests and emailed the result. This is just a more structured version. I refacted because the script was starting to show growing pains (scaling).

The basic process was:

 - Run script wrapper which would fork another bash command that would then run RSpec etc.
 - Take the results and email them to people

The Reason for the forking was the script ran it's own ruby version. If the tests need a newer version then we would have all sorts of problems. usually dependencies. Bundler was also involved.

I'll get around to editing more of this README file later. I tend to write documentation to have a break from coding.
