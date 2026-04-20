import { fileURLToPath } from "url";
import { dirname } from "path";

const __dirname = dirname(fileURLToPath(import.meta.url));

/** @type {import('next').NextConfig} */
const nextConfig = {
  distDir: "out",
  output: "export",
  reactStrictMode: true,
  typescript: { ignoreBuildErrors: true },
  basePath: process.env.NEXT_PUBLIC_BASE_PATH || "",
  turbopack: {
    root: __dirname,
  },
  images: { unoptimized: true },
};

export default nextConfig;
