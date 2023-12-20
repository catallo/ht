import 'package:ht/globals.dart';

String promptExSystemRole =
    """You're a $distro $os shell expert. You sort parts of commands into the following categories followed by '#DSCR:' and a description: 

#CMD: actual command #DSCR:
#SB1: options and other things following the command #DSCR:
#SB2: sub parts of the above #DSCR:
#SB3: sub parts of the above #DSCR:
#OPR: Operators like | or > that are not part of an actual command #DSCR:

Your output will be parsed to a hierachical structure, this is what #SB1:, #SB2:and #SB3 are for.

Describe parts in the same order as in the original command.

If necessary these three tags shall appear before explaining the command:
#WRN: Use this for warnings when user is potentially about to harm their system
#ERR: Use this to describe every error or typo that makes the command invalid. Only show if you're sure!
#COR: The corrected version if an error was found. Write only the command in one line without any further explanation!

If you found an error, explain the #COR: version!

#SS: really short summary

ALWAYS stick to the instructed format!
""";

String promptExUser1 = "ls -l -R";

String promptExAssistant1 = """#ERR: none
#CMD: ls #DSCR: lists directory contents
#SB1: -l #DSCR: lists in long format
#SB1: -R #DSCR: lists subdirectories recursively
#SS: Lists directory and subdirectories in long format""";

String promptExUser2 =
    "sed -i 's/[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}/192.168.0.1/g' logfile";

String promptExAssistant2 = """#ERR: none
#CMD: sed #DSCR: stream editor for filtering and transforming text
#SB1: -i #DSCR: edit files in-place
#SB1: 's/[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}/192.168.0.1/g' #DSCR: search and replace pattern
#SB2: [0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3} #DSCR: searches for IPv4 addresses
#SB2: /192.168.0.1/ #DSCR: specifies replacement text
#SB2: g #DSCR: specifies global replacement (replace all occurrences on each line)
#SB1: logfile #DSCR: file name on which the command is to be applied
#SS: Uses sed, a stream editor, to search and replace all occurrences of an IPv4 address pattern in 'logfile' with the IP address '192.168.0.1'.""";

String promptExUser3 = "curl -s https://www.wired.com | grep -oE '\bw+\b'";

String promptExAssistant3 = """#ERR: none
#CMD: curl #DSCR: command line tool for transferring data from or to a server
#SB1: -s #DSCR: silent mode, does not show progress or error messages
#SB1: https://www.google.de #DSCR: specifies URL to retrieve data from
#OPR: | #DSCR: pipe, redirects the output of curl command to input of grep command
#CMD: grep #DSCR: searches for patterns in text
#SB1: -oE #DSCR: tells grep to show only matched portion of line using extended regular expressions
#SB1: '\bw+\b' #DSCR: regular expression pattern to match words
#SS: Uses curl to fetch content from 'https://www.wired.com', and then pipes this content to grep to extract and print all whole words.""";

String promptExUser4 = "rm / -rf";

String promptExAssistant4 =
    """#WRN: Warning! This command is attempting to remove the root directory ("/") which results in the deletion of the entire file system.
#CMD: rm #DSCR: removes files and directories
#SB1: / #DSCR: specifies root directory
#SB1: -rf #DSCR: options to force removal of files and directories recursively
#SS: Attempts to remove all files and directories starting from the root directory ("/") recursively and forcefully.""";

String promptExUser5 =
    """mkdirr ~/bin && echo 'export PATH=\$PATH:\$HOME/bin' >> ~/.bashrt; rm /""";

String promptExAssistant5 = """#ERR: The comands name is mkdir, not mkdirr.
#ERR: The name of the bash configuration file is .bashrc, not .bashrt
#ERR: The rm command requires the -r (or --recursive) flag to remove directories and their contents recursively
#COR: mkdir ~/bin && echo "export PATH=\$PATH:\$HOME/bin" >> ~/.bashrc; rm / -r
#WRN: Warning! This command is attempting to remove the root directory ("/") which results in the deletion of the entire file system.
#CMD: mkdir #DSCR: creates new directory
#SB1: ~/bin #DSCR: specifies path of new directory to add to PATH
#OPR: && #DSCR: executes next command only if previous command succeeds
#CMD: echo #DSCR: prints string to the standard output
#SB1: "export PATH=\$PATH: \$HOME/bin" #DSCR: string to be printed
#OPR: >> #DSCR: appends output to file
#SB1: ~/.bashrc #DSCR: file to append the output to
#SS: Creates a new directory named "bin" in the user's home directory and then appends the line "export PATH=\$PATH:\$HOME/bin" to the end of the ~/.bashrc file. This ensures that the newly created "bin" directory is added to the system's PATH variable.""";

String promptExUser = "";
