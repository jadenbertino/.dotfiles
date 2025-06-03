# Prerequisites

### Install packages

- If using Ubuntu then ensure you're using 24 to prevent issues with fzf
- Update package manager
  - Ubuntu: `sudo apt update`
  - Mac: `brew update`
- Install `zsh`
  - Ubuntu: `sudo apt install zsh`
  - Mac: `brew install zsh`
- Set `zsh` as the default shell
  - `sudo chsh -s $(which zsh)`
  - Note that once you symlink with stow, the new `.bashrc` will auto switch to `zsh` if it is installed.
- (Optionally backup and) Remove any existing `.zshrc` files or configuration (e.g. `oh-my-zsh`)
- Install additional packages
  - Mac: `brew install --force git fzf zoxide stow`
  - Ubuntu: `sudo apt install -y git fzf zoxide stow`

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

# Usage

1. Clone this repo into your home directory
2. `cd` into the repo
3. run `stow -v .` to symlink the files
4. You will probably get conflicts. You can either:
   - Recommended: Delete the conflicting files then run `stow -v .` again. Keep in mind that you should be deleting the files in your `~` dir.
   - Run `stow --adopt .` to have the external files overwrite the files in `dotfiles` repo. From here you can commit the changes or stash to get rid of them.

# Additional Notes

- You can make changes to the symlinked files and the original files will be updated.
- The structure of this repo must match the structure of your `$HOME` directory.
- If there are conflicts, you can run `stow --adopt .`. This will move the original files into this directory and then symlink the files back to the original location. Keep in mind that this will overwrite the files in this repo.

# References

- [GNU Stow](https://www.gnu.org/software/stow/manual/)
- [Youtube: Stow has forever changed the way I manage my dotfiles](https://www.youtube.com/watch?v=y6XCebnB9gs&list=LL&ab_channel=DreamsofAutonomy)

