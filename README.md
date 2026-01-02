# Version Updater Script

A Bash script to update version numbers in various project files.

## Usage

```sh
./version_updater.sh <TYPE> <VERSION> <PATH/TO/FILE> [BUNDLE_NAME]
```

- `<TYPE>`: One of `xcode`, `json`, `cpp`, `gradle`, `html`, `yand`, `windows`
- `<VERSION>`: Version string in the format `X.Y.Z` (e.g., `1.2.3`)
- `<PATH/TO/FILE>`: Path to the file to update
- `[BUNDLE_NAME]`: Required only for `yand` type

## Version Format

- `X.Y.Z`
  - `X`: major version (integer, max 2 digits, no leading zeros)
  - `Y`: minor version (integer, max 2 digits, no leading zeros)
  - `Z`: patch version (integer, max 2 digits, no leading zeros)

## Supported Types

- **xcode**: Updates `CURRENT_PROJECT_VERSION` and `MARKETING_VERSION` in Xcode project files.
```
CURRENT_PROJECT_VERSION = X.Y.Z;
MARKETING_VERSION = X.Y.Z;
```

- **json**: Updates `androidVersion`, `iosVersion`, and `otherVersion` fields in JSON files.
```json
{
    "value": {
        "androidVersion": "6.18.1",
        "iosVersion": "6.18.1",
        "otherVersion": "6.18.1"
    }
}
```

- **cpp**: Updates C/C++ version string assignments.
```cpp
const char* Version = "X.Y.Z";
```

- **gradle**: Updates `versionCode` and `versionName` in Gradle build files.
```gradle
versionCode = 10203 // as X*10000 + Y*100 + Z*10
versionName = "X.Y.Z"
```

- **html**: Updates HTML attributes and JS version query strings.
```html
<body version="X.Y.Z" build="X.Y.Z">
<script src="js/main.js?ver=X.Y.Z"></script>
```

- **yand**: Updates `CACHE_NAME` constant in JS files (requires `BUNDLE_NAME`).
- **windows**: Updates `FileVersion` and `ProductVersion` in Windows resource files (UTF-16).

## Notes

- The script creates `.bak` backup files and removes them after updating.
- Requires GNU `sed` and `iconv` for some operations.


## Author

```
Copyright © 2026 Andrey A. Ugolnik. All Rights Reserved.
https://github.com/reybits
and@reybits.dev
```
