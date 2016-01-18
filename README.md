# Deprecate with confidence [![Build Status](https://travis-ci.com/salesforce-ux/sass-deprecate.svg?token=1gDsJEsp8ELpc6yY2BCC&branch=master)](https://travis-ci.com/salesforce-ux/sass-deprecate)

`deprecate()` is a Sass mixin that helps managing code deprecation.

How? Sass Deprecate warns about the pieces of your codebase that are deprecated, instructing developers where to clean up. It helps provide a clear upgrade path for framework and library users.

## Getting started

Typical workflow:

### v1.0.0

```scss
$app-version: '1.0.0';
@import 'path/to/deprecate/index.scss';

.button { background: red; }
```

### v1.1.0

We're introducing a new type of button, but we want to keep the old one in for backwards compatibility.

```scss
$app-version: '1.0.0';
@import 'path/to/deprecate/index.scss';

@include deprecate('2.0.0', 'Use .button-new instead') {
  .button { background: red; }
}
.button-new { background: red; border: 3px solid blue; }
```

```css
/* Compiled CSS */
.button { background: red; }
.button-new { background: red; border: 3px solid blue; }
```

### v2.0.0

Major update: we don't want to ship deprecated code, and this is where Sass Deprecate comes into play:

```scss
$app-version: '2.0.0';
@import 'path/to/deprecate/index.scss';
...
```

The compiler will start throwing warnings, such as:

```
WARNING: Deprecated code was found, it should be removed before its release.
REASON:  Use .button-new instead
	on line 145 of index.scss
	from line 5 of button.scss
```

And the compiled CSS won't include `.button`:

```css
/* Compiled CSS */
.button-new { background: red; border: 3px solid blue; }
```

## License

Source code is licensed under [BSD License Clause 2](http://opensource.org/licenses/BSD-2-Clause).

## Acknowledgments

Thanks to [Hugo Giraudel](https://github.com/HugoGiraudel) for his `to-number` Sass function.
