# Test

## Unit tests

Unit tests check that the internals of sass-deprecate work correctly.

For example:

- initialising the module
- throwing errors and warnings where appropriate
- failing compilation when appropriate

### Working locally

Run tests everytime a file changes:

```bash
$ gem install filewatcher
$ filewatcher '**/*.{scss,rb}' 'test/spec.rb' --dontwait
```

When tests fail, the CSS gets output in `test/error.css`.
