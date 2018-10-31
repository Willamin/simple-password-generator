# simple-password-generator

## Usage

```
usage: spg [password_length] [num_passwords]
    password_length                  the length of the passwords; defaults to 64 if left blank
    num_passwords                    how many passwords to generate; defaults to 1 if left blank
    -h, --help                       show this help
character set options:
    -a, --ascii                      add all printable ASCII characters to the set; default if no set options are used
    -n, --number                     add numbers to the set
    -d, --down                       add all lowercase letters to the set
    -u, --up                         add all uppercase letters to the set
    -l, --letter                     add all letters to the set (same as -d -u)
    -s, --simple                     add all letters and numbers to the set (same as -n -d -u)
    -c, --clear                      remove ambiguous letters and numbers (B8G6I1l0OQDS5Z2)
```

## Contributing

1. Fork it ( https://github.com/willamin/simple-password-generator/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [willamin](https://github.com/willamin) Will Lewis - creator, maintainer
