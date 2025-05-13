#!/usr/bin/env -S deno run -A

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title yabai-scene
// @raycast.packageName yabai app desktop save and load package
// @raycast.mode compact

// Optional parameters:
// @raycast.icon 🖥️
// @raycast.argument1 { "type": "dropdown", "placeholder": "Mode", "data": [{ "title": "save", "value": "save" }, { "title": "load", "value": "load" }] }

// Documentation:
// @raycast.description Resize window from yabai
// @raycast.author Yuki Yano
// @raycast.authorURL https://github.com/yuki-yano

import { ensureDir } from "jsr:@std/fs@0.213.0/ensure_dir";
import $ from "jsr:@david/dax@0.42.0";

Deno.env.set("PATH", `${Deno.env.get("PATH")}:${Deno.env.get("HOME")}/.local/bin`);

type Window = {
  id: number;
  app: string;
  title: string;
  space: number;
  frame: {
    x: number;
    y: number;
    w: number;
    h: number;
  };
  display: number;
  "is-hidden": boolean;
  "is-floating": boolean;
};

type Space = {
  id: number;
  windows: Array<Window>;
};

const DATA_DIR = `${Deno.env.get("HOME")}/dotfiles/data/yabai`;
const DATA_FILE = `${DATA_DIR}/yabai-app-desktop-save.json`;

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

const mode = Deno.args[0];

const getYabaiSpaces = async (): Promise<Array<Space>> => {
  try {
    const spacesOutput = await $`yabai -m query --spaces`.json();
    const spaces = spacesOutput as Array<{ index: number }>;

    const spacesWithWindows: Array<Space> = await Promise.all(
      spaces.map(async (space: { index: number }) => {
        const windowsOutput = await $`yabai -m query --windows --space ${space.index}`.json();
        const windows = windowsOutput as Array<Window>;
        const processedWindows: Array<Window> = windows
          .filter((window) => !window["is-hidden"])
          .map((window) => {
            return {
              id: window.id,
              app: window.app,
              title: window.title,
              space: window.space,
              frame: window.frame,
              display: window.display,
              "is-hidden": window["is-hidden"],
              "is-floating": window["is-floating"],
            };
          });

        return {
          id: space.index,
          windows: processedWindows,
        };
      }),
    );

    return spacesWithWindows;
  } catch (error) {
    console.error("Error fetching yabai information:", error);
    throw error;
  }
};

const saveSpaces = async (spaces: Array<Space>): Promise<void> => {
  try {
    await ensureDir(DATA_DIR);

    await Deno.writeTextFile(
      DATA_FILE,
      JSON.stringify(spaces, null, 2),
    );

    console.log(`Saved window layout to ${DATA_FILE}`);
  } catch (error) {
    console.error("Failed to save spaces:", error);
    throw error;
  }
};

const moveWindowToSpace = async (originalWindow: Window, targetSpace: number, otherDisplay: number) => {
  const isFloating = originalWindow["is-floating"];
  let window: Window;
  try {
    window = await $`yabai -m query --windows --window ${originalWindow.id}`.json() as Window;
  } catch (error) {
    console.error(`Failed to get window ${originalWindow.id}: ${error}`);
    const windows = await $`yabai -m query --windows`.json() as Array<Window>;
    const targetWindow = windows.find((window) => window.app === originalWindow.app);
    if (targetWindow == null) {
      console.error(`No windows found for ${originalWindow.app}`);
      return;
    }
    window = targetWindow;
  }

  if (isFloating) {
    await $`yabai -m window ${window.id} --toggle float`;
  }

  console.log(`Moving window ${window.id} to space ${targetSpace} on display ${otherDisplay}`);

  try {
    await $`yabai -m window ${window.id} --display ${otherDisplay}`;
  } catch (error) {
    console.error(`Failed to move window ${window.id} to display ${otherDisplay}: ${error}`);
  }

  try {
    await $`space-switch ${targetSpace}`;
    await sleep(300);
    await $`yabai -m window ${window.id} --display ${originalWindow.display}`;
    await sleep(100);
  } catch (error) {
    console.error(`Failed to move window ${window.id}: ${error}`);
  }

  if (isFloating) {
    await $`yabai -m window ${window.id} --toggle float`;
    try {
      await $`yabai -m window ${window.id} --move abs:${window.frame.x}:${window.frame.y}`;
      await $`yabai -m window ${window.id} --resize abs:${window.frame.w}:${window.frame.h}`;
    } catch (error) {
      console.error(`Failed to move window ${window.id}: ${error}`);
    }
  }
};

const main = async () => {
  if (mode === "load" || mode == null) {
    try {
      const data = await Deno.readTextFile(DATA_FILE);
      const savedSpaces = JSON.parse(data);

      const groupWindowsByApp = (spaces: Array<Space>) => {
        const windowsByApp: Record<string, Array<Window>> = {};
        spaces.flatMap((space) => space.windows).forEach((window) => {
          if (!windowsByApp[window.app]) {
            windowsByApp[window.app] = [];
          }
          windowsByApp[window.app].push(window);
        });
        return windowsByApp;
      };

      const displays = await $`yabai -m query --displays`.json() as Array<{ index: number }>;

      const savedWindowsByApp = groupWindowsByApp(savedSpaces);
      for (const [app, savedWindows] of Object.entries(savedWindowsByApp)) {
        const targetSpace = savedWindows[0].space;
        const otherDisplay = displays.find((display) => display.index !== savedWindows[0].display)?.index;
        if (otherDisplay == null) {
          console.error(`No other display found for ${app}`);
          continue;
        }

        for (const window of savedWindows) {
          await moveWindowToSpace(window, targetSpace, otherDisplay);
        }
      }
    } catch (error) {
      console.error("Failed to load spaces:", error);
    }
  } else if (mode === "save") {
    try {
      const spaces = await getYabaiSpaces();
      await saveSpaces(spaces);
    } catch (error) {
      console.error("Failed to get window information:", error);
    }
  }
};

await main();
