
### ht - a shell command that answers your questions about shell commands.



https://github.com/catallo/ht/assets/45834058/cbe8913f-49fc-4e89-91e1-a25a5cabe680



##### Usage

- **ht &lt;instruction>** - answers with shell command

- **ht e|explain** - explains last answer

- **ht e|explain &nbsp;[command]** - explains command

##### Examples

- `ht find all IPv4 addresses in file A and write to file B`
- `ht explain`
- `ht explain ls -lS`
- `ht explain "ps -aux | grep nvidia"`

##### About

I initially created ht as a simple experiment to test GPT-3.5-Turbo's usefulness with shell commands. However, I now find myself using it extensively in my daily tasks. So I'm sharing it with the hope that it can benefit others in the same way.

ht is written in Dart. This means it's one single binary that you can easily add to your system's PATH. (If you don't know how to do this, ask ht.) The binary is fully self-contained and does not have any dependencies.

To use ht, you'll need an OpenAI API key. The good news is that due to ht's low token usage, a typical request costs about $0.00025, making it an incredibly budget-friendly tool for daily usage. You can [sign up for an API key here](https://platform.openai.com/signup) or refer to [this article](https://www.howtogeek.com/885918/how-to-get-an-openai-api-key) for detailed instructions.

##### Downloads

- [ht-v2.0.3 for Linux 64-Bit](https://github.com/catallo/ht/files/13476314/ht_2-0-3_linux64.zip)


- [ht-v2.0.3 for MacOS ARM64](https://github.com/catallo/ht/files/13476316/ht_2-0-3_MacOS_ARM64.zip)
