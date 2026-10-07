# 👁️ First Reader

Readers before you publish. 

Most AI slop skills look at the text itself: banned words, sentence length, em dashes. They cannot tell you whether a real person would keep reading. This skill simulates two readers going through your draft one passage at a time and reports what happened to them: where they got interested, where they lost interest, where they stopped, and what they still remembered the next day. A third reader only skims the piece and says whether they would have opened it at all. When the run is done you can ask any of the readers follow-up questions. The skill never rewrites your text.

https://github.com/user-attachments/assets/cf222598-39f1-4f37-9f64-505f87925fa7

## Install

```bash
npx skills add https://github.com/Shubhamsaboo/awesome-llm-apps/tree/main/agent_skills/first-reader
```

The [skills CLI](https://skills.sh) installs the folder for compatible
coding agents. You can also copy this directory into an agent's skills
directory. Everything inside is Markdown and stdlib Python. It runs
offline, has no dependencies, and sends nothing off your machine.

## Use

Point your agent at a draft file, or paste the draft, and say who it is for:

> review this, it's a launch post for backend engineers on our blog

A few minutes later the agent reports back in plain language: whether the
skimmer opened it, where each reader got interested or stopped, what they
remembered, and one question for you. It also builds a page that shows
your draft with the readers' comments next to each passage, the skimmer's
verdict, and a strip that shows how attention changed from passage to
passage.

After the run you can keep asking:

- **"ask S what would have kept her past passage 4"**: S answers from her
  own notes, in her own words. She will tell you what was missing, but she
  will not write it for you.
- **"again"**, after you have revised the draft in your editor: the same
  readers read it fresh, and the page shows the previous run's attention
  strip above the new one so you can see what changed.
- **"quick read"**: only the skimmer runs. You get two sentences on whether
  they would open it and why.

The readers are cast from the audience you name in the first sentence.
Describing them as people works better than job titles, for example "a
staff engineer who has built three eval harnesses and wants a reason to
stop". You can save your readers in `.first-reader/audience.json` next to
your drafts so every run in that folder uses the same people.

## Why simulate readers

AI slop skills measure the text. They cannot measure what a reader
experiences, and research on detecting hollow writing shows that the
people who spot it reliably are judging what a piece commits to and what
it leaves in memory, not counting words. So this skill measures the
experience instead.

Three rules keep the simulation honest. The draft is served one passage at
a time, and the feed will not advance faster than a person could read, so
a reader who quits at passage four has never seen passage five. The memory
test is answered from the reader's own notes, never from a second look at
the text. And the readers only report what happened to them and what would
have had to be different for them to keep going; every decision about the
draft stays with you.

## Verify

```bash
python3 agent_skills/evals/first-reader/test_first_reader.py
```

The test builds temporary drafts and checks each part of the skill: the
skim view, the served feed (no text written to disk, reading speed
enforced, one token per reader), the memory quiz, the trust signals, the
reader consult, and the page. The behavior spec is in
[`agent_skills/evals/first-reader/`](../evals/first-reader/). Run each
prompt in `evals.json` in a fresh session with the skill installed and
check the listed expectations. `trigger-cases.json` lists when the skill
should and should not fire. The ledger in the same folder records how the
skill was tested, including five consecutive reads of one real essay.

## Files

```text
first-reader/
|-- SKILL.md
|-- README.md
|-- references/
|   |-- personas.md
|   |-- report.md
|   |-- room.md
|   `-- interview.md
`-- scripts/
    |-- skim.py
    |-- feed.py
    |-- recall.py
    |-- signals.py
    |-- ask.py
    |-- room.py
    `-- room_template.html
```

Part of [awesome-llm-apps](https://github.com/Shubhamsaboo/awesome-llm-apps).
Apache-2.0. Last verified: September 2026.
