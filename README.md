# Codespaces

if using this in codespaces

1. `cd && git clone https://github.com/jadenbertino/.dotfiles.git && cd ~/.dotfiles && ./install.sh -y`
3. approve overwriting conflicting default files if prompted
4. `zsh`
5. ???
6. profit

# Additional Notes

- If you ever want to delete the symlinks, you can run `stow -D .`
- You can make changes to the symlinked files and the original files will be updated.
- The structure of this repo must match the structure of your `$HOME` directory.

# References

- [GNU Stow](https://www.gnu.org/software/stow/manual/)
- [Youtube: Stow has forever changed the way I manage my dotfiles](https://www.youtube.com/watch?v=y6XCebnB9gs&list=LL&ab_channel=DreamsofAutonomy)
