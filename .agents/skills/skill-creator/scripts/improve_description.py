#!/usr/bin/env python3
"""Improve a skill description based on eval results.

Takes eval results (from run_eval.py) and generates an improved description
using the configured backend (Anthropic API or Codex CLI).
"""

import argparse
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

try:
    import anthropic
except ImportError:  # pragma: no cover - optional dependency for codex-only mode
    anthropic = None

from scripts.utils import parse_skill_md


def resolve_backend(backend: str, client_available: bool) -> str:
    if backend in ("anthropic", "codex"):
        return backend
    if backend != "auto":
        raise ValueError(f"Unsupported backend: {backend}")
    if client_available:
        return "anthropic"
    if shutil.which("codex"):
        return "codex"
    raise RuntimeError("No available backend. Install anthropic SDK or codex CLI.")


def run_anthropic_prompt(
    client: object,
    prompt: str,
    model: str,
) -> tuple[str, str]:
    if not model:
        raise ValueError("--model is required for anthropic backend.")
    response = client.messages.create(
        model=model,
        max_tokens=16000,
        thinking={
            "type": "enabled",
            "budget_tokens": 10000,
        },
        messages=[{"role": "user", "content": prompt}],
    )

    thinking_text = ""
    text = ""
    for block in response.content:
        if block.type == "thinking":
            thinking_text = block.thinking
        elif block.type == "text":
            text = block.text
    return thinking_text, text


def run_codex_prompt(
    prompt: str,
    model: str | None,
    timeout: int = 300,
) -> tuple[str, str]:
    cmd = [
        "codex",
        "exec",
        "--json",
        "--skip-git-repo-check",
        "--sandbox",
        "read-only",
        "--",
        prompt,
    ]
    if model:
        cmd.extend(["--model", model])

    result = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        encoding="utf-8",
        timeout=timeout,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(f"codex exec failed with exit code {result.returncode}")

    thinking_chunks: list[str] = []
    text = ""
    for line in result.stdout.splitlines():
        line = line.strip()
        if not line or not line.startswith("{"):
            continue
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue

        if event.get("type") != "item.completed":
            continue
        item = event.get("item", {})
        if item.get("type") == "reasoning":
            chunk = item.get("text", "")
            if chunk:
                thinking_chunks.append(chunk)
        elif item.get("type") == "agent_message":
            text = item.get("text", "")

    if not text:
        raise RuntimeError("codex backend returned no final message.")

    return "\n".join(thinking_chunks).strip(), text


def run_backend_prompt(
    backend: str,
    prompt: str,
    model: str | None,
    client: object | None,
) -> tuple[str, str]:
    if backend == "anthropic":
        if client is None:
            raise RuntimeError("anthropic backend selected but client is not available.")
        return run_anthropic_prompt(client=client, prompt=prompt, model=model or "")
    return run_codex_prompt(prompt=prompt, model=model)


def extract_description(text: str) -> str:
    match = re.search(r"<new_description>(.*?)</new_description>", text, re.DOTALL)
    if match:
        return match.group(1).strip().strip('"')
    return text.strip().strip('"')


def improve_description(
    client: object | None,
    skill_name: str,
    skill_content: str,
    current_description: str,
    eval_results: dict,
    history: list[dict],
    model: str | None,
    backend: str = "auto",
    test_results: dict | None = None,
    log_dir: Path | None = None,
    iteration: int | None = None,
) -> str:
    """Improve the description based on eval results."""
    resolved_backend = resolve_backend(backend, client_available=client is not None)
    failed_triggers = [
        r for r in eval_results["results"]
        if r["should_trigger"] and not r["pass"]
    ]
    false_triggers = [
        r for r in eval_results["results"]
        if not r["should_trigger"] and not r["pass"]
    ]

    # Build scores summary
    train_score = f"{eval_results['summary']['passed']}/{eval_results['summary']['total']}"
    if test_results:
        test_score = f"{test_results['summary']['passed']}/{test_results['summary']['total']}"
        scores_summary = f"Train: {train_score}, Test: {test_score}"
    else:
        scores_summary = f"Train: {train_score}"

    prompt = f"""You are optimizing a skill description for an AI coding agent skill called "{skill_name}". A "skill" is like a prompt with progressive disclosure: the agent sees the name and description first, and only reads the full markdown contents when it chooses to invoke that skill.

The description appears in the agent's "available_skills" list. The agent decides whether to invoke the skill based only on skill name + description. Your goal is to write a description that triggers for relevant queries, and does not trigger for irrelevant ones.

Here's the current description:
<current_description>
"{current_description}"
</current_description>

Current scores ({scores_summary}):
<scores_summary>
"""
    if failed_triggers:
        prompt += "FAILED TO TRIGGER (should have triggered but didn't):\n"
        for r in failed_triggers:
            prompt += f'  - "{r["query"]}" (triggered {r["triggers"]}/{r["runs"]} times)\n'
        prompt += "\n"

    if false_triggers:
        prompt += "FALSE TRIGGERS (triggered but shouldn't have):\n"
        for r in false_triggers:
            prompt += f'  - "{r["query"]}" (triggered {r["triggers"]}/{r["runs"]} times)\n'
        prompt += "\n"

    if history:
        prompt += "PREVIOUS ATTEMPTS (do NOT repeat these — try something structurally different):\n\n"
        for h in history:
            train_s = f"{h.get('train_passed', h.get('passed', 0))}/{h.get('train_total', h.get('total', 0))}"
            test_s = f"{h.get('test_passed', '?')}/{h.get('test_total', '?')}" if h.get('test_passed') is not None else None
            score_str = f"train={train_s}" + (f", test={test_s}" if test_s else "")
            prompt += f'<attempt {score_str}>\n'
            prompt += f'Description: "{h["description"]}"\n'
            if "results" in h:
                prompt += "Train results:\n"
                for r in h["results"]:
                    status = "PASS" if r["pass"] else "FAIL"
                    prompt += f'  [{status}] "{r["query"][:80]}" (triggered {r["triggers"]}/{r["runs"]})\n'
            if h.get("note"):
                prompt += f'Note: {h["note"]}\n'
            prompt += "</attempt>\n\n"

    prompt += f"""</scores_summary>

Skill content (for context on what the skill does):
<skill_content>
{skill_content}
</skill_content>

Based on the failures, write a new and improved description that is more likely to trigger correctly. When I say "based on the failures", it's a bit of a tricky line to walk because we don't want to overfit to the specific cases you're seeing. So what I DON'T want you to do is produce an ever-expanding list of specific queries that this skill should or shouldn't trigger for. Instead, try to generalize from the failures to broader categories of user intent and situations where this skill would be useful or not useful. The reason for this is twofold:

1. Avoid overfitting
2. The list might get loooong and it's injected into ALL queries and there might be a lot of skills, so we don't want to blow too much space on any given description.

Concretely, your description should not be more than about 100-200 words, even if that comes at the cost of accuracy.

Here are some tips that we've found to work well in writing these descriptions:
- The skill should be phrased in the imperative -- "Use this skill for" rather than "this skill does"
- The skill description should focus on the user's intent, what they are trying to achieve, vs. the implementation details of how the skill works.
- The description competes with other skills for the agent's attention — make it distinctive and immediately recognizable.
- If you're getting lots of failures after repeated attempts, change things up. Try different sentence structures or wordings.

I'd encourage you to be creative and mix up the style in different iterations since you'll have multiple opportunities to try different approaches and we'll just grab the highest-scoring one at the end. 

Please respond with only the new description text in <new_description> tags, nothing else."""

    thinking_text, text = run_backend_prompt(
        backend=resolved_backend,
        prompt=prompt,
        model=model,
        client=client,
    )
    description = extract_description(text)

    # Log the transcript
    transcript: dict = {
        "iteration": iteration,
        "backend": resolved_backend,
        "prompt": prompt,
        "thinking": thinking_text,
        "response": text,
        "parsed_description": description,
        "char_count": len(description),
        "over_limit": len(description) > 1024,
    }

    # If over 1024 chars, ask the model to shorten it
    if len(description) > 1024:
        shorten_prompt = f"Your description is {len(description)} characters, which exceeds the hard 1024 character limit. Please rewrite it to be under 1024 characters while preserving the most important trigger words and intent coverage. Respond with only the new description in <new_description> tags."
        rewrite_input = (
            f"{prompt}\n\nDraft response:\n{text}\n\n"
            f"{shorten_prompt}"
        )
        shorten_thinking, shorten_text = run_backend_prompt(
            backend=resolved_backend,
            prompt=rewrite_input,
            model=model,
            client=client,
        )
        shortened = extract_description(shorten_text)

        transcript["rewrite_prompt"] = shorten_prompt
        transcript["rewrite_thinking"] = shorten_thinking
        transcript["rewrite_response"] = shorten_text
        transcript["rewrite_description"] = shortened
        transcript["rewrite_char_count"] = len(shortened)
        description = shortened

    transcript["final_description"] = description

    if log_dir:
        log_dir.mkdir(parents=True, exist_ok=True)
        log_file = log_dir / f"improve_iter_{iteration or 'unknown'}.json"
        log_file.write_text(json.dumps(transcript, indent=2))

    return description


def main():
    parser = argparse.ArgumentParser(description="Improve a skill description based on eval results")
    parser.add_argument("--eval-results", required=True, help="Path to eval results JSON (from run_eval.py)")
    parser.add_argument("--skill-path", required=True, help="Path to skill directory")
    parser.add_argument("--history", default=None, help="Path to history JSON (previous attempts)")
    parser.add_argument(
        "--backend",
        choices=["auto", "anthropic", "codex"],
        default="auto",
        help="Description optimization backend",
    )
    parser.add_argument("--model", default=None, help="Model name (required for anthropic backend)")
    parser.add_argument("--verbose", action="store_true", help="Print thinking to stderr")
    args = parser.parse_args()

    skill_path = Path(args.skill_path)
    if not (skill_path / "SKILL.md").exists():
        print(f"Error: No SKILL.md found at {skill_path}", file=sys.stderr)
        sys.exit(1)

    eval_results = json.loads(Path(args.eval_results).read_text())
    history = []
    if args.history:
        history = json.loads(Path(args.history).read_text())

    name, _, content = parse_skill_md(skill_path)
    current_description = eval_results["description"]

    if args.verbose:
        print(f"Current: {current_description}", file=sys.stderr)
        print(f"Score: {eval_results['summary']['passed']}/{eval_results['summary']['total']}", file=sys.stderr)

    client = anthropic.Anthropic() if anthropic else None
    new_description = improve_description(
        client=client,
        skill_name=name,
        skill_content=content,
        current_description=current_description,
        eval_results=eval_results,
        history=history,
        model=args.model,
        backend=args.backend,
    )

    if args.verbose:
        print(f"Improved: {new_description}", file=sys.stderr)

    # Output as JSON with both the new description and updated history
    output = {
        "description": new_description,
        "history": history + [{
            "description": current_description,
            "passed": eval_results["summary"]["passed"],
            "failed": eval_results["summary"]["failed"],
            "total": eval_results["summary"]["total"],
            "results": eval_results["results"],
        }],
    }
    print(json.dumps(output, indent=2))


if __name__ == "__main__":
    main()
