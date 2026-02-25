#!/usr/bin/env -S deno run --allow-env --allow-net

type DiscordEmbed = {
  readonly title?: string;
  readonly description?: string;
  readonly url?: string;
  readonly color?: number;
};

type DiscordWebhookMessage = {
  readonly content: string;
  readonly username: string;
  readonly avatar_url?: string;
  readonly embeds?: readonly DiscordEmbed[];
  readonly allowed_mentions?: {
    readonly users?: readonly string[];
  };
};

type CliOptions = {
  readonly title?: string;
  readonly body?: string;
  readonly webhookUrl?: string;
  readonly userId?: string;
  readonly agent?: AgentKind;
  readonly username?: string;
  readonly avatarUrl?: string;
  readonly chunkSize?: number;
  readonly embeds?: readonly DiscordEmbed[];
  readonly dryRun: boolean;
};

type AgentKind = "codex" | "claude";

const WEBHOOK_PREFIX = "https://discord.com/api/webhooks/";
const MAX_DISCORD_MESSAGE_LENGTH = 2000;
const DEFAULT_CODEX_USERNAME = "Codex notification";
const DEFAULT_CLAUDE_USERNAME = "Claude Code notification";
const DEFAULT_AVATAR_URL = "https://avatars.githubusercontent.com/u/14957082";
const AGENT_ENV_NAME = "DISCORD_NOTIFY_AGENT";

const usage = `Usage:
  deno run --allow-env --allow-net ~/.agents/skills/deno-discord-notify/scripts/send_discord_notification.ts --title "<title>" --body "<body>" [options]

Options:
  --title <value>         Required notification title
  --body <value>          Required notification body
  --webhook-url <value>   Override DISCORD_WEBHOOK_URL
  --user-id <value>       Override DISCORD_USER_ID
  --agent <value>         codex or claude (override auto detection)
  --username <value>      Sender username (default: auto by agent)
  --avatar-url <value>    Avatar URL
  --chunk-size <value>    Positive number, capped at 2000
  --embeds-json <value>   JSON array passed to Discord embeds
  --dry-run               Print request payloads without sending
  --help                  Print this help
`;

const splitOption = (token: string): { key: string; inlineValue?: string } => {
  const separatorIndex = token.indexOf("=");
  if (separatorIndex === -1) {
    return { key: token };
  }
  return {
    key: token.slice(0, separatorIndex),
    inlineValue: token.slice(separatorIndex + 1),
  };
};

const readOptionValue = (
  optionName: string,
  inlineValue: string | undefined,
  args: readonly string[],
  currentIndex: number,
): { value: string; nextIndex: number } => {
  if (typeof inlineValue === "string") {
    return { value: inlineValue, nextIndex: currentIndex };
  }
  const next = args[currentIndex + 1];
  if (typeof next !== "string" || next.startsWith("--")) {
    throw new Error(`Missing value for ${optionName}`);
  }
  return { value: next, nextIndex: currentIndex + 1 };
};

const parseEmbeds = (rawValue: string): readonly DiscordEmbed[] => {
  let parsed: unknown;
  try {
    parsed = JSON.parse(rawValue);
  } catch (_error) {
    throw new Error("--embeds-json must be valid JSON");
  }
  if (!Array.isArray(parsed)) {
    throw new Error("--embeds-json must be a JSON array");
  }
  return parsed.map((entry, index) => {
    if (typeof entry !== "object" || entry === null || Array.isArray(entry)) {
      throw new Error(`embeds[${index}] must be an object`);
    }
    const source = entry as Record<string, unknown>;
    const embed: DiscordEmbed = {};
    if (typeof source.title !== "undefined") {
      if (typeof source.title !== "string") {
        throw new Error(`embeds[${index}].title must be a string`);
      }
      embed.title = source.title;
    }
    if (typeof source.description !== "undefined") {
      if (typeof source.description !== "string") {
        throw new Error(`embeds[${index}].description must be a string`);
      }
      embed.description = source.description;
    }
    if (typeof source.url !== "undefined") {
      if (typeof source.url !== "string") {
        throw new Error(`embeds[${index}].url must be a string`);
      }
      embed.url = source.url;
    }
    if (typeof source.color !== "undefined") {
      if (typeof source.color !== "number" || !Number.isInteger(source.color)) {
        throw new Error(`embeds[${index}].color must be an integer`);
      }
      embed.color = source.color;
    }
    return embed;
  });
};

const parseArgs = (args: readonly string[]): CliOptions => {
  const mutable: {
    title?: string;
    body?: string;
    webhookUrl?: string;
    userId?: string;
    username?: string;
    avatarUrl?: string;
    chunkSize?: number;
    embeds?: readonly DiscordEmbed[];
    dryRun: boolean;
  } = {
    dryRun: false,
  };

  for (let index = 0; index < args.length; index += 1) {
    const raw = args[index];
    if (!raw.startsWith("--")) {
      throw new Error(`Unknown positional argument: ${raw}`);
    }
    const { key, inlineValue } = splitOption(raw);
    switch (key) {
      case "--help":
        console.log(usage);
        Deno.exit(0);
      case "--dry-run":
        mutable.dryRun = true;
        break;
      case "--title": {
        const { value, nextIndex } = readOptionValue(key, inlineValue, args, index);
        mutable.title = value;
        index = nextIndex;
        break;
      }
      case "--body": {
        const { value, nextIndex } = readOptionValue(key, inlineValue, args, index);
        mutable.body = value;
        index = nextIndex;
        break;
      }
      case "--webhook-url": {
        const { value, nextIndex } = readOptionValue(key, inlineValue, args, index);
        mutable.webhookUrl = value;
        index = nextIndex;
        break;
      }
      case "--user-id": {
        const { value, nextIndex } = readOptionValue(key, inlineValue, args, index);
        mutable.userId = value;
        index = nextIndex;
        break;
      }
      case "--agent": {
        const { value, nextIndex } = readOptionValue(key, inlineValue, args, index);
        mutable.agent = parseAgentKind(value);
        index = nextIndex;
        break;
      }
      case "--username": {
        const { value, nextIndex } = readOptionValue(key, inlineValue, args, index);
        mutable.username = value;
        index = nextIndex;
        break;
      }
      case "--avatar-url": {
        const { value, nextIndex } = readOptionValue(key, inlineValue, args, index);
        mutable.avatarUrl = value;
        index = nextIndex;
        break;
      }
      case "--chunk-size": {
        const { value, nextIndex } = readOptionValue(key, inlineValue, args, index);
        const chunkSize = Number(value);
        if (!Number.isFinite(chunkSize)) {
          throw new Error("--chunk-size must be a finite number");
        }
        mutable.chunkSize = chunkSize;
        index = nextIndex;
        break;
      }
      case "--embeds-json": {
        const { value, nextIndex } = readOptionValue(key, inlineValue, args, index);
        mutable.embeds = parseEmbeds(value);
        index = nextIndex;
        break;
      }
      default:
        throw new Error(`Unknown option: ${key}`);
    }
  }

  return mutable;
};

const normalizeOptionalText = (value: string | undefined): string | undefined => {
  if (typeof value !== "string") {
    return undefined;
  }
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : undefined;
};

const readOptionalEnv = (name: string): string | undefined => {
  return normalizeOptionalText(Deno.env.get(name));
};

const parseAgentKind = (value: string): AgentKind => {
  const normalized = value.trim().toLowerCase();
  if (normalized === "codex") {
    return "codex";
  }
  if (normalized === "claude") {
    return "claude";
  }
  throw new Error("agent must be either codex or claude");
};

const detectAgentKind = (): AgentKind => {
  if (
    readOptionalEnv("CLAUDECODE")
    || readOptionalEnv("CLAUDE_CODE")
    || readOptionalEnv("ANTHROPIC_API_KEY")
    || readOptionalEnv("ANTHROPIC_MODEL")
  ) {
    return "claude";
  }
  if (readOptionalEnv("CODEX_HOME") || readOptionalEnv("CODEX_ENV") || readOptionalEnv("OPENAI_API_KEY")) {
    return "codex";
  }
  return "codex";
};

const resolveAgentKind = (optionValue: AgentKind | undefined): AgentKind => {
  if (optionValue) {
    return optionValue;
  }
  const envValue = readOptionalEnv(AGENT_ENV_NAME);
  if (envValue) {
    return parseAgentKind(envValue);
  }
  return detectAgentKind();
};

const mapUsernameByAgent = (baseUsername: string, agentKind: AgentKind): string => {
  if (agentKind === "codex") {
    return baseUsername;
  }
  if (/codex/i.test(baseUsername)) {
    return baseUsername.replace(/codex/gi, "Claude Code");
  }
  return baseUsername;
};

const resolveDefaultUsername = (agentKind: AgentKind): string => {
  return agentKind === "claude" ? DEFAULT_CLAUDE_USERNAME : DEFAULT_CODEX_USERNAME;
};

const readRequiredCliValue = (name: string, value: string | undefined): string => {
  if (typeof value !== "string" || value.length === 0) {
    throw new Error(`--${name} is required`);
  }
  return value;
};

const resolveChunkSize = (value: number | undefined): number => {
  if (typeof value === "undefined") {
    return MAX_DISCORD_MESSAGE_LENGTH;
  }
  if (!Number.isFinite(value) || value <= 0) {
    throw new Error("chunkSize must be a positive finite number");
  }
  return Math.min(Math.floor(value), MAX_DISCORD_MESSAGE_LENGTH);
};

const createChunks = (value: string, chunkSize: number): readonly string[] => {
  if (value.length <= chunkSize) {
    return [value];
  }
  const chunks: string[] = [];
  for (let index = 0; index < value.length; index += chunkSize) {
    chunks.push(value.slice(index, index + chunkSize));
  }
  return chunks;
};

const buildMessages = (
  title: string,
  body: string,
  userId: string | undefined,
  username: string,
  avatarUrl: string | undefined,
  embeds: readonly DiscordEmbed[] | undefined,
  chunkSize: number,
): readonly DiscordWebhookMessage[] => {
  const lines: string[] = [];
  const firstLine = userId ? `<@${userId}> **${title}**` : `**${title}**`;
  lines.push(firstLine);
  if (body.trim().length > 0) {
    lines.push(body);
  }
  const content = lines.join("\n");
  const chunks = createChunks(content, chunkSize);
  return chunks.map((chunk, chunkIndex) => ({
    content: chunk,
    username,
    ...(avatarUrl ? { avatar_url: avatarUrl } : {}),
    ...(embeds ? { embeds } : {}),
    ...(userId && chunkIndex === 0
      ? {
          allowed_mentions: {
            users: [userId],
          },
        }
      : {}),
  }));
};

const postMessages = async (
  webhookUrl: string,
  messages: readonly DiscordWebhookMessage[],
  dryRun: boolean,
): Promise<void> => {
  if (dryRun) {
    console.log(
      JSON.stringify(
        {
          webhookUrl,
          messages,
        },
        null,
        2,
      ),
    );
    return;
  }

  for (const message of messages) {
    const response = await fetch(webhookUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(message),
    });
    if (!response.ok) {
      const bodyText = await response.text().catch(() => "<no body>");
      throw new Error(
        `Discord Webhook request failed with status ${response.status} ${response.statusText}: ${bodyText}`,
      );
    }
  }

  console.log(`Sent ${messages.length} Discord message(s).`);
};

const main = async (): Promise<void> => {
  const options = parseArgs(Deno.args);

  const title = readRequiredCliValue("title", options.title);
  const body = readRequiredCliValue("body", options.body);

  const webhookUrl = normalizeOptionalText(options.webhookUrl) ?? readOptionalEnv("DISCORD_WEBHOOK_URL");
  if (!webhookUrl) {
    throw new Error("DISCORD_WEBHOOK_URL is required unless --webhook-url is provided");
  }
  if (!webhookUrl.startsWith(WEBHOOK_PREFIX)) {
    throw new Error(`DISCORD_WEBHOOK_URL must start with ${WEBHOOK_PREFIX}`);
  }

  const agentKind = resolveAgentKind(options.agent);
  const userId = normalizeOptionalText(options.userId) ?? readOptionalEnv("DISCORD_USER_ID");
  const optionUsername = normalizeOptionalText(options.username);
  const envUsername = readOptionalEnv("DISCORD_NOTIFY_USER_NAME");
  const username = optionUsername
    ?? (envUsername ? mapUsernameByAgent(envUsername, agentKind) : resolveDefaultUsername(agentKind));
  const avatarUrl =
    normalizeOptionalText(options.avatarUrl) ?? readOptionalEnv("DISCORD_NOTIFY_AVATAR_URL") ?? DEFAULT_AVATAR_URL;
  const chunkSize = resolveChunkSize(options.chunkSize);

  const messages = buildMessages(title, body, userId, username, avatarUrl, options.embeds, chunkSize);
  await postMessages(webhookUrl, messages, options.dryRun);
};

if (import.meta.main) {
  await main().catch((error: unknown) => {
    const message = error instanceof Error ? error.message : String(error);
    console.error(message);
    Deno.exit(1);
  });
}
