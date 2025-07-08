# Prerequisites

### Setup GitHub SSH Key

- Make SSH directory: `mkdir -p ~/.ssh && cd ~/.ssh`
- Create SSH key: `ssh-keygen -t ed25519`
  - Name it `personal`
  - No passphrase
- Get the public key: `cat personal.pub`
- Add the public key to GitHub (Settings -> SSH and GPG keys -> New SSH key)
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

### Install a Nerd Font

- Recommended: `JetBrainsMono Nerd Font`
- Go to [Nerd Fonts Releases](https://github.com/ryanoasis/nerd-fonts/releases)
- Go to assets section of latest version and expand
- Search for your font zip
- Download the font zip
- Unzip the download
- Install the fonts
  - Mac: Open up `Font Book` and drag and drop the fonts into the app
  - Ubuntu: Copy the .ttf files to `/usr/local/share/fonts`
  - PC: Select all .ttf files -> right click -> Install
- Ensure your terminal is using the font
  - Mac (`ghostty`): This will work automatically if you have the font installed due to the `ghostty` config file
  - Windows (`Terminal`): Settings -> Defaults -> Appearance -> Font family
  - VSCode: Command Palette -> `Preferences: Open Settings (JSON)`
      ```json
      "editor.fontFamily": "Consolas, 'Courier New', monospace",
      "terminal.integrated.fontFamily": "'JetBrainsMonoNL Nerd Font', Consolas, 'Courier New', monospace",
      ```

### Install packages

- Update packages
  - Ubuntu: `sudo apt update && sudo apt install -y zsh zoxide stow`
  - Mac: `brew update && brew install --force zsh zoxide stow`
- Set `zsh` as the default shell
  - `sudo chsh -s $(which zsh)`
- (Optionally backup and) Remove any existing `.zshrc` files or configuration (e.g. `oh-my-zsh`)

### Additional Steps

- Refer to `.config/env/.env.example` to set up your `.env` file

# Usage

1. Clone this repo into your home directory
2. `cd` into the repo
3. Run `./scripts/stow.sh`
4. Review and make changes to files in the repo
5. Run `source ~/.zshrc` to load the config

# Additional Notes

- If you ever want to remove the symlinks, you can run `stow -D .`
- You can make changes to the symlinked files and the original files will be updated.
- The structure of this repo must match the structure of your `$HOME` directory.

# References

- [GNU Stow](https://www.gnu.org/software/stow/manual/)
- [Youtube: Stow has forever changed the way I manage my dotfiles](https://www.youtube.com/watch?v=y6XCebnB9gs&list=LL&ab_channel=DreamsofAutonomy)

