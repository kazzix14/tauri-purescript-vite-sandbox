import { defineConfig } from "vite";
import { viteCommonjs } from "@originjs/vite-plugin-commonjs";
import { ViteEjsPlugin } from "vite-plugin-ejs";
//import commonjs from "@rollup/plugin-commonjs";
//import resolve from "@rollup/plugin-node-resolve";
const viteDelayReloadPlugin = (delay) => {
  return {
    name: "delay-reload",
    handleHotUpdate({ server }): Promise<void> {
      return new Promise(async (resolve) => {
        await new Promise((s) => setTimeout(s, delay));
        resolve();
      });
    },
  };
};

const mobile =
  process.env.TAURI_PLATFORM === "android" ||
  process.env.TAURI_PLATFORM === "ios";

// https://vitejs.dev/config/
export default defineConfig(async () => ({
  plugins: [
    viteCommonjs(),
    //viteDelayReloadPlugin(200),
    ViteEjsPlugin((config) => {
      return {
        isDev: config.mode === "development",
      };
    }),
  ],

  // Vite options tailored for Tauri development and only applied in `tauri dev` or `tauri build`
  // prevent vite from obscuring rust errors
  clearScreen: false,
  // tauri expects a fixed port, fail if that port is not available
  server: {
    port: 1420,
    strictPort: true,
  },
  // to make use of `TAURI_DEBUG` and other env variables
  // https://tauri.studio/v1/api/config#buildconfig.beforedevcommand
  envPrefix: ["VITE_", "TAURI_"],
  build: {
    // Tauri supports es2021
    target: process.env.TAURI_PLATFORM == "windows" ? "chrome105" : "safari13",
    // don't minify for debug builds
    minify: !process.env.TAURI_DEBUG ? "esbuild" : false,
    // produce sourcemaps for debug builds
    sourcemap: !!process.env.TAURI_DEBUG,
    outDir: "output",
  },
}));
