# The first-reader page

The review's primary deliverable is a page, not a wall of text: the draft
with the reading still on it. `scripts/room.py` builds it from the run's
raw sessions; you feed it curation through one JSON file so the page
carries a plain-language verdict, the readers' best lines, and the lens
data from the recall and signals steps.

## Build

```
python3 scripts/room.py <run-dir> [--out room.html] [--annotations room-annotations.json]
```

`<run-dir>` is the directory whose subdirectories are the feed.py
sessions. With no annotations the page still works: excerpts are trimmed
mechanically from the logs, and the memory and trust lenses stay hidden.
Always write the annotations file; the mechanical fallback is for
resilience, not for shipping.

Publish the page as an Artifact where you can, or write it beside the
run and open it; give the user the link or path as the review's ending.
Keep the same file path on rebuilds so a published URL survives.

## room-annotations.json

Write it after the recall test and your own read, before building:

- `title`: the page title. Always "First read: <the draft's own title>",
  so the tab says exactly what the page is; room.py defaults to that
  from the first heading if you omit it.
- `skim`: the skim gate's decision, `{"commits": false, "said": "<the
  skimmer's own words, two sentences>"}`. It renders at the top, because
  for most readers that decision is the whole encounter.
- `verdict_lead`, `verdict_rest`: the verdict in plain spoken language.
  Lead with the good news if there is any. No jargon, no codenames, no
  scores. Write it the way you'd tell a friend across a table.
- `readers`: keyed by session directory name:
  `{"initial": "P", "label": "platform eng", "title": "a platform engineer who needs this for a Thursday review"}`.
  The title is a sentence fragment a stranger understands.
- `excerpts`: keyed by session dir, then passage number as a string. One
  or two of the reader's own sentences per passage, trimmed by you. Quote
  the reader; never paraphrase into reviewer-speak.
- `flags`: passage number to a plain phrase a person would say: "best
  moment", "felt misled here", "attention dropped". Never invented
  codenames.
- `memory_phrases`: the exact strings the recall quiz preserved. These
  light up under the "what stuck" lens; everything else ghosts.
- `portable_sentences` and `entities`: from the signals step; they power
  the trust lens.
- `opinions`: the sealed list for opinions-by-permission, as short plain
  sentences. Empty list or omitted means no envelope renders.
- `previous`: on a re-run, `{"summary": "...", "run": "<path to the
  prior run dir>"}`. The summary is one sentence comparing reader
  behavior ("Last time the skeptic quit at passage 2; this time they
  finished") and renders at the top; the run path makes the page draw
  last run's needle strip above this run's, so the author sees the
  orange stretch turn blue (or not).

## Consulting the readers

After the run the readers are still there: each session directory holds
a persona and the log that is that reader's memory, and `skim.txt`
holds the skimmer's decision. When the author asks a reader something:

```
python3 scripts/ask.py <run-dir> skeptic "what would have convinced you at passage 8?"
python3 scripts/ask.py <run-dir> skim "what would have made you open it?"
python3 scripts/ask.py <run-dir> all "did you notice the retention example?"
```

Hand each printed bundle to a fresh subagent and relay the answer in the
reader's voice. The bundle never contains the draft; a reader who
cannot answer from their notes says so. Readers never propose rewrites.

## The saved audience

`.first-reader/audience.json` beside the draft keeps the project's readers
so they stay the same people across drafts and runs:

```json
{
  "venue": "company engineering blog",
  "readers": {
    "keen": {"initial": "E", "label": "adk engineer",
             "title": "an AI engineer whose quality check is reading transcripts by hand"},
    "skeptic": {"initial": "S", "label": "eval skeptic",
                "title": "a staff engineer who has built eval harnesses and wants a reason to stop"}
  }
}
```

Reuse it for casting and for the `readers` block of the annotations;
change it only when the author names a different audience.

## The run manifest

Before the timed reads, write `manifest.json` in the run directory:

```json
{
  "draft": "<path>",
  "intended_gist": "<what the reader should think, feel, or do>",
  "casts": {"<session-dir>": "<one-line persona>"},
  "previous_run": "<path to the prior run dir, or null>"
}
```

On a re-run after revision: reuse the casts from the prior manifest so
the comparison is honest, point `previous_run` at it, and lead both the
chat verdict and the room's `previous` line with what changed in reader
behavior. Fresh readers every time; only the casts repeat.
