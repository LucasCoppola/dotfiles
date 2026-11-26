---
name: show-me
description: Help the user understand the current topic visually with concise diagrams, code-shape sketches, and focused HTML artifacts.
disable-model-invocation: true
---

Help the user understand the current topic of conversation visually. Skip the preamble and keep prose brief.

Pick the format by what the terminal can render:

- Inline text for code-shaped views: pseudocode, call trees, component trees, file trees, and diffs. A terminal shows these fine at any length that fits on one screen.
- One HTML file (see the last item below) for everything a terminal can't show: boxes-and-arrows diagrams (a terminal prints Mermaid as raw text, so never use Mermaid inline), UI mockups, options to choose between, tables too wide or long to scan, and explainer pages.

Common requests and the shape that fits each:

- How a system or flow works → HTML explainer for one reader (see the page rules below).
- What it is now vs. what you propose → a diff or before/after trees inline; HTML side-by-side if it's architecture.
- A finished plan → the design and how it will work, not the list of small decisions the plan already holds.
- Options or a mockup to pick from → HTML with the options side by side, built from real content, so the user can choose by looking.
- A dense result (findings, an inventory, a merge status) → the same content regrouped so it scans: grouped by what the user acts on, the most important group first.

- Show logic or an algorithm as pseudocode:

```text
on(save)
  if content is unchanged
    return cached result
  write new content
  return fresh result
```

- Show runtime control flow as a call tree:

```text
submitForm
  createSession
    persistPrompt
    launchAgent
  navigateToSession
```

- Show UI structure as a component tree, including state and module boundaries that matter:

```tsx
<SessionPage> (apps/example/src/routes/session.tsx)
  useSessionEvents()
  <SessionToolbar>
    <RunSkillButton> (packages/ui)
```

- Show file responsibility or a broad refactor as a shallow file tree:

```text
src/
├── commands/       # parses user actions
├── sessions/       # owns session state
└── transport/      # sends API requests
```

- Inside an HTML file, show component interaction, control flow, or data flow with a diagram drawn as inline SVG or HTML/CSS. Don't use Mermaid or other CDN scripts: they often fail to render in a local file and leave an empty box.

- Use `diff` when the point is what changes and the surrounding shape already exists. Match the diff shape to the topic.

For a component change:

```diff
 <SessionPage>
   useSessionEvents()
   <SessionToolbar>
+    <RunSkillButton />
   <SessionTimeline>
+    <SkillResultCard />
```

For a file-layout change:

```diff
 src/
 ├── commands/
+│   └── show-me.ts       # expands the slash command
 ├── sessions/
-└── transport.ts
+└── transport/
+    ├── client.ts
+    └── stream.ts
```

For a call-tree or call-stack change:

```diff
 submitForm
   createSession
     persistPrompt
+    expandSkillMention
     launchAgent
-  navigateToSession
+  navigateToSession
+    subscribeToEvents
```

For a state or control-flow change:

```diff
 on(save)
-  write content
+  if content is unchanged
+    return cached result
+  write new content
+  invalidate cache
```

- Show the whole block when most of it is new, when omitted context would hide ownership or order, or when the user needs a copyable target shape:

```ts
function expandSkill(command: string): string {
  const skillName = command.slice(1)
  return `use the ${skillName} skill`
}
```

- For a diagram, UI, layout, comparison of options, or architecture, write one focused HTML file — a diagram, an infographic, or a short slide deck, whichever fits the point. For a UI mockup, match the product's colors, type, spacing, and components. For everything else (explainers, diagrams, comparisons), inline `base.css` from this skill's folder in a `<style>` tag so every page shares one look, and add only page-specific rules after it. Use real labels and data; support desktop and mobile. Then open it for the user:

```
Bash(open path/to/show-me-{description}.html)
```

  Write the HTML page for one reader. Pick who it is (a user or operator, a dev new to the code, a reviewer of a plan) and leave out what that reader doesn't need.
  - Make each heading a claim the reader should remember, not a label. "The recipe is a template, not a file that changes" beats "Configuration".
  - Rank by importance. Simple, obvious steps get one compressed line or strip; give the space to the parts that are surprising, risky, or easy to get wrong.
  - Say why for every non-obvious choice, not only what happens.
  - Stay at the altitude asked for: design and how it works, not every small decision.
  - Add interactivity only when it shows a real choice or variant (a toggle between two configurations), never as decoration.
  - No walls of text. If a section needs more than a short paragraph, it needs a visual instead.

### guidance

Place each visual next to the short text it supports. Keep only the calls, files, props, states, and boundaries needed to answer the user's current question or the options to resolve the current discussion point.

You may use one of these, you may use several, it is unlikely you will use all of them. Use your judgement and don't overwhelm the user.
