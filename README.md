# Prerequisites

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
  - Mac (`ghostty`):
      ```bash
      ghostty +list-fonts | grep -i jetbrains
      # choose a top level (non indented) font

      # Open up config file
      # code "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
      # add this line (NL = non ligatures)
      # font-family = "JetBrainsMonoNL Nerd Font Mono"

      # Open up a new ghostty tab
      # confirm config loaded
      ghostty +show-config | grep font-family
      ```
  - Windows (`Terminal`): Settings -> Defaults -> Appearance -> Font family

### Install packages

- Update packages
  - Ubuntu: `sudo apt update && sudo apt install -y zsh zoxide stow`
  - Mac: `brew update && brew install --force zsh zoxide stow`
- Set `zsh` as the default shell
  - `sudo chsh -s $(which zsh)`
- (Optionally backup and) Remove any existing `.zshrc` files or configuration (e.g. `oh-my-zsh`)

# Usage

1. Clone this repo into your home directory
2. `cd` into the repo
3. Run `stow -v .`
    ```bash
    stow -v --adopt .
    git stash
    source ~/.zshrc
    # you can now unstash the changes if you want to to see what changed
    ```

# Additional Notes

- If you ever want to remove the symlinks, you can run `stow -D .`
- You can make changes to the symlinked files and the original files will be updated.
- The structure of this repo must match the structure of your `$HOME` directory.

# References

- [GNU Stow](https://www.gnu.org/software/stow/manual/)
- [Youtube: Stow has forever changed the way I manage my dotfiles](https://www.youtube.com/watch?v=y6XCebnB9gs&list=LL&ab_channel=DreamsofAutonomy)

