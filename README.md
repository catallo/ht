
### ht - a shell command that answers your questions about shell commands.


https://github.com/catallo/ht/assets/45834058/5855363c-a0a3-4eff-8b59-dcf853b161b9



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

[ht-v1.0.5 for Linux 64-Bit](https://github.com/catallo/ht/files/13025284/ht-1.0.5-linux64.tar.gz)

[ht-v1.0.5 for Raspberry OS 64-Bit](https://github.com/catallo/ht/files/13025318/ht-1.0.5-raspi64.tar.gz)
