# Deprecate with confidence [![Build Status](https://travis-ci.org/salesforce-ux/sass-deprecate.svg?branch=master)](https://travis-ci.org/salesforce-ux/sass-deprecate)

`deprecate()` is a Sass mixin that helps managing code deprecation.

How? Sass Deprecate warns about the pieces of your codebase that are deprecated, instructing developers where to clean up. It helps provide a clear upgrade path for framework and library users.

We (the Salesforce UX team) built this tool to help us deprecate code with confidence in the [Lightning Design System](https://www.lightningdesignsystem.com).

## Getting started

Here is a typical workflow in which `deprecate()` comes in handy:

### v1.0.0

Consider a Sass style guide in v1.0.0,  button:

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

## Advanced Semantic Versioning Support

Need to compare version numbers such as `3.2.1-beta.5` and `1.2.3-alpha.2`?

By default, sass-deprecate only compares `$version` with `$app-version` in the form of `Major.Minor.Patch` (e.g. `1.2.3` with `2.0.0`).

For advanced Semver support in the form of `Major.Minor.Patch-beta/alpha/rc.1`, define a `deprecate-version-greater-than($v1, $v2)` function, or rely on Hugo's [sass-semver](https://raw.githubusercontent.com/HugoGiraudel/sass-semver):

```scss
// Override the default Semver resolution engine
// with sass-semver: https://github.com/HugoGiraudel/sass-semver
@import 'node_modules/sass-semver/index';

@function deprecate-version-greater-than($version, $app-version) {
  @return call(gt, $v1: $version, $v2: $app-version);
}

@import 'path-to/sass-deprecate/index';
```

## Running tests

Clone the repository, then:

```
npm install
npm test
```

## Generating the documentation

Sass Deprecate's API is documented using [SassDoc](http://sassdoc.com/).

    npm run generate-doc

Generate & deploy the documentation to <http://salesforce-ux.github.io/sass-deprecate/>:

    npm run deploy-doc

## License

Source code is licensed under [BSD License Clause 2](http://opensource.org/licenses/BSD-2-Clause).

## Acknowledgments

Thanks to [Hugo Giraudel](https://github.com/HugoGiraudel) for his `to-number` Sass function.
