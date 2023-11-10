Map<String, Object> promptEx = {
  "model": "gpt-3.5-turbo",
  "messages": [
    {
      "role": "system",
      "content":
          "You're a Unix shell expert. You sort parts of commands into the following categories followed by '#DSCR:' and a description: \n\n#CMD: actual command #DSCR:\n#SUB: options and other things following the command #DSCR:\n#SUBSUB: sub parts of the above #DSCR:\n#SUBSUBSUB: sub parts of the above #DSCR:\n#OPR: Operators like | or > that are not part of an actual command #DSCR:\n\nYour output will be parsed to a hierachical structure, this is what SUB: and SUBSUB: are for. Describe parts in the same order as in the original command.\n\n#ERR: use this to describe every error or misspelling of commands you found\n#COR: the corrected version if an error was found\n\nIf you found an error, describe the corrected version!\n\n#SS: short summary"
    },
    {"role": "user", "content": "Describe and check for errors: ls -l -R"},
    {
      "role": "assistant",
      "content":
          "#ERR: none\n#CMD: ls #DSCR: lists directory contents\n#SUB: -l #DSCR: lists in long format\n#SUB: -R #DSCR: lists subdirectories recursively\n#SS: Lists directory and subdirectories in long format"
    },
    {
      "role": "user",
      "content":
          "Describe and check for errors: sed -i 's/[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}/192.168.0.1/g' logfile"
    },
    {
      "role": "assistant",
      "content":
          "#ERR: none\n#CMD: sed #DSCR: stream editor for filtering and transforming text\n#SUB: -i #DSCR: edit files in-place\n#SUB: 's/[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}/192.168.0.1/g' #DSCR: search and replace pattern\n#SUBSUB: [0-9]{1,3} #DSCR: specifies one to three digits\n#SUBSUB: . #DSCR: specifies a literal period\n#SUBSUB: /192.168.0.1/ #DSCR: specifies the replacement text\n#SUBSUB: g #DSCR: specifies global replacement (replace all occurrences on each line)\n#SUB: logfile #DSCR: the file name on which the command is to be applied\n#SS: Searches for IP addresses (in the format xxx.xxx.xxx.xxx) in the logfile and replaces them with 192.168.0.1, saving the changes to the logfile."
    },
    {
      "role": "user",
      "content":
          "Describe and check for errors: curl -s https://www.google.de | grep -oE '\\b\\w+\\b'"
    },
    {
      "role": "assistant",
      "content":
          "#ERR: none\n#CMD: curl #DSCR: command line tool for transferring data from or to a server\n#SUB: -s #DSCR: silent mode, does not show progress or error messages\n#SUB: https://www.google.de #DSCR: specifies the URL to retrieve data from\n#OPR: | #DSCR: redirects the output of the previous command to the next command\n#CMD: grep #DSCR: searches for patterns in text\n#SUB: -oE #DSCR: tells grep to show only the matched portion of the line using extended regular expressions\n#SUB: '\\b\\w+\\b' #DSCR: regular expression pattern to match words\n#SS: Retrieves the content of https://www.google.de and then extracts and displays only the individual words found in the text."
    },
    {
      "role": "user",
      "content":
          "Describe and check for errors: grep -E -o \"([0-9]{1,3}\\.){3}[0-9]{1,3}\" file1 > file2 "
    },
    {
      "role": "assistant",
      "content":
          "#ERR: none\n#CMD: grep #DSCR: searches for patterns in text\n#SUB: -E #DSCR: tells grep to use extended regular expressions\n#SUB: -o #DSCR: only outputs the matched portion of the line\n#SUB: \"([0-9]{1,3}\\.){3}[0-9]{1,3}\" #DSCR: regular expression pattern to match IP addresses\n#SUBSUB: [0-9]{1,3} #DSCR: specifies one to three digits\n#SUBSUB: \\. #DSCR: specifies a literal period\n#SUBSUB: {3} #DSCR: specifies exactly three occurrences of the preceding pattern\n#SUB: file1 #DSCR: the file to search in\n#OPR: > #DSCR: redirects the output to a file\n#SUB: file2 #DSCR: the file to write the output to\n#SS: Searches for IP addresses in file1 using extended regular expressions and writes the matched IP addresses to file2."
    },
    {
      "role": "user",
      "content":
          "Describe and check for errors: mkdirr ~/bin && echo \"export PATH=\$PATH:\$HOME/bin\" >> ~/.bashrt"
    },
    {
      "role": "assistant",
      "content":
          "#ERR: The comands name is mkdir, not mkdirr.  The name of the bash configuration file is .bashrc, not .bashrt\n#COR: mkdir ~/bin && echo \"export PATH=\$PATH:\$HOME/bin\" >> ~/.bashrc\n#CMD: mkdir #DSCR: creates a new directory\n#SUB: ~/bin #DSCR: specifies the path of the new directory as the user's home directory followed by \"/bin\"\n#OPR: && #DSCR: executes the next command only if the previous command succeeds\n#CMD: echo #DSCR: prints a string to the standard output\n#SUB: \"export PATH=\$PATH:\$HOME/bin\" #DSCR: the string to be printed\n#OPR: >> #DSCR: appends the output to a file\n#SUB: ~/.bashrc #DSCR: the file to append the output to\n#SS: Creates a new directory named \"bin\" in the user's home directory and then appends the line \"export PATH=\$PATH:\$HOME/bin\" to the end of the ~/.bashrc file. This ensures that the newly created \"bin\" directory is added to the system's PATH variable."
    },
    {"role": "user", "content": "Describe and check for errors: "}
  ],
  "temperature": 0,
  "max_tokens": 512,
  "top_p": 1,
  "frequency_penalty": 0,
  "presence_penalty": 0
};
