
### ht - a shell command that answers your questions about shell commands.


https://github.com/catallo/ht/assets/45834058/ec95fa8f-038a-4a1d-a85e-130b0af1630d

ht is a shell helper tool focused on simplicity that can generate, explain and execute shell commands.

#### Features

- **Low token usage**

- **Cached responses**

- **Easy installation**

- **Automatic updates**

##### Usage

- **ht &lt;instruction>** - answers with shell command

- **ht e|explain** - explains last answer

- **ht e|explain &nbsp;[command]** - explains command

- **ht x|execute** - executes last answer

##### Examples

- `ht find all IPv4 addresses in file A and write to file B`
- `ht explain`
- `ht explain ls -lS`
- `ht explain "ps -aux | grep nvidia"`
- `ht execute`

##### About

I initially created ht as a simple experiment to test GPT3's usefulness with shell commands. However, I now find myself using it extensively in my daily tasks. So I'm sharing it with the hope that it can benefit others in the same way. It's using OpenAI's GPT3.5-Turbo model now and I plan to add more models in the future, including locally running models. 

ht is written in Dart. As a result, it is compiled into a single, self-contained binary. This means that the ht binary operates independently without requiring any external dependencies or runtime environments.

To use ht, you'll need an OpenAI API key. The good news is that due to ht's low token usage, a typical request costs about $0.00025, making it an incredibly budget-friendly tool for daily usage. You can [sign up for an API key here](https://platform.openai.com/signup) or refer to [this article](https://www.howtogeek.com/885918/how-to-get-an-openai-api-key) for detailed instructions.

ht communicates directly with OpenAI's API, without involving a third-party server. For automated updates to work, ht will send a request to the GitHub API to check for new releases.

##### Installation

1. Download the archive for your platform from the Downloads section below.
2. Unzip the archive.
3. Using a terminal, navigate to the directory containing the ht binary and run it with the -i flag to start the installation process.

```
cd Downloads
./ht_2-0-3_linux64 -i
```

ht will be installed to '~/.config/ht' and the directory will be added to your PATH. Future updates will be installed automatically.

##### Downloads

- [Releases](https://github.com/catallo/ht/releases)


