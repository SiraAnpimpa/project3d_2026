# Web version — Somchai’s Last Harvest

## Play

Use a desktop browser with WebGL 2, a keyboard and a mouse. Serve the game over HTTP/HTTPS; opening `index.html` directly from the filesystem is unsupported. Keep all generated `index*` files together under their original names.

After loading, click the game to hide the cursor and enable mouse look. Gameplay waits until the browser confirms capture. Escape opens Pause even when the browser consumes the key to unlock the mouse. In Settings, Escape returns to Pause; click Resume to play again. Closing a menu with Escape or Tab shows a click-to-resume prompt. Switching away from the browser also pauses the game. See [how to play](../README.md) and [controls](../CONTROLS.md).

## GitHub Pages

1. Export the Web build to `docs/index.html`.
2. Commit and push the generated Web files and `docs/.nojekyll` to the repository branch used for hosting.
3. In repository **Settings → Pages**, select **Deploy from a branch**, the hosting branch and the **/docs** folder.
4. After deployment, open the project Pages URL: [Somchai’s Last Harvest](https://siraanpimpa.github.io/project3d_2026/).

## Export from Godot

Open the project in Godot 4.7 with matching export templates installed. Under **Project → Export**, select **Web** and export a release to `docs/index.html`.

From the project root, the command-line equivalent is:

```powershell
& "PATH_TO_GODOT.exe" --headless --path . --export-release Web docs/index.html
```

The Web preset uses Compatibility rendering with threads and extensions disabled. Test fixtures, tools and documentation are excluded from the game pack. Re-export after changing runtime scenes, scripts or assets.

## Local preview

From the project root, start a static HTTP server, then open `http://localhost:8000/`:

```powershell
python -m http.server 8000 --directory docs
```

Stop the server with Ctrl+C. This preview does not publish the game.
