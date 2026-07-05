# Version Updater Script

A Bash script to update version numbers in various project files.

## Usage

```sh
./version_updater.sh <TYPE> <VERSION> <PATH/TO/FILE> [BUNDLE_NAME]
```

- `<TYPE>`: One of `xcode`, `json`, `cpp`, `gradle`, `html`, `yand`, `windows`
- `<VERSION>`: Version string in the format `X.Y.Z[.B]` (e.g., `1.2.3` or `1.2.3.4`)
- `<PATH/TO/FILE>`: Path to the file to update
- `[BUNDLE_NAME]`: Required only for `yand` type

## Version Format

- `X.Y.Z[.B]`
  - `X`: major version (integer, max 2 digits, no leading zeros)
  - `Y`: minor version (integer, max 2 digits, no leading zeros)
  - `Z`: patch version (integer, max 2 digits, no leading zeros)
  - `B`: build number (optional, default `0`, max 2 digits) — bumps the
    numeric build code while the `X.Y.Z` marketing version stays fixed,
    so the same version can be re-uploaded to the stores

The numeric build code is `XXYYZZBB` (each component zero-padded to two
digits): `1.2.3` → `1020300`, `1.2.3.4` → `1020304`. The trailing build
digits keep the code strictly increasing across rebuilds of one version.

## Supported Types

- **xcode**: Updates `CURRENT_PROJECT_VERSION` and `MARKETING_VERSION` in Xcode project files.
```
CURRENT_PROJECT_VERSION = 1020300 /* as XXYYZZBB */;
MARKETING_VERSION = 1.2.3;
```

- **json**: Updates `androidVersion`, `iosVersion`, and `otherVersion` fields in JSON files.
```json
{
    "value": {
        "androidVersion": "1.2.3",
        "iosVersion": "1.2.3",
        "otherVersion": "1.2.3"
    }
}
```

- **cpp**: Updates C/C++ version string assignments.
```cpp
const char* Version = "1.2.3";
```

- **gradle**: Updates `versionCode` and `versionName` in Gradle build files.
```gradle
versionCode = 1020300 // as XXYYZZBB
versionName = "1.2.3"
```

- **html**: Updates HTML attributes and JS version query strings.
```html
<body version="1.2.3" build="1020300"> <!-- as XXYYZZBB -->
<script src="js/main.js?ver=1.2.3"></script>
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
