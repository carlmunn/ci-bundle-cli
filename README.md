# CiBunde (WIP)

Name isn't that creative, a placeholder I guess.

Based on a script I made awhile ago that ran RSpec tests and emailed the results, this is just a more structured version. I refacted because the script was starting to show growing pains (scaling).

The basic process was:

 - Run script which forks another bash command that would then run RSpec etc.
 - Take the results and email them to people

The Reason for the script forking was it ran it's own ruby version. If the tests need a newer version then we would have all sorts of problems, usually dependencies. Bundler was also involved.

I'll get around to editing more of this README later. I tend to write documentation to have a break from coding.
