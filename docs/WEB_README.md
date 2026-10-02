# Play Somchai's Last Harvest on GitHub Pages

This folder contains the latest playable Web release, including the UI polish pass.
The source Godot project remains in the repository root.

## Publish

1. Commit and push the generated `docs/index*` files and `docs/.nojekyll` to `main`.
2. In **Settings > Pages**, choose **Deploy from a branch**, branch **main**, folder **/docs**, then **Save**.
3. After GitHub finishes deployment, open https://siraanpimpa.github.io/project3d_2026/ .

Keep every generated `index*` file together with its original filename. The game
must be served over HTTP/HTTPS; double-clicking `index.html` is not supported.
Use a desktop browser with WebGL 2 (Chrome, Edge or Firefox).

## Rebuild

In Godot 4.7, open **Project > Export**, select **Web**, and export a release to
`docs/index.html`. The matching Web templates must be installed.

Alternatively, from the project root:

```powershell
& "PATH_TO_GODOT.exe" --headless --path . --export-release Web docs/index.html
```

The Web preset uses Compatibility rendering and disables threads/extensions,
so this release does not require custom cross-origin server headers. Test files,
reports and screenshots are excluded from the game pack. Existing reports in
`docs` are retained.

## Controls

WASD move · Shift sprint · E interact · Q Farming/Combat · Tab bag
· wheel select · RMB aim · LMB attack · R reload · N wait until night · Esc pause.
Click the canvas to capture the mouse. Escape can release the cursor in a browser;
click the canvas again to resume mouse control.

References: [Godot Web export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)
and [GitHub Pages branch setup](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site).


## Local browser verification

The release was served at a repository-style `/project3d_2026/` subpath and tested
in Edge at 1280x720. Menu, Play loading the complete 3D world, movement and Tab
opening the bag were observed. No browser console errors or failed requests.
The nine release files total 106.82 MiB; each file is below 100 MiB.
[Verification data](web_verification/result.json), [world screenshot](web_verification/02_game.png),
[bag screenshot](web_verification/03_inventory.png).

Files are prepared locally. GitHub publishing has not been performed in this task;
the public URL becomes available after commit/push and Pages deployment.
