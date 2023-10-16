### ht - an assistant that answers your questions about shell commands.

##### Usage

- **ht &lt;question>** - answers question

- **ht explain|x** - explains last answer

- **ht explain|x &nbsp;[command]** - explains command

##### Examples

- `ht find all IPv4 addresses in file and write to new file`
- `ht explain`
- `ht explain ls -lS`
- `ht explain "ps -aux | grep nvidia"`

##### About

I initially created ht as a simple experiment to test GPT-3.5-Turbo's usefulness with shell commands. However, I find myself using it extensively in my daily tasks. So I'm sharing it with the hope that it can benefit others in the same way.

To use ht, you'll need an OpenAI API key. The good news is that due to its low token usage, it's an incredibly budget-friendly tool. 

ht is is written in Dart. This means it's a single binary that you can easily add to your system's PATH. You won't have to deal with Python virtual environments or other complexities. 

##### Downloads

- [Linux x64](download-link-for-Linux-x64) works on every x64 Linux distro
- [Raspberry Pi 32-Bit](download-link-for-Raspberry-Pi-32-Bit)
- [Raspberry Pi 64-Bit](download-link-for-Raspberry-Pi-64-Bit)