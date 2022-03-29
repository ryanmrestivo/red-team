<p align="center">
  <img width="600" height="197" src="https://user-images.githubusercontent.com/24392180/60277578-86af4e00-9906-11e9-8c60-fed3de02b449.png"><br/>
  <a href="https://github.com/PyObfx/PyObfx/releases"><img src="https://img.shields.io/github/release/PyObfx/PyObfx.svg"/></a>
  <a href="https://github.com/PyObfx/PyObfx/issues"><img src="https://img.shields.io/github/issues/PyObfx/PyObfx.svg"/></a>
  <a href="https://github.com/PyObfx/PyObfx/pulls"><img src="https://img.shields.io/github/issues-pr/PyObfx/PyObfx.svg"/></a>
  <a href="https://github.com/PyObfx/PyObfx/stargazers"><img src="https://img.shields.io/github/stars/PyObfx/PyObfx.svg"/></a>
  <a href="https://github.com/PyObfx/PyObfx/network"><img src="https://img.shields.io/github/forks/PyObfx/PyObfx.svg"/></a>
  <a href="https://github.com/PyObfx/PyObfx/blob/master/LICENSE"><img src="https://img.shields.io/github/license/PyObfx/PyObfx.svg"/></a>
</p>

# PyObfx
Python Obfuscation tool

## Features
* String, Integer, Float and Boolean Obfuscation
* Variable Name Obfuscation
* Import Name Obfuscation
* Packing

## Installation

```
git clone https://github.com/PyObfx/PyObfx.git && cd PyObfx/
pip install -r requirements.txt
```

## Usage

<p align="center">
  <a href="https://asciinema.org/a/207739" target="_blank"><img src="https://asciinema.org/a/207739.png" /></a>
</p>

In order to obfuscate a single file:
```
python3 PyObfx.py <file_name>
```

To pack the file after obfuscation: (Available packers are bz2, gz and lzma)
```
python3 PyObfx.py <file_name> -p <packer>
```

For other options, see:
```
python3 PyObfx.py -h
```

## License
This project is licensed under the GPL v3 License - see the [LICENSE](https://github.com/PyObfx/PyObfx/blob/master/LICENSE) file for details.
