### ht - a shell command that answers your questions about shell commands.

##### Usage

- **ht &lt;question>** - answers question

- **ht explain|x** - explains last answer

- **ht explain|x &nbsp;[command]** - explains command

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

- [Linux x64](download-link-for-Linux-x64) (works on every 64-Bit Linux distro)
- [Raspberry Pi 32-Bit](download-link-for-Raspberry-Pi-32-Bit)
- [Raspberry Pi 64-Bit](download-link-for-Raspberry-Pi-64-Bit)