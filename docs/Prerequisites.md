# Prerequisites

## Setup GitHub SSH Key

- Make SSH directory: `mkdir -p ~/.ssh && cd ~/.ssh`
- Create SSH key: `ssh-keygen -t ed25519`
  - Name it `personal`
  - No passphrase
- Get the public key: `cat personal.pub`
- Add the public key to [GitHub (Settings -> SSH and GPG keys -> New SSH key)](https://github.com/settings/keys)
- Update SSH config: `vim ~/.ssh/config`

```
# Personal
Host github-personal.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/personal

# Work (OSSA)
Host github-ossa.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/ossa

# Global defaults for all hosts
Host *
    IdentitiesOnly yes
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

- Test SSH connection: `ssh -T git@github-personal.com`
- You should get a message like: `Hi <your-username>! You've successfully authenticated...`

## Install a Nerd Font

> Recommended: `JetBrainsMono Nerd Font`, use a NL (non-ligature) version

- Go to [Nerd Fonts Releases](https://github.com/ryanoasis/nerd-fonts/releases)
- Go to assets section of latest version and click `Show all assets`
- Search for your font
- Download the `.tar.xz` file
- Unzip the file
  - Windows: Use 7zip
  - Mac / Linux: `tar -xvf <filename>`
- Install the fonts (recommended: `JetBrainsMonoNLNerdFont-Regular.ttf`)
  - Mac: Open up `Font Book` and drag and drop the fonts into the app
  - Ubuntu: Copy the .ttf files to `/usr/local/share/fonts`
    - PC: Select all .ttf files -> right click -> Install. If this doesn't work then just open the .ttf file you want to use (e.g. `JetBrainsMonoNerdFont-Regular.ttf`)
- Ensure your terminal is using the font
  - Mac (`ghostty`): This will work automatically if you have the font installed due to the `ghostty` config file (once you setup this repo)
  - Windows (`Terminal`): Settings -> Defaults -> Appearance -> Font family
  - VSCode / Cursor: Should work automatically once you setup this repo
    - If you need to install manually then do: Command Palette -> `Preferences: Open Settings (JSON)`
      ```json
      "editor.fontFamily": "Consolas, 'Courier New', monospace",
      "terminal.integrated.fontFamily": "'JetBrainsMonoNL Nerd Font', Consolas, 'Courier New', monospace",
      ```
