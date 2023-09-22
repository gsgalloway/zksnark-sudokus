

## VSCode Language Server

```
npm install --global @vscode/vsce
cd /tmp
git clone git@github.com:starkware-libs/cairo.git
cd ./cairo/vscode-cairo/
npm install
vsce package
code --install-extension cairo1*.vsix

cd ../
cargo build --bin cairo-language-server --release
```