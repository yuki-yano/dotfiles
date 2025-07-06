#!/usr/bin/env -S deno run --allow-net --allow-env --allow-sys

type DiscordWebhookPayload = {
  content: string;
  username?: string;
  avatar_url?: string;
};

async function sendDiscordNotification(
  webhookUrl: string,
  message: string,
  options: {
    username?: string;
    title?: string;
  } = {},
): Promise<void> {
  // Discord API制限
  const MAX_CONTENT_LENGTH = 2000;
  const MAX_USERNAME_LENGTH = 80;

  // DISCORD_USER_IDがあればメンションを追加
  const userId = Deno.env.get("DISCORD_USER_ID");
  const mention = userId ? `<@${userId}> ` : "";

  // タイトルとメッセージを組み合わせ
  const fullMessage = options.title
    ? `**${options.title}**\n${message}\n_From ${Deno.hostname()}_`
    : `${message}\n_From ${Deno.hostname()}_`;

  const contentWithMention = mention + fullMessage;

  // メッセージの検証と切り詰め
  const truncatedContent = contentWithMention.length > MAX_CONTENT_LENGTH
    ? contentWithMention.slice(0, MAX_CONTENT_LENGTH - 3) + "..."
    : contentWithMention;

  const truncatedUsername = options.username && options.username.length > MAX_USERNAME_LENGTH
    ? options.username.slice(0, MAX_USERNAME_LENGTH - 3) + "..."
    : options.username || "Claude Code Notification";

  const payload: DiscordWebhookPayload = {
    content: truncatedContent,
    username: truncatedUsername,
  };

  const response = await fetch(webhookUrl, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    const responseText = await response.text();
    console.error(`Response body: ${responseText}`);
    throw new Error(`Discord API error: ${response.status} ${response.statusText}`);
  }
}

// Main CLI
if (import.meta.main) {
  const args = Deno.args;

  if (args.length === 0 || args.includes("-h") || args.includes("--help")) {
    console.log(`Discord Webhook Notification CLI

Usage:
  discord-notify <webhook-url> <message> [options]
  discord-notify --env DISCORD_WEBHOOK_URL <message> [options]

Options:
  -h, --help              Show this help
  --env <VAR_NAME>        Use webhook URL from environment variable
  --username <name>       Set username (default: "Claude Code Notification")
  --title <title>         Set message title

Environment Variables:
  DISCORD_USER_ID         Discord user ID to mention in the message

Examples:
  discord-notify "https://discord.com/api/webhooks/..." "Build completed successfully"
  discord-notify --env DISCORD_WEBHOOK_URL "Tests passed" --title "CI Status"
  discord-notify --env DISCORD_WEBHOOK_URL "Deploy finished" --title "Deployment"
  
  # With user mention (requires DISCORD_USER_ID env var)
  DISCORD_USER_ID=123456789 discord-notify --env DISCORD_WEBHOOK_URL "Task completed"
`);
    Deno.exit(0);
  }

  let webhookUrl: string | undefined;
  let message: string | undefined;
  const options: { username?: string; title?: string } = {};

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];

    if (arg === "--env") {
      const envVar = args[++i];
      webhookUrl = Deno.env.get(envVar);
      if (!webhookUrl) {
        console.error(`Error: Environment variable ${envVar} not found`);
        Deno.exit(1);
      }
    } else if (arg === "--username") {
      options.username = args[++i];
    } else if (arg === "--title") {
      options.title = args[++i];
    } else if (!webhookUrl && arg.startsWith("https://discord.com/api/webhooks/")) {
      webhookUrl = arg;
    } else if (!message) {
      message = arg;
    }
  }

  if (!webhookUrl) {
    console.error("Error: Discord webhook URL is required");
    Deno.exit(1);
  }

  if (!message) {
    console.error("Error: Message is required");
    Deno.exit(1);
  }

  try {
    await sendDiscordNotification(webhookUrl, message, options);
    console.log("✓ Notification sent successfully");
  } catch (error) {
    console.error(`Error: ${(error as Error).message}`);
    Deno.exit(1);
  }
}
