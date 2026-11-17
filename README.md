# Obscure Code Reviewer

<p align="center">
  <img width="500" alt="left: the agent codes and you don't understand; right: you review it with this tool" src="https://github.com/user-attachments/assets/f9f7af83-1bfe-4dc2-82b5-94fda0aa172a" />
  <br>
  <em>Left: the agent codes and you don't understand. Right: you review it with this tool.</em>
</p>

Review code changes inside a Pharo image. Built for reviewing what a coding agent wrote, but it works without one.

It shows everything between a base commit and the image, organized in a tree. You read the diffs, mark what you reviewed, write comments, and click **Copy review** to get Markdown you can paste back to the agent.

<p align="center">
  <img width="600" alt="The review window: the Structure tab with a method diff, then the Topics tab with reviewed marks and comments" src="https://github.com/user-attachments/assets/92850147-240b-41ab-b423-bc93fe234bec" />
</p>

## Install

```smalltalk
Metacello new
	baseline: 'ObscureCodeReviewer';
	repository: 'github://jordanmontt/obscure-code-reviewer:main/src';
	load.
```

## Open it

- World menu: **Browse → Obscure Code Reviewer**. Pick a repository and what to compare it with, then **Open review**.
- Or from a Playground:

```smalltalk
(OCRReviewPresenter onRepositoryNamed: 'my-project') open.
```

The repository must be registered in Iceberg, with a local checkout and its packages loaded.

## What you review

Everything between a **base commit** and the **image**, including changes not committed yet:

- the code of the loaded packages (methods, class definitions, class comments);
- the other files of the repository (README, docs, packages not loaded), compared with the disk. A brand-new file shows up once it is committed. Markdown files show the text diff, or, with **Rendered**, both versions rendered with Microdown. Binary files (pictures, videos, archives) show their sizes instead of a diff, and pictures are shown side by side.

The base is chosen for you (the window title says which one):

| You are | Base | You review |
|---|---|---|
| On a branch, and the project has `main` or `master` | where the branch split from it | the whole branch, like a pull request |
| On `main`, with an upstream | where it split from its upstream | what is not pushed yet |
| Anywhere else | the last commit | the uncommitted changes |

The picker lets you choose another base.

**Work on a branch.** On `main`, earlier local commits are mixed into the review until they are pushed. With a branch per task, the review is exactly that task.

## The window

- **Structure:** Code, Tests, Baseline and Files, then package → class → method. Each node shows its kind (`+` added, `~` modified, `-` removed) and the lines changed under it; commented nodes are bold.
- **The right side:** the diff of the selected change, or the code alone when it was added or removed. **Double-click** a change to open it in its own large window, for long lines and long methods.
- **Topics:** the changes grouped by purpose, from the agent's review guide (below). Changes no topic mentions are under "Not covered by any topic".
- **Guide:** the guide itself, editable (**Apply**), with warnings about it.
- **Pull request:** the title and description of the future pull request; the agent drafts them, you edit them.
- **Reviewed:** marks the selected change, or everything under the selected node; on something already reviewed it reads **Unmark**. A refresh keeps the mark only while the code is the same.
- **Comments:** one per change or topic, plus a general comment.
- **Edit / Save / Cancel:** fix an added or modified method by hand. **Browse** opens it in the System Browser.
- **Refresh:** recomputes everything, keeping your comments, marks and pull request edits.
- **Copy review:** your comments as Markdown, with the changes not reviewed yet and your pull request edits.

Hover a tab to see what it is for. Comments and marks live in memory while the window is open.

## The review guide (for agents)

The agent gives a Markdown guide to the review window when it opens it (for example over MCP). The guide is not stored: it lives as long as the window.

```smalltalk
(OCRReviewPresenter
	onRepositoryNamed: 'my-project'
	guide: (OCRReviewGuide fromText: 'Title: Parse tokens lazily
The parser read the whole stream for every token.

# Goal
`MyParser>>#nextToken` reads one token at a time.

Topics:

# Parse tokens lazily
Why: the stream was re-scanned for every token.
- MyParser>>#nextToken reads one token, not the whole stream
- MyToken
- MyToken>>#value <- MyParser>>#tokenValueAt: extracted from the parser
- README.md')) open
```

- Before the `Topics:` line: the pull request title and description, as written; its `#` headings and `- ` lines are not topics or changes.
- After it, `# ` starts a topic, the lines below explain it, `- ` lines list its changes.
- After a change: why it was made, and `<- Other>>#ref` when its code was moved from another change (the diff then compares with that code).

The `pharo-review` agent skill describes the whole workflow; `DESIGN.md` describes the tool in detail.
## Development

- Packages: `ObscureCodeReviewer` (Model and UI tags), `ObscureCodeReviewer-Tests`, `BaselineOfObscureCodeReviewer`.
- Only `OCRIcebergReader` knows Iceberg; everything else works on plain `OCRChange` and is tested without a repository.
- Run the tests in `ObscureCodeReviewer-Tests`.

## License

MIT
