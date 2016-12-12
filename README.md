swift-build-report
==================

## Usage

### Pretty format for swift build/test

```sh
$ swift test 2>&1 | swift-build-report
```

![sample_pretty](https://raw.githubusercontent.com/tokorom/swift-build-report/images/sample_pretty.png)

### Error reports for other tools

```sh
$ swift test 2>&1 | swift-build-report --report default --output .build/errors.txt
```

- .build/errors.txt

```txt
/foo/bar/main.swift:77:5: error: expected declaration
/foo/bar/main.swift:61:9: error: use of unresolved identifier 'foo'
/foo/bar/main.swift:117:13: error: use of unresolved identifier 'printIfNeeded'
```

## Installation

```sh
$ brew tap tokorom/tokorom
$ brew install swift-build-report
```

## Formats

- `--format pretty` (default)
![sample_pretty](https://raw.githubusercontent.com/tokorom/swift-build-report/images/sample_pretty.png)

- `--format simple` (do not replace all strings)
![sample_simple](https://raw.githubusercontent.com/tokorom/swift-build-report/images/sample_simple.png)

## Error Handling

### Vim

- shell
```sh
$ swift test 2>&1 | swift-build-report --report default --output errors.txt
```

- Vim (QuickFix)
```vim
:cfile errors.txt
:copen
```

- jump to first error automatically
![vim_quickfix](https://raw.githubusercontent.com/tokorom/swift-build-report/images/vim_quickfix.png)
