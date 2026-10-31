# Social Media Engagement Analytics — GitHub Pages

A static, responsive dashboard built from the 13 SQL-result CSV files supplied for the Social Media Engagement Analytics project.

## Publish on GitHub Pages

1. Create a new **public** GitHub repository (for example `social-media-analytics`).
2. Extract this ZIP on your computer.
3. Open the extracted folder. You should see `index.html`, `README.md`, and the `data` folder.
4. In your GitHub repository, choose **Add file → Upload files**.
5. Upload `index.html`, `README.md`, and the entire `data` folder (keep the folder name `data`).
6. Commit the files to the `main` branch.
7. Open **Settings → Pages**.
8. Under **Build and deployment**, choose **Deploy from a branch**.
9. Select branch `main` and folder `/ (root)`, then click **Save**.
10. Wait for GitHub Pages to publish. Your site URL will look like:
   `https://YOUR-USERNAME.github.io/REPOSITORY-NAME/`

## Important

- Upload the contents of this project folder, not the ZIP file itself.
- Keep `index.html` at the repository root and preserve the `data` folder.
- The site uses Chart.js from a CDN, so visitors need an internet connection for charts to render.
- The dashboard is static: no server, database, API key, React installation, or build command is required.
- The project data is synthetic/AI-generated and should not be presented as real platform data.
- The dashboard displays the supplied SQL outputs and does not independently validate the underlying SQL logic.
