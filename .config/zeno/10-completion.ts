import { defineConfig } from "jsr:@yuki-yano/zeno@0.2.0";
import { join } from "jsr:@std/path@1.1.2";


export default defineConfig(() => ({
  completions: [
    {
      name: "npm scripts",
      patterns: ["^npm run $"],
      sourceFunction: async ({ projectRoot }) => {
        try {
          const pkgPath = join(projectRoot, "package.json");
          const pkg = JSON.parse(
            await Deno.readTextFile(pkgPath),
          ) as { scripts?: Record<string, unknown> };
          return Object.keys(pkg.scripts ?? {});
        } catch {
          return [];
        }
      },
      options: { "--prompt": "'npm scripts> '" },
      callbackFunction: ({ items, context }) => {
        const script = items[0];
        if (!script) {
          return undefined;
        }
        const buffer = `${context.buffer}${script}`;
        return { buffer, cursor: buffer.length };
      },
    },
  ],
}));
