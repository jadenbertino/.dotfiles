# Codespaces

if using this in codespaces

1. clone the repo into home dir: `cd && gh repo clone jadenbertino/.dotfiles`
2. run the installer: `cd ~/.dotfiles && ./install.sh`
3. approve overwriting conflicting default files if prompted
4. ???
5. profit

# Additional Notes

- If you ever want to delete the symlinks, you can run `stow -D .`
- You can make changes to the symlinked files and the original files will be updated.
- The structure of this repo must match the structure of your `$HOME` directory.

# References

- [GNU Stow](https://www.gnu.org/software/stow/manual/)
- [Youtube: Stow has forever changed the way I manage my dotfiles](https://www.youtube.com/watch?v=y6XCebnB9gs&list=LL&ab_channel=DreamsofAutonomy)
