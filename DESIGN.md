# Obscure Code Reviewer — Design

A small Spec 2 application for Pharo 15 to review code changes (typically written by an agent) inside the image, where there are no files to diff.

## What a review is

A review is **everything between a base commit and the current image**, as computed by Iceberg, plus the other files of the repository:

- **Code** of the packages loaded in the image: Iceberg's diff between the base commit and the image (`OCRMethodChange`, `OCRClassChange`). Class definitions are printed in the fluid format the System Browser shows (`Object << #Foo slots: {…}; tag: …; package: …`), with the comment below, instead of Iceberg's old `subclass:instanceVariableNames:…` format. The base version of a class is not in the image, so `OCRClassDefinitionPrinter` prints both sides from the Monticello definitions Iceberg keeps, following Pharo's `FluidClassDefinitionPrinter` (tests compare the two on real classes); class variables stay in Monticello's sorted order, so the diff is stable. Traits are printed the same way (`Trait << #TFoo …`, class side `Trait << TFoo classTrait`), and an empty class side is hidden for traits as for classes.
- **Files** (`OCRFileChange`): every other file (README, DESIGN.md, `.properties`, the files of packages that are not loaded), compared as a whole between the base commit and the disk. Only files that the base commit or the last commit has are compared, so a brand-new file shows up once it is committed. A file that is not text on both sides (not UTF-8, or with a NUL byte) is binary (`OCRBinaryFileChange`): instead of a diff, the window shows its kind and sizes (e.g. `Binary file, modified: 1.20 KB → 2.00 KB`), and for a picture (PNG, JPEG, GIF, BMP) the base and disk versions side by side. A Markdown file (`.md`, `.markdown`, an `OCRMarkdownFileChange`) shows the text diff (**Source**, the default); **Rendered** switches to Microdown (`MicrodownPresenter`), base and disk side by side, and the choice stays while moving between Markdown files.

Supported bases (`OCRLastCommitBase`, `OCRSplitBase`):

- **Last commit (HEAD):** uncommitted changes only.
- **Branch split point:** where the current branch split from another branch, local (`main`) or remote (`origin/main`). This includes the commits on the branch *and* the uncommitted changes.

Default base (`OCRDefaultBaseRule`). It never fails: when nothing better fits, it uses the last commit. The main branch is the first local branch named `main` or `master`.

| Situation | Base | The review shows |
|---|---|---|
| On another branch, and the project has `main` or `master` | split from the main branch | the whole branch, like a pull request |
| On the main branch, with an upstream | split from its upstream (e.g. `origin/main`) | everything not pushed yet |
| On the main branch, never pushed | last commit | uncommitted changes |
| No `main` and no `master` | last commit | uncommitted changes |
| No branch checked out (detached HEAD) | last commit | uncommitted changes |

The window title always shows the repository and the base used, e.g. `base: 8808718 (split from origin/main)`. The picker lets the user choose another base.

Not supported: reviewing commit by commit. Picking an arbitrary base commit may come later.

> Note: the tool works best when work happens on its own branch. On `main`, the split point between `main` and `main` is the last commit, so the review shrinks to uncommitted changes (or to unpushed work when compared to `origin/main`).

## Organization of changes

### Structural tab (always available)

Follows Iceberg's tree shape, without the `src` directory level, split into sections:

- sections **Code**, **Tests** (package name contains `-Test`), **Baseline** (package name starts with `BaselineOf`) and **Files** (a flat list of paths); empty sections are hidden
- package → class (and `Foo class` for class-side) → method
- icons show what each node is: section, package, class, extension, method
- extension methods under their own node in the package
- a changed class definition or class comment is the class node itself
- each item is marked as added (`+`), modified (`~`), or removed (`-`); added and removed items are also colored with the current theme's success and danger text colors, so dark and custom themes work
- each node shows the lines added and removed under it, e.g. `~ refresh  (6 lines)` (nothing for binary files, which have no lines)
- a commented node is **bold** and marked `[commented]`

### Topics tab (optional, needs a review guide)

The agent groups changes by what they do (e.g. "Optimize parsing"), across packages. The guide is Markdown (`OCRGuideParser`):

```markdown
Title: Parse tokens lazily
The parser re-scanned the stream for every token; it now reads one token at a time.

# Optimize parsing
Why: avoid re-scanning the stream for every token.
- OCRParser>>#nextToken reads one token, not the whole stream
- OCRParser class>>#on:
- OCRToken
- OCRToken class
- OCRToken>>#value <- OCRParser>>#tokenValueAt: extracted from the parser
- README.md
```

- Text before the first topic is the **pull request description**: an optional first line `Title: …`, then the body (see "Pull request tab").
- `# ` headings are topics; the other lines below are the explanation; `- ` lines are changes.
- A change is written as in the copied review: `Foo>>#bar`, `Foo class>>#bar`, `Foo` for a class definition, `Foo class` for a class-side definition, and a path for a file. Backquotes are ignored (put a path with spaces between them) and `Foo>>bar` is read as `Foo>>#bar`.
- After the reference, the rest of the line is **why that change** was made; it is shown above its diff.
- `<- Other>>#ref` after the reference says the code was **moved or extracted** from that change: the diff then compares the new code with the old code of `Other>>#ref`, and says so above the diff.
- A change belongs to exactly one topic. If listed twice, the first topic keeps it.
- Changes not mentioned go to **"Not covered by any topic"**.
- Problems (a change in two topics, a change not in the diff, code moved from a change not in the diff) appear as warnings in the Guide tab and never block the review.
- Selecting a topic shows its explanation in the diff area; a topic can be commented like a change.
- The guide gets into the image either:
  - stored by the agent through the MCP: `OCRReviewGuide forRepositoryNamed: 'x' put: '…'` (kept in memory while the image runs, one guide per repository; storing again replaces it), or
  - pasted or edited by the user in the **Guide** tab, then **Apply** (which stores it the same way and refreshes).
- Refresh re-reads the stored guide.
- The tool works fully without a guide: the Topics tab then has only "Not covered by any topic".

### Pull request tab

The title and body of the pull request the changes will become (`OCRPullRequest`). The tool does not open pull requests: the agent does, from this text, following its own pull request style (see the `pharo-review` skill).

- The agent drafts them at the top of the guide; the reviewer edits them here.
- Edits are kept in memory like comments, and survive a refresh (the reviewer's version wins over a new draft).
- Copy review includes them only when the reviewer changed the draft.

## Window

```
┌ Toolbar: [Refresh] [Copy review] [Reviewed] [Browse] [Edit] [Save] [Cancel] ┐
├[Structure][Topics][Guide][Pull request]┬ Why / moved from (when the guide says) ┤
│ Package                                ├ Diff: base │ image (or topic text) ──┤
│  Class                   ├ Comment on selected change or topic ────┤
│   + method               │                                         │
├ General comment (whole review) ────────────────────────────────────┤
```

- Side-by-side diff (`SpDiffPresenter`), old on the left, new on the right.
- An added or removed change has one side only, so it is shown alone, in one read-only code pane titled **Added** or **Removed**. A method is highlighted for its class, and the protocol line Iceberg writes above it (`"accessing"`) moves into the title (`Added — protocol: accessing`); in a diff that line stays, as it shows a change of protocol. Class definitions (which carry their comment below) and files are not highlighted. Code moved from another change (`<-` in the guide) keeps its diff.
- Double-clicking a change in a tree opens it alone in its own large, read-only window (an `OCRChangeAreaPresenter`), titled with its reference: for long lines, which the diff does not wrap, and long methods. Several can stay open side by side.
- Items with a comment are bold and marked `[commented]` in the tree.
- Each tab explains itself when the mouse is over it.

## Reviewed marks

- **Reviewed** marks the selected change as reviewed, or every change under the selected node (package, class, topic, section). When everything selected is already reviewed, the button reads **Unmark** and unmarks it.
- A node shows `[reviewed]` when every change under it is reviewed.
- Marks are kept in memory, like comments. A refresh keeps the mark of a change only while its code is exactly the same: changed code must be reviewed again.

## Editing by hand

For small fixes, the reviewer edits a method without going back to the agent:

- **Edit** replaces the diff with a code editor holding the method's source in the image.
- **Save** (or Cmd+S) compiles it, keeping its protocol, then refreshes the review (comments and selection kept). A compile error is shown in the editor, which stays open.
- **Cancel** goes back to the diff without saving.
- While editing, the tree and Refresh are disabled: Save or Cancel first.
- Only added and modified methods can be edited. Removed methods are not in the image; class definitions are edited in the System Browser.

## Comments

- One comment per method, class definition or topic, plus one general comment.
- No line-level comments (write "line 3: …" in the method comment).
- Kept in memory only, while the window is open.
- **Refresh** recomputes the diff and keeps comments matched by `Class>>#selector`. Comments on topics are kept while the topic is in the guide. Comments whose item disappeared are moved into the general comment, flagged "(item no longer in diff)".

### Copy review

Copies Markdown to the clipboard, ready to paste to the agent. Only commented items are included:

```markdown
Review of <repo>, base <short commit id> (<label>)
Reviewed: 12 of 40 changes.

## Pull request (edited by the reviewer)
Title: <title>

<body>

## General
<general comment>

## Topic: Optimize parsing
<comment on the topic>

## Foo>>#bar (modified)
<comment>

## Not reviewed yet
- Foo>>#baz (added)
```

Order: the progress line and the "Not reviewed yet" list only when at least one change is marked; the pull request only when the reviewer edited it; then the general comment, topics in the guide's order, and changes in Structure tree order.

## Opening the tool

- Playground: `(OCRReviewPresenter onRepositoryNamed: 'my-project') open`
- World menu: **Browse → Obscure Code Reviewer** (below Playground) opens the picker, a dialog (`OCRPickerPresenter`):
  - **Repository:** the Iceberg repositories with a local checkout and loaded packages.
  - **Compare with:** the default base first, marked "(default)", then the last commit, then the split point from each local and remote branch other than the current one (`OCRBaseChoices`). `origin/HEAD` is never offered.
  - **Open review** opens the review window; **Cancel** closes the dialog.

## Code organization

- Packages: `ObscureCodeReviewer` (tags `Model`, `UI`), `ObscureCodeReviewer-Tests`, `BaselineOfObscureCodeReviewer`.
- Main classes:
  - model: `OCRReview` (changes, marks, guide, pull request), `OCRReviewComments`, `OCRChange` and its subclasses, `OCRReviewGuide` / `OCRGuideParser` / `OCRTopic`, `OCRPullRequest`, the bases and `OCRDefaultBaseRule`, `OCRBaseChoices`;
  - trees: `OCRStructuralTreeBuilder`, `OCRTopicTreeBuilder`, and the nodes `OCRContainerNode`, `OCRChangeNode`, `OCRTopicNode`;
  - output: `OCRFeedbackWriter` (Copy review);
  - Iceberg: `OCRIcebergReader` only;
  - UI: `OCRReviewPresenter` (the window), made of `OCRReviewToolbar`, `OCRReviewTabsPresenter` (the four tabs, with `OCRGuidePresenter`, `OCRPullRequestPresenter` and `OCRNotebookPage` for the hover help) and `OCRChangeAreaPresenter` (diff, notes, editor, topic text, `OCRMarkdownFilePresenter`, `OCRBinaryFilePresenter`); `OCRPickerPresenter`.
- Class prefix: `OCR`.
- The tool uses its own small model classes (`OCRChange`, `OCRReview`, …). A single reader class knows Iceberg's API and turns an Iceberg diff into `OCRChange`s; it is kept as small as possible.

## Quality rules

- Code must stay understandable and editable by humans.
- Model separate from Spec presenters; presenters stay thin.
- SUnit tests for the model, built from hand-made `OCRMethodChange`s, `OCRClassChange`s and `OCRFileChange`s. Iceberg itself is not tested, so `OCRIcebergReader` is not either.
- No nil as a value: different cases are different classes (`OCRMethodChange` / `OCRClassChange`, `OCRContainerNode` / `OCRChangeNode`).
- Small methods, intention-revealing names, a class comment on every class, no metaprogramming.
- The Pharo critics (`critique_run` over the three packages) report nothing, except two false positives: `BaselineOfObscureCodeReviewer` (loaded by Metacello by name) and `OCRPickerPresenter` (used from its `<worldMenu>` pragma) are "not referenced".

## Plan

1. Skeleton: model, Iceberg reader (base = HEAD), window with tree and diff, opened from Playground.
2. Comments, general comment, Copy review, tree markers.
3. Refresh keeping comments.
4. Edit added and modified methods by hand in the review window.
5. Branch split-point base, with the `main` / `origin/main` default.
6. Picker and world menu entry.
7. Topics: guide parser, guide store, paste box, warnings.
8. Files and pull request: non-code files and packages not loaded, the Pull request tab, why on a single change (ideas from the CodeReview tool, `github://guillep/pharo-review`).
9. Reviewed marks, moved-code links, line counts, "Not reviewed yet" in Copy review (also from CodeReview).
10. README for Pharo developers: clear and straight to the point, including the branch caveat.

Not planned: a "Create pull request" button. Opening a pull request needs the agent's PR style and the reviewer's go-ahead, which live in the agent skills, not in the image.

## Process

- Code is installed in the image through the MCP server (port 4000).
- Work happens on `main`; each step is reviewed as uncommitted changes.
- After each step: tests pass, the user reviews (step 1 in Iceberg, then with the tool itself), and commits happen only when the user says so. Pushing is always the user's call.
