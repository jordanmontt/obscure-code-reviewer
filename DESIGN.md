# Obscure Code Reviewer — Design

A small Spec 2 application for Pharo 15 (it relies on Spec 15) to review code changes (typically written by an agent) inside the image, where there are no files to diff.

## What a review is

A review is **everything between a base commit and the current image**, as computed by Iceberg, plus the other files of the repository:

- **Code** of the packages loaded in the image: Iceberg's diff between the base commit and the image (`OCRMethodChange`, `OCRClassChange`). Class definitions are printed in the fluid format the System Browser shows (`Object << #Foo slots: {…}; tag: …; package: …`), with the comment below, instead of Iceberg's old `subclass:instanceVariableNames:…` format. The base version of a class is not in the image, so `OCRClassDefinitionPrinter` prints both sides from the Monticello definitions Iceberg keeps, following Pharo's `FluidClassDefinitionPrinter` (tests compare the two on real classes); class variables stay in Monticello's sorted order, so the diff is stable. Traits are printed the same way (`Trait << #TFoo …`, class side `Trait << TFoo classTrait`), and an empty class side is hidden for traits as for classes.
- **Files** (`OCRFileChange`): every other file (README, DESIGN.md, `.properties`, the files of packages that are not loaded), compared as a whole between the base commit and the disk. Git says which files changed (`OCRIcebergReader>>#changedFilePathsIn:since:`): committed since the base, staged, or changed on disk; only those are read. A file git does not track is not listed, so a brand-new file shows up once it is added or committed. A file that is not text on both sides (not UTF-8, or with a NUL byte) is binary (`OCRBinaryFileChange`): instead of a diff, the window shows its kind and sizes (e.g. `Binary file, modified: 1.20 KB → 2.00 KB`), and for a picture (PNG, JPEG, GIF, BMP) the base and disk versions side by side. A Markdown file (`.md`, `.markdown`, an `OCRMarkdownFileChange`) opens **Rendered** (the default): rendered with Microdown, base and disk side by side; **Source** switches to the text diff, and the choice stays while moving between Markdown files. An added or removed Markdown file shows its one side alone, titled **Added** or **Removed**. It is rendered only when Rendered is shown, and the tool composes the rich text itself (`Microdown asRichText:`), so that when Microdown fails on a file (e.g. inline code holding only a number, pillar-markup/Microdown#1114) the window shows the source with the reason above it instead of a debugger.

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

The base, the commit it resolved to and a warning when it may be wrong form an `OCRReviewBase`. When the base is a split from a local branch that lacks commits of its upstream (e.g. after a pull request was merged on GitHub and not pulled), the review would show what the upstream already merged: the window title and Copy review warn, e.g. `main (d274ab5) is behind origin/main (ae02d54)`. The base is not changed automatically.

Not supported: reviewing commit by commit. Picking an arbitrary base commit may come later.

> Note: the tool works best when work happens on its own branch. On `main`, the split point between `main` and `main` is the last commit, so the review shrinks to uncommitted changes (or to unpushed work when compared to `origin/main`).

## Organization of changes

### Files view (always available)

Follows Iceberg's tree shape, without the `src` directory level, split into sections:

- sections **Code**, **Tests** (package name contains `-Test`), **Baseline** (package name starts with `BaselineOf`) and **Files** (a flat list of paths); empty sections are hidden
- package → class (and `Foo class` for class-side) → method
- icons show what each node is: section, package, class, extension, method
- extension methods under their own node in the package
- a changed class definition or class comment is the class node itself
- each change is marked **A** (added), **M** (modified) or **D** (deleted), colored with the current theme's success, warning and danger text colors, so dark and custom themes work; a deleted change is also struck through
- a commented change is **bold** and says `commented`; a group says how many of its changes are reviewed (`3 / 7`)
- each row has a checkbox: ticking it marks everything under it as reviewed

### Topics view (optional, needs a review guide)

The agent groups changes by what they do (e.g. "Optimize parsing"), across packages. The guide is Markdown (`OCRGuideParser`):

```markdown
Title: Parse tokens lazily
The parser re-scanned the stream for every token; it now reads one token at a time.

# Goal
`OCRParser>>#nextToken` reads one token at a time.

Topics:

# Optimize parsing
Why: avoid re-scanning the stream for every token.
- OCRParser>>#nextToken reads one token, not the whole stream
- OCRParser class>>#on:
- OCRToken
- OCRToken class
- OCRToken>>#value <- OCRParser>>#tokenValueAt: extracted from the parser
- README.md
```

- Text before the line `Topics:` is the **pull request description**, as written: an optional first line `Title: …`, then the body (see "Pull request"). Its `#` headings and `- ` lines are part of the description, not topics or changes, so it can follow a pull request style with `# Goal` and `# Main changes`. Without a `Topics:` line, the text before the first topic is the description.
- `# ` headings are topics; the other lines below are the explanation; `- ` lines are changes.
- A change is written as in the copied review: `Foo>>#bar`, `Foo class>>#bar`, `Foo` for a class definition, `Foo class` for a class-side definition, and a path for a file. Backquotes are ignored (put a path with spaces between them) and `Foo>>bar` is read as `Foo>>#bar`.
- After the reference, the rest of the line is **why that change** was made; it is shown above its diff.
- `<- Other>>#ref` after the reference says the code was **moved or extracted** from that change: the diff then compares the new code with the old code of `Other>>#ref`, and says so above the diff.
- A change belongs to exactly one topic. If listed twice, the first topic keeps it.
- Changes not mentioned go to **"Not covered by any topic"**.
- Problems (a change in two topics, a change not in the diff, code moved from a change not in the diff) appear as warnings in the Overview and never block the review.
- Selecting a topic shows its explanation and its changes, each with its note and whether it is reviewed or commented (`OCRTopicPresenter`); double-clicking one selects it. A topic can be commented like a change.
- The title of a change says which topic it is in.
- The guide is not stored anywhere: it belongs to the review window.
  - The agent gives it when it opens the window: `(OCRReviewPresenter onRepositoryNamed: 'x' guide: (OCRReviewGuide fromText: '…')) open`.
  - The user can paste or edit it with **Edit guide…** in the Overview, then **Apply**, which refreshes with the new guide.
- Refresh keeps the window's guide; closing the window forgets it.
- The tool works fully without a guide: the Topics view then has only "Not covered by any topic".

### Pull request

The title and body of the pull request the changes will become (`OCRPullRequest`). The tool does not open pull requests: the agent does, from this text, following its own pull request style (see the `pharo-review` skill).

- The agent drafts them at the top of the guide; the reviewer edits them in the Overview.
- Edits are kept in memory like comments, and survive a refresh (the reviewer's version wins over a new draft).
- Copy review includes them only when the reviewer changed the draft.

## Window

The window is meant to be simple, not an IDE: one thing selected at a time, and only the actions that apply to it, next to it. Screenshots are in `docs/`.

```
┌ repository, base         12 of 40 reviewed, 5 comments ▓▓░░  [Review all] [Refresh] [Finish review] ┐
├ [Files][Topics] ──────────┬ Code › MyPackage › MyClass     Topic: …                                   ┤
│ Overview                  │ MyClass>>#bar  modified           [Browse] [More ▾] [Reviewed]           │
│ ▾ Code            7 / 24 ☐│ Why / moved from (when the guide says)                                   │
│   ▾ MyPackage            ☐│ Diff: base │ image   (or the topic, or the overview)                     │
│      M bar   commented   ☑│ Your comment on MyClass>>#bar                                            │
├ Cmd+R reviewed & next   Cmd+A select all   Cmd+B browse   Cmd+E edit   Cmd+M impl.   Cmd+N senders ──┤
```

- **Header** (`OCRReviewHeaderPresenter`, then the buttons): the repository, what it is compared with (with the warning when the base may be wrong), the progress, **Review all**, **Refresh** and **Finish review**.
- **Sidebar** (`OCRReviewSidebarPresenter`): the Files and Topics trees, as the two pages of a notebook (`SpNotebookPresenter`), which builds each tree once and keeps it; both start with the **Overview** row (`OCROverviewNode`) and open expanded. The selection is the one of the tree shown. Switching keeps the selected change selected when the other tree has it, or else selects the Overview, so the page is never empty.
- **Several rows** can be selected; Cmd+A (or **Select all** in the right-click menu) selects them all. The selection is then a node grouping them, titled with how many changes they hold (e.g. `279 changes selected`): Reviewed marks them all, and it cannot be commented. Selecting all rows of a few hundred takes seconds, in FastTable and Spec, not here (pharo-project/pharo#19954). In a tree with multiple selection, Spec's `selectItem:` and `selectItems:` add to the selection row by row; the window selects one row with `selectPaths:`, which replaces it (`OCRReviewSidebarPresenter>>#selectOnly:`).
- **The selection:** its title, under the groups it is in, and the buttons that act on it: **Browse**, **More** (Edit, Implementors, Senders) and **Reviewed**. Below, the change (`OCRChangeAreaPresenter`), the topic (`OCRTopicPresenter`) or the overview (`OCROverviewPresenter`: pull request, progress by topic, guide warnings and **Edit guide…**, base); then the comment on a change or topic.
- **Finish review** (`OCRFinishReviewPresenter`, a dialog): what is reviewed and commented, what is not reviewed yet, the general comment, **Keep reviewing** and **Copy review**.
- The buttons, the window's shortcuts and the trees' right-click menu come from the same actions, each written once in `OCRReviewPresenter` (`refreshAction`, `reviewedAction`, `editAction`, …). The buttons are never hidden, only disabled: Morphic does not lay out again a widget hidden then shown. For the same reason the selection's content is one presenter whose children are replaced, and **Save** and **Cancel** come with the editor, above it. When the Reviewed button reads Unmark, its icon is the undo icon, in the menu too (`dynamicIconName:`, from pharo-spec/Spec#2004).
- With nothing selected, the window asks an empty node (`OCRReviewSidebarPresenter>>#selectedNode`), which has nothing to show, comment, browse or mark. A group, several rows or nothing selected show a one-line message instead of a diff.

### Widgets of an open window

In Spec 15, removing a presenter from the layout of an open window does not let go of its widgets: they stay in memory, keep reacting to the presenter, and every later build gets slower (selecting the same 10 changes took up to 224 ms each, then 602, then 989). The causes are in Spec (logged as an upstream issue): `SpMorphicBoxAdapter>>#removeAll` does not unsubscribe the children's adapters, a box adapter never unsubscribes from its layout, and `#unsubscribe:` misses the presenter's announcer and the vertical alignment of lists and trees. So the window:

- replaces content only when it changes (`OCRReviewPresenter>>#showContentMadeOf:`, `OCRChangeAreaPresenter>>#showPresenters:`): moving from one modified method to another only changes texts;
- removes children with `SpBoxLayout>>#ocrRemoveAll`, which first releases the adapters of the removed presenter and of everything inside it (`SpPresenter>>#ocrReleaseWidgets`, `#ocrReleaseAdapter`, `SpExecutableLayout>>#ocrReleaseAdapters`, extensions of Spec classes in this package);
- never takes a tree off screen (the notebook keeps both): a tree's selection keeps its old adapter in a way that cannot be released from outside.

Tests open a real window to check that switching changes and views leaves no old widget in memory (`OCRReviewDriver>>#liveDiffWidgets`, `#liveTreeWidgets`; Morphic lets go of removed widgets only once the UI process has run). Measured after: 50–80 ms per selection, flat; Files → Topics → Files about 155 ms (was 1.2–2 s). Left: about 6 small widgets per Markdown file shown, which `OCRMarkdownFilePresenter`'s layout swap still keeps.
- Side-by-side diff (`SpDiffPresenter`), old on the left, new on the right.
- An added or removed change has one side only, so it is shown alone, in one read-only code pane titled **Added** or **Removed**. A method is highlighted for its class, and the protocol line Iceberg writes above it (`"accessing"`) moves into the title (`Added — protocol: accessing`); in a diff that line stays, as it shows a change of protocol. Class definitions (which carry their comment below) and files are not highlighted. Code moved from another change (`<-` in the guide) keeps its diff.
- The code panes and the comment boxes offer Pharo's code search on the selection: right-click → **Code search**, Cmd+M for implementors, Cmd+N for senders. The comment boxes are code panes without highlighting, line numbers or smart characters, so they read as plain text. Each review runs in its own application, an `OCRApplication` (see `OCRReviewPresenter class>>#currentApplication`); a review opened from the picker runs in the picker's. Spec runs a code pane's commands in the pane's application, so the browsers they open run in it too: it is a Pharo tool application (a subclass of `StPharoApplication`) because they fail in Spec's default null application. It is never `run`, which would make it the Pharo IDE's application and close its windows.
- Double-clicking a change in a tree opens it alone in its own large, read-only window (an `OCRChangeAreaPresenter`), titled with its reference: for long lines, which the diff does not wrap, and long methods. Several can stay open side by side.
- Comments are written in `OCRCommentPresenter` panes.

## Reviewed marks

- **Reviewed** (Cmd+R) marks the selected change as reviewed and selects the next change not reviewed, in the order of the tree shown, starting over at the top. On a group or a topic it marks every change under it. When everything selected is already reviewed, the button reads **Unmark** and unmarks it.
- With several rows selected (Cmd+A selects them all), Reviewed marks every change they hold.
- **Review all** marks every change of the review; it is disabled once everything is reviewed.
- The checkbox of a row does the same for that row, without moving the selection.
- A group shows how many of its changes are reviewed, and its checkbox is ticked when they all are.
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
Warning: main (d274ab5) is behind origin/main (ae02d54)
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

Order: the warning only when the base may be wrong; the progress line and the "Not reviewed yet" list only when at least one change is marked; the pull request only when the reviewer edited it; then the general comment, topics in the guide's order, and changes in Files tree order.

## Opening the tool

- Playground: `(OCRReviewPresenter onRepositoryNamed: 'my-project') open`
- World menu: **Browse → Obscure Code Reviewer** (below Playground) opens the picker, a dialog (`OCRPickerPresenter`):
  - **Repository:** the Iceberg repositories with a local checkout and loaded packages.
  - **Compare with:** the default base first, marked "(default)", then the last commit, then the split point from each local and remote branch other than the current one (`OCRBaseChoices`). `origin/HEAD` is never offered.
  - **Open review** opens the review window; **Cancel** closes the dialog.

## Code organization

- Packages: `ObscureCodeReviewer` (tags `Model`, `UI`), `ObscureCodeReviewer-Tests`, `BaselineOfObscureCodeReviewer`.
- Main classes:
  - model: `OCRReview` (changes, marks, guide, pull request), `OCRReviewComments`, `OCRChange` and its subclasses, `OCRReviewGuide` / `OCRGuideParser` / `OCRTopic`, `OCRPullRequest`, the bases, `OCRReviewBase` and `OCRDefaultBaseRule`, `OCRBaseChoices`;
  - trees: `OCRStructuralTreeBuilder`, `OCRTopicTreeBuilder`, and the nodes `OCRContainerNode`, `OCRChangeNode`, `OCRTopicNode`;
  - output: `OCRFeedbackWriter` (Copy review);
  - Iceberg: `OCRIcebergReader` only;
  - UI: `OCRReviewPresenter` (the window and its actions), made of `OCRReviewHeaderPresenter` (repository, base, progress), `OCRReviewSidebarPresenter` (the Files and Topics trees), `OCRChangeAreaPresenter` (diff, notes, editor, `OCRMarkdownFilePresenter`, `OCRBinaryFilePresenter`), `OCRTopicPresenter`, `OCROverviewPresenter` (with `OCRPullRequestPresenter`, and `OCRGuidePresenter` in its own window) and `OCRCommentPresenter`; `OCRFinishReviewPresenter`; `OCRPickerPresenter`. `OCRStyleContributor` holds the window's styles, all from the theme's colors.
- Class prefix: `OCR`.
- The tool uses its own small model classes (`OCRChange`, `OCRReview`, …). A single reader class knows Iceberg's API and turns an Iceberg diff into `OCRChange`s; it is kept as small as possible.

## Quality rules

- Code must stay understandable and editable by humans.
- Model separate from Spec presenters; presenters stay thin.
- The window is tested as a reviewer uses it, through `OCRReviewDriver`: select a change, click a button by its name, comment, read what is shown. The tests never name a presenter or say where a button sits, so a new layout changes the driver, not the tests.
- SUnit tests for the model, built from hand-made `OCRMethodChange`s, `OCRClassChange`s and `OCRFileChange`s; the builders the tests share are in `OCRTestCase`. Iceberg and git themselves are not tested: `OCRIcebergReader` is tested only where it works on plain files (`OCRIcebergReaderTest`, with in-memory stubs).
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
7. Topics: guide parser, paste box, warnings.
8. Files and pull request: non-code files and packages not loaded, the Pull request tab, why on a single change (ideas from the CodeReview tool, `github://guillep/pharo-review`).
9. Reviewed marks, moved-code links, line counts (removed later: unused), "Not reviewed yet" in Copy review (also from CodeReview).
10. README for Pharo developers: clear and straight to the point, including the branch caveat.
11. A simpler window: a header with the progress, Files | Topics instead of four tabs, only the actions of the selection next to it, Reviewed goes to the next change, an Overview, and a Finish review dialog with the general comment. The window tests go through a driver first, so they survive the new layout.
12. Speed: profile switching changes, switching views and selecting all; release the widgets Spec keeps when a presenter leaves an open window; Files and Topics as notebook pages.

Not planned: a "Create pull request" button. Opening a pull request needs the agent's PR style and the reviewer's go-ahead, which live in the agent skills, not in the image.

## Process

- Code is installed in the image through the MCP server (port 4000).
- Work happens on `main`; each step is reviewed as uncommitted changes.
- After each step: tests pass, the user reviews (step 1 in Iceberg, then with the tool itself), and commits happen only when the user says so. Pushing is always the user's call.
