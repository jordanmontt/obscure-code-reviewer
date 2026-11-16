# Obscure Code Reviewer — Design

A small Spec 2 application for Pharo 15 to review code changes (typically written by an agent) inside the image, where there are no files to diff.

## What a review is

A review is **everything between a base commit and the current image**, as computed by Iceberg.

Supported bases:

- **Last commit (HEAD):** uncommitted changes only.
- **Branch split point:** where the current branch split from another branch. This includes the commits on the branch *and* the uncommitted changes.

Default base:

- On a feature branch: the split point with `main`.
- On `main` itself: the split point with `origin/main`, i.e. everything not pushed yet.

The window title always shows the repository and the base used.

Not supported: reviewing commit by commit. Picking an arbitrary base commit may come later.

> Note: the tool works best when work happens on its own branch. On `main`, the split point between `main` and `main` is the last commit, so the review shrinks to uncommitted changes (or to unpushed work when compared to `origin/main`).

## Organization of changes

### Structural tab (always available)

Follows Iceberg's tree shape, without the `src` directory level, split into sections:

- sections **Code**, **Tests** (package name contains `-Test`) and **Baseline** (package name starts with `BaselineOf`); empty sections are hidden
- package → class (and `Foo class` for class-side) → method
- icons show what each node is: section, package, class, extension, method
- extension methods under their own node in the package
- a changed class definition or class comment is the class node itself
- each item is marked as added (`+`), modified (`~`), or removed (`-`); added and removed items are also colored with the current theme's success and danger text colors, so dark and custom themes work

### Topics tab (optional, needs a review guide)

The agent groups changes by what they do (e.g. "Optimize parsing"), across packages. The guide is Markdown:

```markdown
# Optimize parsing
Why: avoid re-scanning the stream for every token.
- OCRParser>>#nextToken
- OCRParser class>>#on:
- OCRToken
```

- `#` headings are topics; the text below is the explanation; `- ` lines are changes.
- A change belongs to exactly one topic. If listed twice, the first topic keeps it.
- Changes not mentioned go to **"Not covered by any topic"**.
- Problems (duplicates, items not in the diff) appear in a warnings list and never block the review.
- The guide gets into the image either:
  - stored by the agent through the MCP: `OCRReviewGuide forRepositoryNamed: 'x' put: '…'`, or
  - pasted by the user in a "Guide" text box.
- The tool works fully without a guide.

## Window

```
┌ Toolbar: [Refresh] [Copy review]                         ┐
├ Changes tree ──┬ Diff: base │ image ──────────────────────┤
│ Package        │                                          │
│  Class         ├ Comment on selected item ────────────────┤
│   + method     │                                          │
├ General comment (whole review) ───────────────────────────┤
```

- Side-by-side diff (`SpDiffPresenter`), old on the left, new on the right.
- Items with a comment are marked in the tree.

## Comments

- One comment per method or class definition, plus one general comment.
- No line-level comments (write "line 3: …" in the method comment).
- Kept in memory only, while the window is open.
- **Refresh** recomputes the diff and keeps comments matched by `Class>>#selector`. Comments whose item disappeared are moved into the general comment, flagged "(item no longer in diff)".

### Copy review

Copies Markdown to the clipboard, ready to paste to the agent. Only commented items are included:

```markdown
Review of <repo>, base <short commit id> (<label>)

## General
<general comment>

## Foo>>#bar (modified)
<comment>
```

## Opening the tool

- Playground: `(OCRReviewPresenter onRepositoryNamed: 'my-project') open`
- World menu: **Browse → Obscure Code Reviewer** (next to Playground), opening a picker.
- Picker: list of Iceberg repositories that have a local checkout and loaded packages; base choice; `[Open review]`. `origin/HEAD` is never offered as a branch.

## Code organization

- Packages: `ObscureCodeReviewer` (tags `Model`, `UI`), `ObscureCodeReviewer-Tests`, `BaselineOfObscureCodeReviewer`.
- Class prefix: `OCR`.
- The tool uses its own small model classes (`OCRChange`, `OCRReview`, …). A single reader class knows Iceberg's API and turns an Iceberg diff into `OCRChange`s; it is kept as small as possible.

## Quality rules

- Code must stay understandable and editable by humans.
- Model separate from Spec presenters; presenters stay thin.
- SUnit tests for the model, built from hand-made `OCRMethodChange`s and `OCRClassChange`s. Iceberg itself is not tested.
- No nil as a value: different cases are different classes (`OCRMethodChange` / `OCRClassChange`, `OCRContainerNode` / `OCRChangeNode`).
- Small methods, intention-revealing names, a class comment on every class, no metaprogramming.

## Plan

1. Skeleton: model, Iceberg reader (base = HEAD), window with tree and diff, opened from Playground.
2. Comments, general comment, Copy review, tree markers.
3. Refresh keeping comments.
4. Branch split-point base, with the `main` / `origin/main` default.
5. Picker and world menu entry.
6. Topics: guide parser, guide store, paste box, warnings.
7. README for Pharo developers: clear and straight to the point, including the branch caveat.
8. Ideas from the CodeReview tool (`github://guillep/pharo-review`): Reviewed marks, links from moved code to where it came from, and line counts.

## Process

- Code is installed in the image through the MCP server (port 4000).
- Work happens on `main`; each step is reviewed as uncommitted changes.
- After each step: tests pass, the user reviews (step 1 in Iceberg, then with the tool itself), and commits happen only when the user says so. Pushing is always the user's call.
